import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class AnalyticsTrackingService {
  static final AnalyticsTrackingService _instance = AnalyticsTrackingService._internal();
  factory AnalyticsTrackingService() => _instance;
  AnalyticsTrackingService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // Track user login
  Future<void> trackUserLogin(String userId, String userType) async {
    await _analytics.logLogin(loginMethod: userType);
    await _recordUserActivity(userId, 'login', userType);
    
    // Set user properties
    await _analytics.setUserId(id: userId);
    await _analytics.setUserProperty(name: 'user_type', value: userType);
  }
  
  // Track user logout
  Future<void> trackUserLogout(String userId) async {
    await _analytics.logEvent(name: 'user_logout');
    await _recordUserActivity(userId, 'logout', null);
  }
  
  // Track app opens
  Future<void> trackAppOpen(String userId, String userType) async {
    await _analytics.logAppOpen();
    await _recordUserActivity(userId, 'app_open', userType);
  }
  
  // Track screen views
  Future<void> trackScreenView(String screenName, String? userId) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenName,
    );
    if (userId != null) {
      await _recordUserActivity(userId, 'screen_view', screenName);
    }
  }
  
  // Track feature usage
  Future<void> trackFeatureUse(String userId, String featureName) async {
    await _analytics.logEvent(
      name: 'feature_used',
      parameters: {
        'feature_name': featureName,
        'user_id': userId,
      },
    );
    await _recordUserActivity(userId, 'feature_use', featureName);
  }
  
  // Track appointment booking
  Future<void> trackAppointmentBooked(String userId, String doctorId) async {
    await _analytics.logEvent(
      name: 'appointment_booked',
      parameters: {
        'user_id': userId,
        'doctor_id': doctorId,
      },
    );
    await _recordUserActivity(userId, 'appointment_booked', doctorId);
  }
  
  // Track prescription creation
  Future<void> trackPrescriptionCreated(String doctorId, String patientId) async {
    await _analytics.logEvent(
      name: 'prescription_created',
      parameters: {
        'doctor_id': doctorId,
        'patient_id': patientId,
      },
    );
    await _recordUserActivity(doctorId, 'prescription_created', patientId);
  }
  
  // Track payment
  Future<void> trackPayment(String userId, double amount, String paymentType) async {
    await _analytics.logEvent(
      name: 'payment_made',
      parameters: {
        'user_id': userId,
        'amount': amount,
        'payment_type': paymentType,
      },
    );
    await _recordUserActivity(userId, 'payment', paymentType);
  }
  
  // Record user activity in local database
  Future<void> _recordUserActivity(String userId, String activityType, String? activityData) async {
    try {
      final db = await DatabaseService().database;
      await db.insert(
        'user_activities',
        {
          'userId': userId,
          'activityType': activityType,
          'activityData': activityData,
          'timestamp': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error recording user activity: $e');
    }
  }
  
  // Get analytics data
  Future<Map<String, dynamic>> getAnalyticsData(DateTime startDate, DateTime endDate) async {
    final db = await DatabaseService().database;
    
    // Total users
    final totalUsersResult = await db.rawQuery(
      'SELECT COUNT(DISTINCT userId) as count FROM user_activities'
    );
    
    // Active users in period
    final activeUsersResult = await db.rawQuery(
      'SELECT COUNT(DISTINCT userId) as count FROM user_activities WHERE timestamp BETWEEN ? AND ?',
      [startDate.toIso8601String(), endDate.toIso8601String()]
    );
    
    // Daily active users
    final dailyActiveResult = await db.rawQuery(
      'SELECT DATE(timestamp) as date, COUNT(DISTINCT userId) as count FROM user_activities WHERE timestamp BETWEEN ? AND ? GROUP BY DATE(timestamp) ORDER BY date',
      [startDate.toIso8601String(), endDate.toIso8601String()]
    );
    
    // User types
    final userTypesResult = await db.rawQuery(
      '''SELECT activityData as userType, COUNT(DISTINCT userId) as count 
         FROM user_activities 
         WHERE activityType = "login" AND timestamp BETWEEN ? AND ?
         GROUP BY activityData''',
      [startDate.toIso8601String(), endDate.toIso8601String()]
    );
    
    // Feature usage
    final featureUsageResult = await db.rawQuery(
      '''SELECT activityData as feature, COUNT(*) as count 
         FROM user_activities 
         WHERE activityType = "feature_use" AND timestamp BETWEEN ? AND ?
         GROUP BY activityData
         ORDER BY count DESC
         LIMIT 10''',
      [startDate.toIso8601String(), endDate.toIso8601String()]
    );
    
    return {
      'totalUsers': totalUsersResult.first['count'] ?? 0,
      'activeUsers': activeUsersResult.first['count'] ?? 0,
      'dailyActiveUsers': dailyActiveResult,
      'userTypes': userTypesResult,
      'topFeatures': featureUsageResult,
    };
  }
  
  // Get today's active users
  Future<int> getTodayActiveUsers() async {
    final db = await DatabaseService().database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT userId) as count FROM user_activities WHERE timestamp BETWEEN ? AND ?',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()]
    );
    
    return (result.first['count'] as int?) ?? 0;
  }
  
  // Get user retention rate
  Future<double> getUserRetentionRate(int days) async {
    final db = await DatabaseService().database;
    final startDate = DateTime.now().subtract(Duration(days: days));
    
    final newUsersResult = await db.rawQuery(
      '''SELECT COUNT(DISTINCT userId) as count 
         FROM user_activities 
         WHERE activityType = "login" 
         AND timestamp BETWEEN ? AND ?''',
      [startDate.toIso8601String(), DateTime.now().toIso8601String()]
    );
    
    final returningUsersResult = await db.rawQuery(
      '''SELECT COUNT(DISTINCT userId) as count 
         FROM user_activities 
         WHERE userId IN (
           SELECT DISTINCT userId FROM user_activities 
           WHERE timestamp < ?
         )
         AND timestamp BETWEEN ? AND ?''',
      [startDate.toIso8601String(), startDate.toIso8601String(), DateTime.now().toIso8601String()]
    );
    
    final newUsers = (newUsersResult.first['count'] as int?) ?? 0;
    final returningUsers = (returningUsersResult.first['count'] as int?) ?? 0;
    
    if (newUsers == 0) return 0.0;
    return (returningUsers / newUsers) * 100;
  }
}
