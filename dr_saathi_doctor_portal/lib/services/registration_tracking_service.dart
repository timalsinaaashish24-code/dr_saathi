import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';

class RegistrationTrackingService {
  static final RegistrationTrackingService _instance = RegistrationTrackingService._internal();
  factory RegistrationTrackingService() => _instance;
  RegistrationTrackingService._internal();

  final _uuid = const Uuid();

  // Record new user registration
  Future<void> recordUserRegistration({
    required String userId,
    required String userType, // 'doctor' or 'patient'
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final db = await DatabaseService().database;
      final now = DateTime.now().toIso8601String();
      final platform = _getPlatform();
      final deviceInfo = await _getDeviceInfo();
      final appVersion = await _getAppVersion();

      await db.insert(
        'user_registrations',
        {
          'id': _uuid.v4(),
          'userId': userId,
          'userType': userType,
          'registrationDate': now,
          'platform': platform,
          'deviceInfo': deviceInfo,
          'appVersion': appVersion,
          'isActive': 1,
          'lastActiveAt': now,
          'createdAt': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('User registration recorded: $userId ($userType)');
    } catch (e) {
      print('Error recording user registration: $e');
    }
  }

  // Update last active timestamp
  Future<void> updateLastActive(String userId) async {
    try {
      final db = await DatabaseService().database;
      await db.update(
        'user_registrations',
        {
          'lastActiveAt': DateTime.now().toIso8601String(),
          'isActive': 1,
        },
        where: 'userId = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      print('Error updating last active: $e');
    }
  }

  // Mark user as inactive
  Future<void> markUserInactive(String userId) async {
    try {
      final db = await DatabaseService().database;
      await db.update(
        'user_registrations',
        {'isActive': 0},
        where: 'userId = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      print('Error marking user inactive: $e');
    }
  }

  // Get total registered users
  Future<int> getTotalUsers() async {
    try {
      final db = await DatabaseService().database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM user_registrations'
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      print('Error getting total users: $e');
      return 0;
    }
  }

  // Get active users count
  Future<int> getActiveUsers() async {
    try {
      final db = await DatabaseService().database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM user_registrations WHERE isActive = 1'
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      print('Error getting active users: $e');
      return 0;
    }
  }

  // Get users by type
  Future<Map<String, int>> getUsersByType() async {
    try {
      final db = await DatabaseService().database;
      final result = await db.rawQuery(
        '''SELECT userType, COUNT(*) as count 
           FROM user_registrations 
           GROUP BY userType'''
      );
      
      final userCounts = <String, int>{};
      for (var row in result) {
        final type = row['userType'] as String;
        final count = (row['count'] as int?) ?? 0;
        userCounts[type] = count;
      }
      return userCounts;
    } catch (e) {
      print('Error getting users by type: $e');
      return {};
    }
  }

  // Get registrations over time
  Future<List<Map<String, dynamic>>> getRegistrationsTrend(DateTime startDate, DateTime endDate) async {
    try {
      final db = await DatabaseService().database;
      final result = await db.rawQuery(
        '''SELECT DATE(registrationDate) as date, COUNT(*) as count
           FROM user_registrations
           WHERE registrationDate BETWEEN ? AND ?
           GROUP BY DATE(registrationDate)
           ORDER BY date''',
        [startDate.toIso8601String(), endDate.toIso8601String()]
      );
      
      return result.map((row) => {
        'date': row['date'] as String,
        'count': (row['count'] as int?) ?? 0,
      }).toList();
    } catch (e) {
      print('Error getting registrations trend: $e');
      return [];
    }
  }

  // Get users by platform
  Future<Map<String, int>> getUsersByPlatform() async {
    try {
      final db = await DatabaseService().database;
      final result = await db.rawQuery(
        '''SELECT platform, COUNT(*) as count 
           FROM user_registrations 
           GROUP BY platform'''
      );
      
      final platformCounts = <String, int>{};
      for (var row in result) {
        final platform = row['platform'] as String;
        final count = (row['count'] as int?) ?? 0;
        platformCounts[platform] = count;
      }
      return platformCounts;
    } catch (e) {
      print('Error getting users by platform: $e');
      return {};
    }
  }

  // Get user registration info
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      final db = await DatabaseService().database;
      final result = await db.query(
        'user_registrations',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      
      if (result.isNotEmpty) {
        return result.first;
      }
      return null;
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }

  // Get recently active users (last 7 days)
  Future<int> getRecentlyActiveUsers({int days = 7}) async {
    try {
      final db = await DatabaseService().database;
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      final result = await db.rawQuery(
        '''SELECT COUNT(*) as count 
           FROM user_registrations 
           WHERE lastActiveAt >= ?''',
        [cutoffDate.toIso8601String()]
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      print('Error getting recently active users: $e');
      return 0;
    }
  }

  // Helper: Get platform string
  String _getPlatform() {
    if (kIsWeb) return 'Web';
    try {
      if (Platform.isAndroid) return 'Android';
      if (Platform.isIOS) return 'iOS';
      if (Platform.isMacOS) return 'macOS';
      if (Platform.isWindows) return 'Windows';
      if (Platform.isLinux) return 'Linux';
    } catch (e) {
      // Platform detection failed
    }
    return 'Unknown';
  }

  // Helper: Get device information
  Future<String> _getDeviceInfo() async {
    // In a real app, use device_info_plus package
    // For now, return basic platform info
    return _getPlatform();
  }

  // Helper: Get app version
  Future<String> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      return '1.0.0'; // Fallback version
    }
  }
}
