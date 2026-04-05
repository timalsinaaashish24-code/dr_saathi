import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/patient.dart';
import '../models/prescription.dart';
import '../models/doctor.dart';
import '../models/pharmacy.dart';
import 'database_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  static const String _baseUrl = 'https://api.drsaathi.com/v1'; // Dr. Saathi API endpoint
  static const String _syncStatusKey = 'last_sync_timestamp';
  static const String _offlineModeKey = 'offline_mode';
  
  // Callbacks for UI updates
  Function(String)? onSyncStatusChanged;
  Function(double)? onSyncProgress;
  Function(String)? onSyncError;
  
  final DatabaseService _databaseService = DatabaseService();
  Timer? _syncTimer;
  bool _isSyncing = false;
  
  SyncService._internal();
  
  factory SyncService() {
    return _instance;
  }
  
  /// Start automatic sync every 5 minutes when online
  void startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      syncPendingChanges();
    });
  }
  
  /// Stop automatic sync
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }
  
  /// Check if device is online
  Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }
  
  /// Sync all pending changes with server
  Future<bool> syncPendingChanges() async {
    if (_isSyncing) return false;
    
    final online = await isOnline();
    if (!online) {
      onSyncStatusChanged?.call('Offline - sync pending');
      return false;
    }
    
    _isSyncing = true;
    onSyncStatusChanged?.call('Syncing...');
    onSyncProgress?.call(0.0);
    
    try {
      // Sync patients
      onSyncStatusChanged?.call('Syncing patients...');
      await _syncAllPatients();
      onSyncProgress?.call(0.25);
      
      // Sync prescriptions
      onSyncStatusChanged?.call('Syncing prescriptions...');
      await _syncAllPrescriptions();
      onSyncProgress?.call(0.5);
      
      // Sync deliveries
      onSyncStatusChanged?.call('Syncing deliveries...');
      await syncPrescriptionDeliveries();
      onSyncProgress?.call(0.75);
      
      // Sync doctors and pharmacies
      onSyncStatusChanged?.call('Syncing healthcare providers...');
      await _syncHealthcareProviders();
      onSyncProgress?.call(1.0);
      
      // Update last sync timestamp
      await _updateLastSyncTimestamp();
      onSyncStatusChanged?.call('Sync completed');
      
      return true;
    } catch (e) {
      print('Sync error: $e');
      onSyncError?.call('Sync failed: $e');
      onSyncStatusChanged?.call('Sync failed');
      return false;
    } finally {
      _isSyncing = false;
      onSyncProgress?.call(0.0);
    }
  }
  
  /// Sync a single patient with server
  Future<bool> _syncPatient(Patient patient) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/patients'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode(patient.toMap()),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error syncing patient ${patient.id}: $e');
      return false;
    }
  }
  
  /// Process a sync queue item
  Future<bool> _processSyncQueueItem(Map<String, dynamic> queueItem) async {
    try {
      final operation = queueItem['operation'];
      final patientId = queueItem['patientId'];
      
      switch (operation) {
        case 'INSERT':
          return await _syncPatientToServer(patientId, 'POST');
        case 'UPDATE':
          return await _syncPatientToServer(patientId, 'PUT');
        case 'DELETE':
          return await _deletePatientFromServer(patientId);
        default:
          return false;
      }
    } catch (e) {
      print('Error processing sync queue item: $e');
      return false;
    }
  }
  
  /// Sync patient to server with specific HTTP method
  Future<bool> _syncPatientToServer(String patientId, String method) async {
    try {
      final patient = await _databaseService.getPatientById(patientId);
      if (patient == null) return false;
      
      final url = method == 'POST' 
          ? '$_baseUrl/patients'
          : '$_baseUrl/patients/${patient.id}';
      
      final uri = Uri.parse(url);
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _getAuthToken()}',
      };
      final body = jsonEncode(patient.toMap());
      
      final response = method == 'POST'
          ? await http.post(uri, headers: headers, body: body)
          : await http.put(uri, headers: headers, body: body);
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error syncing patient $patientId: $e');
      return false;
    }
  }
  
  /// Delete patient from server
  Future<bool> _deletePatientFromServer(String patientId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/patients/$patientId'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting patient $patientId: $e');
      return false;
    }
  }
  
  /// Download patients from server
  Future<List<Patient>> downloadPatientsFromServer() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/patients'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Patient.fromMap(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error downloading patients: $e');
      return [];
    }
  }
  
  /// Full sync - download all patients from server and merge with local data
  Future<bool> fullSync() async {
    if (!await isOnline()) return false;
    
    try {
      // First, sync local changes to server
      await syncPendingChanges();
      
      // Then download all patients from server
      final serverPatients = await downloadPatientsFromServer();
      
      for (final patient in serverPatients) {
        // Check if patient exists locally
        final localPatient = await _databaseService.getPatientById(patient.id);
        
        if (localPatient == null) {
          // New patient from server, insert locally
          await _databaseService.insertPatient(patient.copyWith(synced: true));
        } else {
          // Patient exists, check if server version is newer
          if (patient.updatedAt.isAfter(localPatient.updatedAt)) {
            await _databaseService.updatePatient(patient.copyWith(synced: true));
          }
        }
      }
      
      await _updateLastSyncTimestamp();
      return true;
    } catch (e) {
      print('Full sync error: $e');
      return false;
    }
  }
  
  /// Get authentication token (implement based on your auth system)
  Future<String> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }
  
  /// Update last sync timestamp
  Future<void> _updateLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_syncStatusKey, DateTime.now().toIso8601String());
  }
  
  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestampString = prefs.getString(_syncStatusKey);
    return timestampString != null ? DateTime.parse(timestampString) : null;
  }
  
  /// Check if sync is needed (based on last sync time)
  Future<bool> isSyncNeeded() async {
    final lastSync = await getLastSyncTimestamp();
    if (lastSync == null) return true;
    
    // Sync if last sync was more than 1 hour ago
    return DateTime.now().difference(lastSync).inHours > 1;
  }
  
  /// Get sync status
  Future<Map<String, dynamic>> getSyncStatus() async {
    final unsyncedPatients = await _databaseService.getUnsyncedPatients();
    final syncQueue = await _databaseService.getSyncQueue();
    final lastSync = await getLastSyncTimestamp();
    final online = await isOnline();
    
    return {
      'isOnline': online,
      'isSyncing': _isSyncing,
      'unsyncedCount': unsyncedPatients.length,
      'queueCount': syncQueue.length,
      'lastSyncTime': lastSync?.toIso8601String(),
      'syncNeeded': await isSyncNeeded(),
    };
  }
  
  /// Force sync now
  Future<bool> forceSyncNow() async {
    if (!await isOnline()) return false;
    return await syncPendingChanges();
  }
  
  /// Clear all sync data (for testing or reset)
  Future<void> clearSyncData() async {
    await _databaseService.clearSyncQueue();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_syncStatusKey);
  }
  
  /// Sync prescription deliveries with server
  Future<bool> syncPrescriptionDeliveries() async {
    if (!await isOnline()) return false;
    
    try {
      // Get unsynced deliveries from database
      final db = await _databaseService.database;
      final result = await db.query(
        'prescription_deliveries',
        where: 'is_synced = ?',
        whereArgs: [0],
      );
      
      for (final delivery in result) {
        final success = await _syncDeliveryToServer(delivery);
        if (success) {
          // Mark as synced
          await db.update(
            'prescription_deliveries',
            {'is_synced': 1},
            where: 'id = ?',
            whereArgs: [delivery['id']],
          );
        }
      }
      
      return true;
    } catch (e) {
      print('Error syncing prescription deliveries: $e');
      return false;
    }
  }
  
  /// Sync individual delivery to server
  Future<bool> _syncDeliveryToServer(Map<String, dynamic> delivery) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/prescription-deliveries'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode(delivery),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error syncing delivery ${delivery['id']}: $e');
      return false;
    }
  }
  
  /// Sync all patients
  Future<bool> _syncAllPatients() async {
    try {
      final db = await _databaseService.database;
      final result = await db.query(
        'patients',
        where: 'is_synced = ?',
        whereArgs: [0],
      );
      
      for (final patientData in result) {
        final patient = Patient.fromDatabaseJson(patientData);
        final success = await _syncPatient(patient);
        if (success) {
          await db.update(
            'patients',
            {'is_synced': 1, 'updated_at': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [patient.id],
          );
        }
      }
      
      return true;
    } catch (e) {
      print('Error syncing patients: $e');
      return false;
    }
  }
  
  /// Sync all prescriptions
  Future<bool> _syncAllPrescriptions() async {
    try {
      final db = await _databaseService.database;
      final result = await db.query(
        'prescriptions',
        where: 'is_synced = ?',
        whereArgs: [0],
      );
      
      for (final prescriptionData in result) {
        final success = await _syncPrescriptionToServer(prescriptionData);
        if (success) {
          await db.update(
            'prescriptions',
            {'is_synced': 1, 'updated_at': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [prescriptionData['id']],
          );
        }
      }
      
      return true;
    } catch (e) {
      print('Error syncing prescriptions: $e');
      return false;
    }
  }
  
  /// Sync individual prescription to server
  Future<bool> _syncPrescriptionToServer(Map<String, dynamic> prescription) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/prescriptions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
        body: jsonEncode(prescription),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error syncing prescription ${prescription['id']}: $e');
      return false;
    }
  }
  
  /// Sync healthcare providers (doctors and pharmacies)
  Future<bool> _syncHealthcareProviders() async {
    try {
      // Download latest doctors
      await _downloadDoctors();
      
      // Download latest pharmacies
      await _downloadPharmacies();
      
      return true;
    } catch (e) {
      print('Error syncing healthcare providers: $e');
      return false;
    }
  }
  
  /// Download doctors from server
  Future<bool> _downloadDoctors() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/doctors'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final db = await _databaseService.database;
        
        for (final doctorData in data) {
          await db.insert(
            'doctors',
            doctorData,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
      
      return true;
    } catch (e) {
      print('Error downloading doctors: $e');
      return false;
    }
  }
  
  /// Download pharmacies from server
  Future<bool> _downloadPharmacies() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/pharmacies'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final db = await _databaseService.database;
        
        for (final pharmacyData in data) {
          await db.insert(
            'pharmacies',
            pharmacyData,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
      
      return true;
    } catch (e) {
      print('Error downloading pharmacies: $e');
      return false;
    }
  }
  
  /// Enable offline mode
  Future<void> setOfflineMode(bool offline) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineModeKey, offline);
    
    if (offline) {
      stopAutoSync();
      onSyncStatusChanged?.call('Offline mode enabled');
    } else {
      startAutoSync();
      onSyncStatusChanged?.call('Online mode enabled');
    }
  }
  
  /// Check if offline mode is enabled
  Future<bool> isOfflineModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_offlineModeKey) ?? false;
  }
  
  /// Get detailed sync statistics
  Future<Map<String, dynamic>> getSyncStatistics() async {
    final db = await _databaseService.database;
    
    // Count unsynced items
    final unsyncedPatients = await db.query(
      'patients', 
      where: 'is_synced = ?', 
      whereArgs: [0]
    );
    
    final unsyncedPrescriptions = await db.query(
      'prescriptions', 
      where: 'is_synced = ?', 
      whereArgs: [0]
    );
    
    final unsyncedDeliveries = await db.query(
      'prescription_deliveries', 
      where: 'is_synced = ?', 
      whereArgs: [0]
    );
    
    // Total counts
    final totalPatients = await db.query('patients');
    final totalPrescriptions = await db.query('prescriptions');
    final totalDeliveries = await db.query('prescription_deliveries');
    
    return {
      'lastSync': await getLastSyncTimestamp(),
      'isOnline': await isOnline(),
      'isOfflineMode': await isOfflineModeEnabled(),
      'isSyncing': _isSyncing,
      'syncNeeded': await isSyncNeeded(),
      'unsynced': {
        'patients': unsyncedPatients.length,
        'prescriptions': unsyncedPrescriptions.length,
        'deliveries': unsyncedDeliveries.length,
      },
      'total': {
        'patients': totalPatients.length,
        'prescriptions': totalPrescriptions.length,
        'deliveries': totalDeliveries.length,
      },
    };
  }
}
