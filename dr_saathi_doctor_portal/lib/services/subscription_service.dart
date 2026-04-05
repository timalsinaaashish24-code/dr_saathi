import '../models/pricing_tier.dart';
import 'database_service.dart';

class SubscriptionService {
  final DatabaseService _dbService = DatabaseService();
  
  // Get current subscription for a doctor
  Future<Map<String, dynamic>?> getCurrentSubscription(String doctorId) async {
    try {
      final result = await (await _dbService.database).query(
        'subscriptions',
        where: 'doctor_id = ? AND is_active = ?',
        whereArgs: [doctorId, 1],
        orderBy: 'created_at DESC',
        limit: 1,
      );
      
      if (result.isNotEmpty) {
        return result.first;
      }
      return null;
    } catch (e) {
      print('Error getting current subscription: \$e');
      return null;
    }
  }

  // Check if doctor has active subscription
  Future<bool> hasActiveSubscription(String doctorId) async {
    final subscription = await getCurrentSubscription(doctorId);
    if (subscription == null) return false;
    
    final expiryDate = DateTime.parse(subscription['expires_at']);
    return DateTime.now().isBefore(expiryDate);
  }

  // Get current patient count for a doctor
  Future<int> getCurrentPatientCount(String doctorId) async {
    try {
      final result = await (await _dbService.database).rawQuery(
        'SELECT COUNT(*) as count FROM patients WHERE doctor_id = ?',
        [doctorId],
      );
      return result.first['count'] as int;
    } catch (e) {
      print('Error getting patient count: \$e');
      return 0;
    }
  }

  // Check if doctor can add more patients
  Future<bool> canAddPatient(String doctorId) async {
    final subscription = await getCurrentSubscription(doctorId);
    if (subscription == null) {
      // No subscription, allow limited free tier (e.g., 50 patients)
      final currentCount = await getCurrentPatientCount(doctorId);
      return currentCount < 50; // Free tier limit
    }
    
    final tierId = subscription['tier_id'];
    final tier = PricingTier.getTierById(tierId);
    if (tier == null) return false;
    
    final currentCount = await getCurrentPatientCount(doctorId);
    return currentCount < tier.maxPatients;
  }

  // Subscribe to a tier
  Future<bool> subscribeToTier({
    required String doctorId,
    required String tierId,
    required int durationMonths,
  }) async {
    try {
      final tier = PricingTier.getTierById(tierId);
      if (tier == null) return false;

      final now = DateTime.now();
      final expiryDate = now.add(Duration(days: 30 * durationMonths));
      
      // Deactivate existing subscriptions
      await (await _dbService.database).update(
        'subscriptions',
        {'is_active': 0},
        where: 'doctor_id = ?',
        whereArgs: [doctorId],
      );
      
      // Create new subscription
      await (await _dbService.database).insert('subscriptions', {
        'doctor_id': doctorId,
        'tier_id': tierId,
        'tier_name': tier.name,
        'max_patients': tier.maxPatients,
        'price': tier.price,
        'duration_months': durationMonths,
        'is_active': 1,
        'created_at': now.toIso8601String(),
        'expires_at': expiryDate.toIso8601String(),
      });
      
      return true;
    } catch (e) {
      print('Error subscribing to tier: \$e');
      return false;
    }
  }

  // Get subscription details for display
  Future<Map<String, dynamic>?> getSubscriptionDetails(String doctorId) async {
    final subscription = await getCurrentSubscription(doctorId);
    if (subscription == null) return null;
    
    final patientCount = await getCurrentPatientCount(doctorId);
    final isActive = await hasActiveSubscription(doctorId);
    
    return {
      ...subscription,
      'current_patient_count': patientCount,
      'is_currently_active': isActive,
      'patients_remaining': (subscription['max_patients'] as int) - patientCount,
    };
  }

  // Cancel subscription
  Future<bool> cancelSubscription(String doctorId) async {
    try {
      await (await _dbService.database).update(
        'subscriptions',
        {'is_active': 0, 'cancelled_at': DateTime.now().toIso8601String()},
        where: 'doctor_id = ? AND is_active = ?',
        whereArgs: [doctorId, 1],
      );
      return true;
    } catch (e) {
      print('Error cancelling subscription: \$e');
      return false;
    }
  }

  // Upgrade subscription
  Future<bool> upgradeSubscription({
    required String doctorId,
    required String newTierId,
  }) async {
    try {
      final currentSubscription = await getCurrentSubscription(doctorId);
      if (currentSubscription == null) {
        // No current subscription, treat as new subscription
        return await subscribeToTier(
          doctorId: doctorId,
          tierId: newTierId,
          durationMonths: 1,
        );
      }
      
      final newTier = PricingTier.getTierById(newTierId);
      if (newTier == null) return false;
      
      // Update existing subscription
      await (await _dbService.database).update(
        'subscriptions',
        {
          'tier_id': newTierId,
          'tier_name': newTier.name,
          'max_patients': newTier.maxPatients,
          'price': newTier.price,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'doctor_id = ? AND is_active = ?',
        whereArgs: [doctorId, 1],
      );
      
      return true;
    } catch (e) {
      print('Error upgrading subscription: \$e');
      return false;
    }
  }

  // Initialize subscription table
  Future<void> initializeSubscriptionTable() async {
    try {
      await (await _dbService.database).execute('''
        CREATE TABLE IF NOT EXISTS subscriptions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          doctor_id TEXT NOT NULL,
          tier_id TEXT NOT NULL,
          tier_name TEXT NOT NULL,
          max_patients INTEGER NOT NULL,
          price REAL NOT NULL,
          duration_months INTEGER NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          expires_at TEXT NOT NULL,
          cancelled_at TEXT
        )
      ''');
      
      print('Subscription table initialized successfully');
    } catch (e) {
      print('Error initializing subscription table: \$e');
    }
  }

  // Get subscription history
  Future<List<Map<String, dynamic>>> getSubscriptionHistory(String doctorId) async {
    try {
      final result = await (await _dbService.database).query(
        'subscriptions',
        where: 'doctor_id = ?',
        whereArgs: [doctorId],
        orderBy: 'created_at DESC',
      );
      return result;
    } catch (e) {
      print('Error getting subscription history: \$e');
      return [];
    }
  }

  // Check if subscription is about to expire (within 7 days)
  Future<bool> isSubscriptionExpiringSoon(String doctorId) async {
    final subscription = await getCurrentSubscription(doctorId);
    if (subscription == null) return false;
    
    final expiryDate = DateTime.parse(subscription['expires_at']);
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate.difference(now).inDays;
    
    return daysUntilExpiry <= 7 && daysUntilExpiry > 0;
  }

  // Send subscription renewal notification
  Future<void> sendRenewalNotification(String doctorId) async {
    // TODO: Implement email/SMS notification for subscription renewal
    print('Renewal notification sent to doctor: \$doctorId');
  }
}
