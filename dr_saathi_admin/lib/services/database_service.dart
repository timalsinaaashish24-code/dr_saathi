import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      // Initialize database factory
      if (kIsWeb) {
        // For web, use sqflite_common_ffi_web for IndexedDB support
        databaseFactory = databaseFactoryFfiWeb;
        return await databaseFactory.openDatabase('dr_saathi_admin.db',
          options: OpenDatabaseOptions(
            version: 3,
            onCreate: _createDatabase,
            onUpgrade: _upgradeDatabase,
          ),
        );
      } else if (Platform.isWindows || Platform.isLinux) {
        // Initialize FFI for desktop platforms
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      
      String path = join(await getDatabasesPath(), 'dr_saathi_admin.db');
      return await openDatabase(
        path,
        version: 3,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );
    } catch (e) {
      print('Database initialization error: $e');
      // Fallback to in-memory database if web setup fails
      if (kIsWeb) {
        return await databaseFactory.openDatabase(inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: 3,
            onCreate: _createDatabase,
            onUpgrade: _upgradeDatabase,
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create bank transfer table
    await db.execute('''
      CREATE TABLE bank_transfers (
        id TEXT PRIMARY KEY,
        patientId TEXT NOT NULL,
        appointmentId TEXT,
        invoiceId TEXT,
        amount REAL NOT NULL,
        senderBankName TEXT NOT NULL,
        senderAccountName TEXT NOT NULL,
        senderAccountNumber TEXT NOT NULL,
        receiverBankName TEXT NOT NULL,
        receiverAccountNumber TEXT NOT NULL,
        transactionId TEXT,
        transactionDate TEXT NOT NULL,
        transactionProofPath TEXT,
        status INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        verifiedAt TEXT,
        verifiedBy TEXT,
        rejectionReason TEXT,
        remarks TEXT
      )
    ''');
    
    // Create doctor payments table
    await db.execute('''
      CREATE TABLE doctor_payments (
        id TEXT PRIMARY KEY,
        doctorId TEXT NOT NULL,
        appointmentId TEXT,
        invoiceId TEXT,
        patientPaymentId TEXT,
        totalAmount REAL NOT NULL,
        platformCommission REAL NOT NULL,
        platformCommissionRate REAL NOT NULL,
        doctorAmount REAL NOT NULL,
        taxDeducted REAL NOT NULL,
        taxRate REAL NOT NULL,
        netPayable REAL NOT NULL,
        status INTEGER NOT NULL,
        paymentMethod TEXT,
        bankName TEXT,
        accountNumber TEXT,
        accountName TEXT,
        transactionId TEXT,
        transactionProof TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        scheduledAt TEXT,
        completedAt TEXT,
        processedBy TEXT,
        failureReason TEXT,
        remarks TEXT
      )
    ''');
    
    // Create feedback table
    await db.execute('''
      CREATE TABLE feedback (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        userName TEXT NOT NULL,
        userType TEXT NOT NULL,
        subject TEXT NOT NULL,
        message TEXT NOT NULL,
        category TEXT NOT NULL,
        rating INTEGER NOT NULL,
        status TEXT NOT NULL,
        response TEXT,
        respondedBy TEXT,
        createdAt TEXT NOT NULL,
        respondedAt TEXT,
        userEmail TEXT,
        userPhone TEXT
      )
    ''');

    // Operations monitoring tables
    await _createOperationsTables(db);
  }

  Future<void> _createOperationsTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS clinical_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        appointmentId TEXT,
        patientId TEXT,
        doctorId TEXT,
        eventType TEXT NOT NULL,
        waitTimeMinutes REAL,
        consultationCompleted INTEGER,
        noShow INTEGER DEFAULT 0,
        timeToTreatmentHours REAL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS technical_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        callId TEXT,
        callSucceeded INTEGER,
        callDropped INTEGER DEFAULT 0,
        audioOnly INTEGER DEFAULT 0,
        bitrateKbps REAL,
        region TEXT,
        connectionType TEXT,
        latencyMs REAL,
        crashOccurred INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS compliance_audit_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        userName TEXT,
        role TEXT,
        action TEXT NOT NULL,
        resource TEXT,
        authorized INTEGER DEFAULT 1,
        consentValid INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_clinical_created ON clinical_events(createdAt)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_technical_created ON technical_events(createdAt)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_audit_created ON compliance_audit_log(createdAt)');
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add feedback table
      await db.execute('''
        CREATE TABLE feedback (
          id TEXT PRIMARY KEY,
          userId TEXT NOT NULL,
          userName TEXT NOT NULL,
          userType TEXT NOT NULL,
          subject TEXT NOT NULL,
          message TEXT NOT NULL,
          category TEXT NOT NULL,
          rating INTEGER NOT NULL,
          status TEXT NOT NULL,
          response TEXT,
          respondedBy TEXT,
          createdAt TEXT NOT NULL,
          respondedAt TEXT,
          userEmail TEXT,
          userPhone TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      await _createOperationsTables(db);
    }
  }
}
