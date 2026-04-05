import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import '../sample_data_creator.dart';

class PatientAuthService {
  static const String _dbName = 'patients_auth.db';
  static const String _tableName = 'patients_auth';
  
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path;
      if (kIsWeb) {
        // For web, use sqflite_common_ffi_web
        databaseFactory = databaseFactoryFfiWeb;
        path = _dbName;
      } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        // For desktop platforms, initialize sqflite_ffi
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        path = join(await getDatabasesPath(), _dbName);
        print('Desktop platform detected, using sqflite_ffi with path: $path');
      } else {
        // For mobile platforms
        path = join(await getDatabasesPath(), _dbName);
        print('Mobile platform detected, using standard sqflite with path: $path');
      }
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_tableName (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              email TEXT UNIQUE NOT NULL,
              password_hash TEXT NOT NULL,
              full_name TEXT NOT NULL,
              phone_number TEXT,
              date_of_birth TEXT,
              gender TEXT,
              address TEXT,
              emergency_contact_name TEXT,
              emergency_contact_phone TEXT,
              created_at TEXT NOT NULL,
              last_login TEXT,
              is_active INTEGER DEFAULT 1
            )
          ''');
        },
      );
    } catch (e) {
      print('Patient database initialization error: $e');
      print('Attempting fallback database initialization...');
      
      // Fallback to in-memory database for all platforms
      try {
        if (kIsWeb) {
          databaseFactory = databaseFactoryFfiWeb;
        } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
          sqfliteFfiInit();
          databaseFactory = databaseFactoryFfi;
        }
        
        return await databaseFactory.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) async {
              print('Creating patient auth table in fallback database...');
              await db.execute('''
                CREATE TABLE $_tableName (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  email TEXT UNIQUE NOT NULL,
                  password_hash TEXT NOT NULL,
                  full_name TEXT NOT NULL,
                  phone_number TEXT,
                  date_of_birth TEXT,
                  gender TEXT,
                  address TEXT,
                  emergency_contact_name TEXT,
                  emergency_contact_phone TEXT,
                  created_at TEXT NOT NULL,
                  last_login TEXT,
                  is_active INTEGER DEFAULT 1
                )
              ''');
              print('Fallback patient auth table created successfully');
            },
          ),
        );
      } catch (fallbackError) {
        print('Fallback database initialization also failed: $fallbackError');
        rethrow;
      }
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    try {
      print('Starting patient signup for email: $email');
      final db = await database;
      print('Database connection established successfully');
      
      // Check if email already exists
      print('Checking if email already exists...');
      final existing = await db.query(
        _tableName,
        where: 'email = ?',
        whereArgs: [email],
      );
      
      if (existing.isNotEmpty) {
        print('Email $email already exists in database');
        return false; // Email already exists
      }
      print('Email is available for registration');

      // Hash password
      final passwordHash = _hashPassword(password);
      print('Password hashed successfully');
      
      // Prepare data for insertion
      final patientData = {
        'email': email,
        'password_hash': passwordHash,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'address': address,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
        'created_at': DateTime.now().toIso8601String(),
        'is_active': 1,
      };
      
      print('Inserting patient data: ${patientData.keys}');
      
      // Insert new patient
      final result = await db.insert(
        _tableName,
        patientData,
      );
      
      print('Patient inserted successfully with ID: $result');
      return true;
    } catch (e) {
      print('Patient sign up error: $e');
      print('Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final db = await database;
      
      // Hash the provided password
      final passwordHash = _hashPassword(password);
      
      // Check credentials
      final result = await db.query(
        _tableName,
        where: 'email = ? AND password_hash = ? AND is_active = 1',
        whereArgs: [email, passwordHash],
      );
      
      if (result.isNotEmpty) {
        // Update last login
        await db.update(
          _tableName,
          {'last_login': DateTime.now().toIso8601String()},
          where: 'email = ?',
          whereArgs: [email],
        );
        
        // Store patient info in preferences
        final prefs = await SharedPreferences.getInstance();
        final patientData = result.first;
        await prefs.setString('patient_id', patientData['id'].toString());
        await prefs.setString('patient_name', patientData['full_name'].toString());
        await prefs.setString('patient_email', patientData['email'].toString());
        await prefs.setString('patient_phone', patientData['phone_number']?.toString() ?? '');
        await prefs.setString('patient_dob', patientData['date_of_birth']?.toString() ?? '');
        await prefs.setString('patient_gender', patientData['gender']?.toString() ?? '');
        await prefs.setBool('is_patient_logged_in', true);
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Patient login error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getPatientProfile(String email) async {
    try {
      final db = await database;
      
      final result = await db.query(
        _tableName,
        where: 'email = ? AND is_active = 1',
        whereArgs: [email],
      );
      
      if (result.isNotEmpty) {
        return result.first;
      }
      
      return null;
    } catch (e) {
      print('Get patient profile error: $e');
      return null;
    }
  }

  Future<bool> updateProfile({
    required String email,
    required String fullName,
    String? phoneNumber,
    String? dateOfBirth,
    String? gender,
    String? address,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    try {
      final db = await database;
      
      await db.update(
        _tableName,
        {
          'full_name': fullName,
          'phone_number': phoneNumber,
          'date_of_birth': dateOfBirth,
          'gender': gender,
          'address': address,
          'emergency_contact_name': emergencyContactName,
          'emergency_contact_phone': emergencyContactPhone,
        },
        where: 'email = ?',
        whereArgs: [email],
      );
      
      // Update preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('patient_name', fullName);
      await prefs.setString('patient_phone', phoneNumber ?? '');
      await prefs.setString('patient_dob', dateOfBirth ?? '');
      await prefs.setString('patient_gender', gender ?? '');
      
      return true;
    } catch (e) {
      print('Update patient profile error: $e');
      return false;
    }
  }

  Future<bool> changePassword(String email, String currentPassword, String newPassword) async {
    try {
      final db = await database;
      
      // Verify current password
      final currentHash = _hashPassword(currentPassword);
      final result = await db.query(
        _tableName,
        where: 'email = ? AND password_hash = ?',
        whereArgs: [email, currentHash],
      );
      
      if (result.isEmpty) {
        return false; // Current password is incorrect
      }
      
      // Update password
      final newHash = _hashPassword(newPassword);
      await db.update(
        _tableName,
        {'password_hash': newHash},
        where: 'email = ?',
        whereArgs: [email],
      );
      
      return true;
    } catch (e) {
      print('Change password error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_patient_logged_in', false);
    await prefs.remove('patient_id');
    await prefs.remove('patient_name');
    await prefs.remove('patient_email');
    await prefs.remove('patient_phone');
    await prefs.remove('patient_dob');
    await prefs.remove('patient_gender');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_patient_logged_in') ?? false;
  }

  Future<String?> getLoggedInPatientEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('patient_email');
  }

  Future<String?> getLoggedInPatientId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('patient_id');
  }

  Future<Map<String, String>> getPatientInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString('patient_id') ?? '',
      'name': prefs.getString('patient_name') ?? '',
      'email': prefs.getString('patient_email') ?? '',
      'phone': prefs.getString('patient_phone') ?? '',
      'dob': prefs.getString('patient_dob') ?? '',
      'gender': prefs.getString('patient_gender') ?? '',
    };
  }

  Future<bool> createSamplePatient() async {
    try {
      final success = await signUp(
        email: 'patient@example.com',
        password: 'password123',
        fullName: 'John Doe',
        phoneNumber: '+977-9841234567',
        dateOfBirth: '1990-01-15',
        gender: 'Male',
        address: 'Kathmandu, Nepal',
        emergencyContactName: 'Jane Doe',
        emergencyContactPhone: '+977-9847654321',
      );
      
      if (success) {
        print('Sample patient created successfully: patient@example.com');
        
        // Create sample invoices for this patient
        await _createSampleInvoicesForPatient();
      }
      
      return success;
    } catch (e) {
      print('Error creating sample patient: $e');
      return false;
    }
  }
  
  Future<void> _createSampleInvoicesForPatient() async {
    try {
      // Create comprehensive sample data including patients and invoices
      print('Creating sample invoices for demo patient...');
      await SampleDataCreator.createSampleData();
      print('Sample data created successfully!');
    } catch (e) {
      print('Error creating sample invoices: $e');
    }
  }
}