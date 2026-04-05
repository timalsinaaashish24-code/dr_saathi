import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'nmc_verification_service.dart';

/// Result of a login attempt with reason for failure
class LoginResult {
  final bool success;
  final String? reason;
  LoginResult({required this.success, this.reason});
}

class AuthService {
  static const String _dbName = 'doctors.db';
  static const String _tableName = 'doctors';
  
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
      } else {
        // For mobile/desktop
        path = join(await getDatabasesPath(), _dbName);
      }
      
      return await openDatabase(
        path,
        version: 2,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_tableName (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              email TEXT UNIQUE NOT NULL,
              password_hash TEXT NOT NULL,
              name TEXT NOT NULL,
              license_number TEXT NOT NULL,
              specialization TEXT NOT NULL,
              phone TEXT,
              age INTEGER,
              gender TEXT,
              address TEXT,
              bank_name TEXT,
              bank_account_number TEXT,
              bank_branch TEXT,
              created_at TEXT NOT NULL,
              updated_at TEXT,
              is_verified INTEGER DEFAULT 0,
              last_login TEXT
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('ALTER TABLE $_tableName ADD COLUMN phone TEXT');
            await db.execute('ALTER TABLE $_tableName ADD COLUMN age INTEGER');
            await db.execute('ALTER TABLE $_tableName ADD COLUMN gender TEXT');
            await db.execute('ALTER TABLE $_tableName ADD COLUMN address TEXT');
            await db.execute('ALTER TABLE $_tableName ADD COLUMN bank_name TEXT');
            await db.execute('ALTER TABLE $_tableName ADD COLUMN bank_account_number TEXT');
            await db.execute('ALTER TABLE $_tableName ADD COLUMN bank_branch TEXT');
            await db.execute('ALTER TABLE $_tableName ADD COLUMN updated_at TEXT');
          }
        },
      );
    } catch (e) {
      print('Doctor database initialization error: $e');
      // Fallback to in-memory database
      if (kIsWeb) {
        return await databaseFactory.openDatabase(
          inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: 2,
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE $_tableName (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  email TEXT UNIQUE NOT NULL,
                  password_hash TEXT NOT NULL,
                  name TEXT NOT NULL,
                  license_number TEXT NOT NULL,
                  specialization TEXT NOT NULL,
                  phone TEXT,
                  age INTEGER,
                  gender TEXT,
                  address TEXT,
                  bank_name TEXT,
                  bank_account_number TEXT,
                  bank_branch TEXT,
                  created_at TEXT NOT NULL,
                  updated_at TEXT,
                  is_verified INTEGER DEFAULT 0,
                  last_login TEXT
                )
              ''');
            },
          ),
        );
      }
      rethrow;
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
    required String name,
    required String licenseNumber,
    required String specialization,
    String? phone,
    int? age,
    String? gender,
    String? bankName,
    String? bankAccountNumber,
    String? bankBranch,
  }) async {
    try {
      final db = await database;
      
      // Check if email already exists
      final existing = await db.query(
        _tableName,
        where: 'email = ?',
        whereArgs: [email],
      );
      
      if (existing.isNotEmpty) {
        return false; // Email already exists
      }

      // Hash password
      final passwordHash = _hashPassword(password);
      
      // Insert new doctor
      await db.insert(
        _tableName,
        {
          'email': email,
          'password_hash': passwordHash,
          'name': name,
          'license_number': licenseNumber,
          'specialization': specialization,
          'phone': phone,
          'age': age,
          'gender': gender,
          'bank_name': bankName,
          'bank_account_number': bankAccountNumber,
          'bank_branch': bankBranch,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'is_verified': 0,
        },
      );

      return true;
    } catch (e) {
      print('Sign up error: $e');
      return false;
    }
  }

  /// Login result with reason for failure
  Future<LoginResult> loginWithNMCCheck(String email, String password) async {
    try {
      final db = await database;
      
      // Hash the provided password
      final passwordHash = _hashPassword(password);
      
      // Check credentials
      final result = await db.query(
        _tableName,
        where: 'email = ? AND password_hash = ?',
        whereArgs: [email, passwordHash],
      );
      
      if (result.isEmpty) {
        return LoginResult(success: false, reason: 'Invalid email or password');
      }

      final doctorData = result.first;
      final licenseNumber = doctorData['license_number'].toString().trim().toUpperCase();

      // Verify NMC registration is still valid
      final nmcService = NMCVerificationService();
      final isNMCValid = await nmcService.verifyNMCNumber(licenseNumber);

      if (!isNMCValid) {
        // Check if NMC exists but is expired/suspended/revoked
        final nmcDetails = await nmcService.getNMCDetails(licenseNumber);
        if (nmcDetails != null) {
          final status = nmcDetails['status'] as String;
          return LoginResult(
            success: false,
            reason: 'Your NMC registration ($licenseNumber) is $status. '
                'Please renew your registration with Nepal Medical Council before logging in.',
          );
        }
        return LoginResult(
          success: false,
          reason: 'Your NMC registration number ($licenseNumber) was not found in the NMC registry. '
              'Only verified NMC-registered doctors can access the portal. '
              'Please contact admin if you believe this is an error.',
        );
      }

      // NMC valid — proceed with login
      await db.update(
        _tableName,
        {'last_login': DateTime.now().toIso8601String()},
        where: 'email = ?',
        whereArgs: [email],
      );
      
      // Store doctor info in preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('doctor_id', doctorData['id'].toString());
      await prefs.setString('doctor_name', doctorData['name'].toString());
      await prefs.setString('doctor_email', doctorData['email'].toString());
      await prefs.setString('doctor_license', doctorData['license_number'].toString());
      await prefs.setString('doctor_specialization', doctorData['specialization'].toString());
      
      return LoginResult(success: true);
    } catch (e) {
      print('Login error: $e');
      return LoginResult(success: false, reason: 'Login failed. Please try again.');
    }
  }

  /// Legacy login without NMC check (kept for backward compatibility)
  Future<bool> login(String email, String password) async {
    final result = await loginWithNMCCheck(email, password);
    return result.success;
  }

  Future<Map<String, dynamic>?> getDoctorProfile(String email) async {
    try {
      final db = await database;
      
      final result = await db.query(
        _tableName,
        where: 'email = ?',
        whereArgs: [email],
      );
      
      if (result.isNotEmpty) {
        return result.first;
      }
      
      return null;
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  Future<bool> updateProfile({
    required String email,
    required String name,
    required String licenseNumber,
    required String specialization,
  }) async {
    try {
      final db = await database;
      
      await db.update(
        _tableName,
        {
          'name': name,
          'license_number': licenseNumber,
          'specialization': specialization,
        },
        where: 'email = ?',
        whereArgs: [email],
      );
      
      // Update preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('doctor_name', name);
      await prefs.setString('doctor_license', licenseNumber);
      await prefs.setString('doctor_specialization', specialization);
      
      return true;
    } catch (e) {
      print('Update profile error: $e');
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
    await prefs.setBool('is_doctor_logged_in', false);
    await prefs.remove('doctor_id');
    await prefs.remove('doctor_name');
    await prefs.remove('doctor_email');
    await prefs.remove('doctor_license');
    await prefs.remove('doctor_specialization');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_doctor_logged_in') ?? false;
  }

  Future<String?> getLoggedInDoctorEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('doctor_email');
  }

  Future<Map<String, String>> getDoctorInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString('doctor_id') ?? '',
      'name': prefs.getString('doctor_name') ?? '',
      'email': prefs.getString('doctor_email') ?? '',
      'license': prefs.getString('doctor_license') ?? '',
      'specialization': prefs.getString('doctor_specialization') ?? '',
    };
  }
}
