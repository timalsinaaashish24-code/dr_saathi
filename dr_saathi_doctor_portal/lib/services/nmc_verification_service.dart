import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class NMCVerificationService {
  final DatabaseService _databaseService = DatabaseService();

  Future<Database> get _database async => await _databaseService.database;

  /// Initialize NMC verification tables
  Future<void> initialize() async {
    final db = await _database;
    
    // Create table for verified NMC registration numbers
    await db.execute('''
      CREATE TABLE IF NOT EXISTS nmc_verified_doctors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nmc_number TEXT UNIQUE NOT NULL,
        doctor_name TEXT NOT NULL,
        specialization TEXT,
        registration_date TEXT,
        expiry_date TEXT,
        status TEXT NOT NULL,
        verified_at TEXT NOT NULL,
        last_updated TEXT NOT NULL,
        data_source TEXT,
        additional_info TEXT
      )
    ''');

    // Create table for NMC update logs
    await db.execute('''
      CREATE TABLE IF NOT EXISTS nmc_update_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        update_date TEXT NOT NULL,
        total_records_added INTEGER,
        total_records_updated INTEGER,
        update_source TEXT,
        status TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Create index for faster NMC number lookups
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_nmc_number 
      ON nmc_verified_doctors(nmc_number)
    ''');
  }

  /// Verify if an NMC registration number is valid and active
  Future<bool> verifyNMCNumber(String nmcNumber) async {
    try {
      final db = await _database;
      final result = await db.query(
        'nmc_verified_doctors',
        where: 'nmc_number = ? AND status = ?',
        whereArgs: [nmcNumber.trim().toUpperCase(), 'active'],
      );
      
      return result.isNotEmpty;
    } catch (e) {
      print('Error verifying NMC number: $e');
      return false;
    }
  }

  /// Get detailed information about a verified NMC number
  Future<Map<String, dynamic>?> getNMCDetails(String nmcNumber) async {
    try {
      final db = await _database;
      final result = await db.query(
        'nmc_verified_doctors',
        where: 'nmc_number = ?',
        whereArgs: [nmcNumber.trim().toUpperCase()],
      );
      
      if (result.isNotEmpty) {
        return result.first;
      }
      return null;
    } catch (e) {
      print('Error getting NMC details: $e');
      return null;
    }
  }

  /// Add or update a verified NMC registration
  Future<int> addOrUpdateNMCRecord({
    required String nmcNumber,
    required String doctorName,
    String? specialization,
    String? registrationDate,
    String? expiryDate,
    String status = 'active',
    String? dataSource,
    String? additionalInfo,
  }) async {
    try {
      final db = await _database;
      final now = DateTime.now().toIso8601String();
      
      final data = {
        'nmc_number': nmcNumber.trim().toUpperCase(),
        'doctor_name': doctorName,
        'specialization': specialization,
        'registration_date': registrationDate,
        'expiry_date': expiryDate,
        'status': status,
        'verified_at': now,
        'last_updated': now,
        'data_source': dataSource ?? 'Manual Entry',
        'additional_info': additionalInfo,
      };
      
      return await db.insert(
        'nmc_verified_doctors',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error adding NMC record: $e');
      return -1;
    }
  }

  /// Bulk import NMC records from a list
  Future<int> bulkImportNMCRecords(List<Map<String, dynamic>> records) async {
    try {
      final db = await _database;
      final batch = db.batch();
      final now = DateTime.now().toIso8601String();
      int count = 0;
      
      for (var record in records) {
        final data = {
          'nmc_number': record['nmc_number'].toString().trim().toUpperCase(),
          'doctor_name': record['doctor_name'],
          'specialization': record['specialization'],
          'registration_date': record['registration_date'],
          'expiry_date': record['expiry_date'],
          'status': record['status'] ?? 'active',
          'verified_at': now,
          'last_updated': now,
          'data_source': record['data_source'] ?? 'Bulk Import',
          'additional_info': record['additional_info'],
        };
        
        batch.insert(
          'nmc_verified_doctors',
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        count++;
      }
      
      await batch.commit(noResult: true);
      
      // Log the bulk import
      await _logUpdate(
        totalAdded: count,
        totalUpdated: 0,
        source: 'Bulk Import',
        status: 'completed',
        notes: 'Imported $count NMC records',
      );
      
      return count;
    } catch (e) {
      print('Error in bulk import: $e');
      return -1;
    }
  }

  /// Update NMC record status (e.g., expired, suspended, revoked)
  Future<int> updateNMCStatus(String nmcNumber, String status, {String? notes}) async {
    try {
      final db = await _database;
      return await db.update(
        'nmc_verified_doctors',
        {
          'status': status,
          'last_updated': DateTime.now().toIso8601String(),
          'additional_info': notes,
        },
        where: 'nmc_number = ?',
        whereArgs: [nmcNumber.trim().toUpperCase()],
      );
    } catch (e) {
      print('Error updating NMC status: $e');
      return 0;
    }
  }

  /// Get all verified NMC numbers (for admin purposes)
  Future<List<Map<String, dynamic>>> getAllVerifiedNMCs({
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await _database;
      
      String whereClause = '';
      List<dynamic> whereArgs = [];
      
      if (status != null) {
        whereClause = 'status = ?';
        whereArgs.add(status);
      }
      
      final result = await db.query(
        'nmc_verified_doctors',
        where: whereClause.isEmpty ? null : whereClause,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: 'doctor_name ASC',
        limit: limit,
        offset: offset,
      );
      
      return result;
    } catch (e) {
      print('Error getting verified NMCs: $e');
      return [];
    }
  }

  /// Get NMC verification statistics
  Future<Map<String, int>> getNMCStats() async {
    try {
      final db = await _database;
      
      final totalResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM nmc_verified_doctors'
      );
      
      final activeResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM nmc_verified_doctors WHERE status = ?',
        ['active']
      );
      
      final expiredResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM nmc_verified_doctors WHERE status = ?',
        ['expired']
      );
      
      final suspendedResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM nmc_verified_doctors WHERE status = ?',
        ['suspended']
      );
      
      return {
        'total': totalResult.first['count'] as int,
        'active': activeResult.first['count'] as int,
        'expired': expiredResult.first['count'] as int,
        'suspended': suspendedResult.first['count'] as int,
      };
    } catch (e) {
      print('Error getting NMC stats: $e');
      return {'total': 0, 'active': 0, 'expired': 0, 'suspended': 0};
    }
  }

  /// Check for expired registrations and update their status
  Future<int> updateExpiredRegistrations() async {
    try {
      final db = await _database;
      final now = DateTime.now().toIso8601String();
      
      final result = await db.update(
        'nmc_verified_doctors',
        {
          'status': 'expired',
          'last_updated': now,
        },
        where: 'expiry_date IS NOT NULL AND expiry_date < ? AND status = ?',
        whereArgs: [now, 'active'],
      );
      
      if (result > 0) {
        await _logUpdate(
          totalAdded: 0,
          totalUpdated: result,
          source: 'Automatic Expiry Check',
          status: 'completed',
          notes: 'Updated $result expired registrations',
        );
      }
      
      return result;
    } catch (e) {
      print('Error updating expired registrations: $e');
      return 0;
    }
  }

  /// Log NMC database updates
  Future<void> _logUpdate({
    required int totalAdded,
    required int totalUpdated,
    required String source,
    required String status,
    String? notes,
  }) async {
    try {
      final db = await _database;
      await db.insert('nmc_update_logs', {
        'update_date': DateTime.now().toIso8601String().split('T')[0],
        'total_records_added': totalAdded,
        'total_records_updated': totalUpdated,
        'update_source': source,
        'status': status,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error logging update: $e');
    }
  }

  /// Get update history
  Future<List<Map<String, dynamic>>> getUpdateHistory({int? limit}) async {
    try {
      final db = await _database;
      return await db.query(
        'nmc_update_logs',
        orderBy: 'created_at DESC',
        limit: limit ?? 50,
      );
    } catch (e) {
      print('Error getting update history: $e');
      return [];
    }
  }

  /// Search for NMC records
  Future<List<Map<String, dynamic>>> searchNMCRecords(String query) async {
    try {
      final db = await _database;
      final searchTerm = '%${query.toUpperCase()}%';
      
      return await db.query(
        'nmc_verified_doctors',
        where: 'nmc_number LIKE ? OR UPPER(doctor_name) LIKE ?',
        whereArgs: [searchTerm, searchTerm],
        orderBy: 'doctor_name ASC',
        limit: 50,
      );
    } catch (e) {
      print('Error searching NMC records: $e');
      return [];
    }
  }

  /// Load sample/demo NMC data for testing
  Future<void> loadSampleNMCData() async {
    final sampleData = [
      {
        'nmc_number': 'NMC12345',
        'doctor_name': 'Dr. Ram Prasad Sharma',
        'specialization': 'General Medicine',
        'registration_date': '2020-01-15',
        'expiry_date': '2030-01-15',
        'status': 'active',
        'data_source': 'Sample Data',
      },
      {
        'nmc_number': 'NMC23456',
        'doctor_name': 'Dr. Sita Kumari Thapa',
        'specialization': 'Pediatrics',
        'registration_date': '2019-06-20',
        'expiry_date': '2029-06-20',
        'status': 'active',
        'data_source': 'Sample Data',
      },
      {
        'nmc_number': 'NMC34567',
        'doctor_name': 'Dr. Bikram Bahadur Rana',
        'specialization': 'Cardiology',
        'registration_date': '2021-03-10',
        'expiry_date': '2031-03-10',
        'status': 'active',
        'data_source': 'Sample Data',
      },
      {
        'nmc_number': 'NMC45678',
        'doctor_name': 'Dr. Anita Gurung',
        'specialization': 'Gynecology',
        'registration_date': '2018-09-05',
        'expiry_date': '2028-09-05',
        'status': 'active',
        'data_source': 'Sample Data',
      },
      {
        'nmc_number': 'NMC56789',
        'doctor_name': 'Dr. Krishna Shrestha',
        'specialization': 'Orthopedics',
        'registration_date': '2022-02-28',
        'expiry_date': '2032-02-28',
        'status': 'active',
        'data_source': 'Sample Data',
      },
    ];
    
    await bulkImportNMCRecords(sampleData);
  }

  /// Delete all NMC records (use with caution - for admin only)
  Future<int> deleteAllNMCRecords() async {
    try {
      final db = await _database;
      return await db.delete('nmc_verified_doctors');
    } catch (e) {
      print('Error deleting NMC records: $e');
      return 0;
    }
  }
}
