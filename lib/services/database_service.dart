import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../models/patient.dart';
import '../models/sms_reminder.dart';
import '../models/prescription.dart';

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
        return await databaseFactory.openDatabase('dr_saathi.db',
          options: OpenDatabaseOptions(
            version: 8,
            onCreate: _createDatabase,
            onUpgrade: _upgradeDatabase,
          ),
        );
      } else if (Platform.isWindows || Platform.isLinux) {
        // Initialize FFI for desktop platforms
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      
      String path = join(await getDatabasesPath(), 'dr_saathi.db');
      return await openDatabase(
        path,
        version: 8,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );
    } catch (e) {
      print('Database initialization error: $e');
      // Fallback to in-memory database if web setup fails
      if (kIsWeb) {
        return await databaseFactory.openDatabase(inMemoryDatabasePath,
          options: OpenDatabaseOptions(
            version: 8,
            onCreate: _createDatabase,
            onUpgrade: _upgradeDatabase,
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients(
        id TEXT PRIMARY KEY,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        dateOfBirth TEXT,
        age INTEGER NOT NULL,
        phoneNumber TEXT NOT NULL,
        email TEXT,
        address TEXT,
        emergencyContact TEXT,
        medicalHistory TEXT,
        allergies TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patientId TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (patientId) REFERENCES patients (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sms_reminders(
        id TEXT PRIMARY KEY,
        patientId TEXT NOT NULL,
        patientName TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        message TEXT NOT NULL,
        scheduledTime TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        errorMessage TEXT,
        retryCount INTEGER DEFAULT 0,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (patientId) REFERENCES patients (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sms_templates(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        template TEXT NOT NULL,
        type TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE prescriptions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT NOT NULL,
        doctor_name TEXT NOT NULL,
        doctor_id TEXT NOT NULL,
        prescription_date TEXT NOT NULL,
        diagnosis TEXT NOT NULL,
        notes TEXT,
        status TEXT NOT NULL,
        follow_up_date TEXT,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE medications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        prescription_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        frequency TEXT NOT NULL,
        duration TEXT NOT NULL,
        instructions TEXT,
        form TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        generic_name TEXT,
        is_generic INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (prescription_id) REFERENCES prescriptions (id)
      )
    ''');

    // Create invoice tables
    await db.execute('''
      CREATE TABLE invoices (
        id TEXT PRIMARY KEY,
        invoice_number TEXT UNIQUE NOT NULL,
        patient_id TEXT NOT NULL,
        patient_name TEXT NOT NULL,
        doctor_id TEXT NOT NULL,
        doctor_name TEXT NOT NULL,
        invoice_date TEXT NOT NULL,
        due_date TEXT NOT NULL,
        subtotal REAL NOT NULL,
        vat_rate REAL NOT NULL,
        vat_amount REAL NOT NULL,
        tax_rate REAL NOT NULL,
        tax_amount REAL NOT NULL,
        total_amount REAL NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        paid_at TEXT,
        payment_method TEXT,
        payment_reference TEXT,
        FOREIGN KEY (patient_id) REFERENCES patients (id)
      )
    ''');
    
    await db.execute('''
      CREATE TABLE billing_items (
        id TEXT PRIMARY KEY,
        invoice_id TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit_price REAL NOT NULL,
        total_amount REAL NOT NULL,
        category TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (invoice_id) REFERENCES invoices (id)
      )
    ''');
    
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
    
    // Create doctor bank accounts table
    await db.execute('''
      CREATE TABLE doctor_bank_accounts (
        id TEXT PRIMARY KEY,
        doctorId TEXT NOT NULL,
        bankName TEXT NOT NULL,
        accountName TEXT NOT NULL,
        accountNumber TEXT NOT NULL,
        branchName TEXT,
        swiftCode TEXT,
        isVerified INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        verifiedAt TEXT,
        verifiedBy TEXT
      )
    ''');
    
    // Create analytics tables
    await db.execute('''
      CREATE TABLE user_activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        activityType TEXT NOT NULL,
        activityData TEXT,
        timestamp TEXT NOT NULL
      )
    ''');
    
    await db.execute('''
      CREATE INDEX idx_user_activities_timestamp ON user_activities(timestamp)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_user_activities_userId ON user_activities(userId)
    ''');
    
    await db.execute('''
      CREATE TABLE user_registrations (
        id TEXT PRIMARY KEY,
        userId TEXT UNIQUE NOT NULL,
        userType TEXT NOT NULL,
        registrationDate TEXT NOT NULL,
        platform TEXT NOT NULL,
        deviceInfo TEXT,
        appVersion TEXT,
        isActive INTEGER NOT NULL DEFAULT 1,
        lastActiveAt TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE sms_reminders(
          id TEXT PRIMARY KEY,
          patientId TEXT NOT NULL,
          patientName TEXT NOT NULL,
          phoneNumber TEXT NOT NULL,
          message TEXT NOT NULL,
          scheduledTime TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          type TEXT NOT NULL,
          status TEXT NOT NULL,
          errorMessage TEXT,
          retryCount INTEGER DEFAULT 0,
          synced INTEGER DEFAULT 0,
          FOREIGN KEY (patientId) REFERENCES patients (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE sms_templates(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          template TEXT NOT NULL,
          type TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');
    }
    
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE prescriptions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          patient_id TEXT NOT NULL,
          doctor_name TEXT NOT NULL,
          doctor_id TEXT NOT NULL,
          prescription_date TEXT NOT NULL,
          diagnosis TEXT NOT NULL,
          notes TEXT,
          status TEXT NOT NULL,
          follow_up_date TEXT,
          is_synced INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (patient_id) REFERENCES patients (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE medications(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          prescription_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          dosage TEXT NOT NULL,
          frequency TEXT NOT NULL,
          duration TEXT NOT NULL,
          instructions TEXT,
          form TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          generic_name TEXT,
          is_generic INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (prescription_id) REFERENCES prescriptions (id)
        )
      ''');
    }
    
    if (oldVersion < 6) {
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
    }
    
    if (oldVersion < 7) {
      // Create doctor bank accounts table
      await db.execute('''
        CREATE TABLE doctor_bank_accounts (
          id TEXT PRIMARY KEY,
          doctorId TEXT NOT NULL,
          bankName TEXT NOT NULL,
          accountName TEXT NOT NULL,
          accountNumber TEXT NOT NULL,
          branchName TEXT,
          swiftCode TEXT,
          isVerified INTEGER NOT NULL DEFAULT 0,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          verifiedAt TEXT,
          verifiedBy TEXT
        )
      ''');
    }
    
    if (oldVersion < 8) {
      // Create user activities table for analytics
      await db.execute('''
        CREATE TABLE user_activities (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT NOT NULL,
          activityType TEXT NOT NULL,
          activityData TEXT,
          timestamp TEXT NOT NULL
        )
      ''');
      
      // Create index for faster queries
      await db.execute('''
        CREATE INDEX idx_user_activities_timestamp ON user_activities(timestamp)
      ''');
      
      await db.execute('''
        CREATE INDEX idx_user_activities_userId ON user_activities(userId)
      ''');
      
      // Create user registrations table
      await db.execute('''
        CREATE TABLE user_registrations (
          id TEXT PRIMARY KEY,
          userId TEXT UNIQUE NOT NULL,
          userType TEXT NOT NULL,
          registrationDate TEXT NOT NULL,
          platform TEXT NOT NULL,
          deviceInfo TEXT,
          appVersion TEXT,
          isActive INTEGER NOT NULL DEFAULT 1,
          lastActiveAt TEXT,
          createdAt TEXT NOT NULL
        )
      ''');
    }
  }

  // Patient CRUD operations
  Future<String> insertPatient(Patient patient) async {
    final db = await database;
    await db.insert(
      'patients',
      patient.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Add to sync queue if not already synced
    if (!patient.synced) {
      await _addToSyncQueue(patient.id, 'INSERT', patient.toMap());
    }
    
    return patient.id;
  }

  Future<List<Patient>> getAllPatients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('patients', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => Patient.fromMap(maps[i]));
  }

  Future<Patient?> getPatientById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Patient.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updatePatient(Patient patient) async {
    final db = await database;
    await db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
    
    // Add to sync queue if not already synced
    if (!patient.synced) {
      await _addToSyncQueue(patient.id, 'UPDATE', patient.toMap());
    }
  }

  Future<void> deletePatient(String id) async {
    final db = await database;
    await db.delete(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    // Add to sync queue
    await _addToSyncQueue(id, 'DELETE', null);
  }

  Future<List<Patient>> getUnsyncedPatients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'synced = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) => Patient.fromMap(maps[i]));
  }

  Future<void> markPatientAsSynced(String id) async {
    final db = await database;
    await db.update(
      'patients',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Sync queue operations
  Future<void> _addToSyncQueue(String patientId, String operation, Map<String, dynamic>? data) async {
    final db = await database;
    await db.insert('sync_queue', {
      'patientId': patientId,
      'operation': operation,
        'data': data?.toString(),
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return await db.query('sync_queue', orderBy: 'createdAt ASC');
  }

  Future<void> clearSyncQueue() async {
    final db = await database;
    await db.delete('sync_queue');
  }

  Future<void> removeSyncQueueItem(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  // Search patients
  Future<List<Patient>> searchPatients(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patients',
      where: 'firstName LIKE ? OR lastName LIKE ? OR phoneNumber LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Patient.fromMap(maps[i]));
  }

  // SMS Reminder CRUD operations
  Future<String> insertSmsReminder(SmsReminder reminder) async {
    final db = await database;
    await db.insert(
      'sms_reminders',
      reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return reminder.id;
  }

  Future<List<SmsReminder>> getAllSmsReminders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sms_reminders',
      orderBy: 'scheduledTime DESC',
    );
    return List.generate(maps.length, (i) => SmsReminder.fromMap(maps[i]));
  }

  Future<List<SmsReminder>> getPendingReminders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sms_reminders',
      where: 'status = ?',
      whereArgs: [SmsReminderStatus.pending.toString()],
      orderBy: 'scheduledTime ASC',
    );
    return List.generate(maps.length, (i) => SmsReminder.fromMap(maps[i]));
  }

  Future<List<SmsReminder>> getOverdueReminders() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'sms_reminders',
      where: 'status = ? AND scheduledTime < ?',
      whereArgs: [SmsReminderStatus.pending.toString(), now],
      orderBy: 'scheduledTime ASC',
    );
    return List.generate(maps.length, (i) => SmsReminder.fromMap(maps[i]));
  }

  Future<List<SmsReminder>> getPatientReminders(String patientId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sms_reminders',
      where: 'patientId = ?',
      whereArgs: [patientId],
      orderBy: 'scheduledTime DESC',
    );
    return List.generate(maps.length, (i) => SmsReminder.fromMap(maps[i]));
  }

  Future<void> updateSmsReminderStatus(
    String reminderId,
    SmsReminderStatus status, {
    String? errorMessage,
  }) async {
    final db = await database;
    await db.update(
      'sms_reminders',
      {
        'status': status.toString(),
        'errorMessage': errorMessage,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [reminderId],
    );
  }

  Future<void> deleteSmsReminder(String reminderId) async {
    final db = await database;
    await db.delete(
      'sms_reminders',
      where: 'id = ?',
      whereArgs: [reminderId],
    );
  }

  Future<Map<String, int>> getReminderStats() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        status,
        COUNT(*) as count
      FROM sms_reminders 
      GROUP BY status
    ''');
    
    Map<String, int> stats = {
      'pending': 0,
      'sent': 0,
      'failed': 0,
      'cancelled': 0,
    };
    
    for (final row in result) {
      final status = row['status'].toString().split('.').last;
      stats[status] = row['count'] as int;
    }
    
    return stats;
  }

  // SMS Template CRUD operations
  Future<String> insertSmsTemplate(SmsTemplate template) async {
    final db = await database;
    await db.insert(
      'sms_templates',
      template.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return template.id;
  }

  Future<List<SmsTemplate>> getAllSmsTemplates() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sms_templates',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => SmsTemplate.fromMap(maps[i]));
  }

  Future<List<SmsTemplate>> getSmsTemplatesByType(SmsReminderType type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sms_templates',
      where: 'type = ?',
      whereArgs: [type.toString()],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => SmsTemplate.fromMap(maps[i]));
  }

  Future<SmsTemplate?> getSmsTemplateById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sms_templates',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return SmsTemplate.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateSmsTemplate(SmsTemplate template) async {
    final db = await database;
    await db.update(
      'sms_templates',
      template.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  Future<void> deleteSmsTemplate(String templateId) async {
    final db = await database;
    await db.delete(
      'sms_templates',
      where: 'id = ?',
      whereArgs: [templateId],
    );
  }

  // Prescription CRUD operations
  Future<int> insertPrescription(Prescription prescription) async {
    final db = await database;
    
    // Insert prescription
    final prescriptionId = await db.insert(
      'prescriptions',
      prescription.toDatabaseJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Insert medications
    for (final medication in prescription.medications) {
      await db.insert(
        'medications',
        medication.copyWith(prescriptionId: prescriptionId).toDatabaseJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    return prescriptionId;
  }

  Future<List<Prescription>> getAllPrescriptions() async {
    final db = await database;
    final List<Map<String, dynamic>> prescriptionMaps = await db.query(
      'prescriptions',
      orderBy: 'prescription_date DESC',
    );
    
    List<Prescription> prescriptions = [];
    for (final prescriptionMap in prescriptionMaps) {
      final prescription = Prescription.fromDatabaseJson(prescriptionMap);
      final medications = await getMedicationsByPrescriptionId(prescription.id!);
      prescriptions.add(prescription.copyWith(medications: medications));
    }
    
    return prescriptions;
  }

  Future<List<Prescription>> getPrescriptionsByPatientId(String patientId) async {
    final db = await database;
    final List<Map<String, dynamic>> prescriptionMaps = await db.query(
      'prescriptions',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'prescription_date DESC',
    );
    
    List<Prescription> prescriptions = [];
    for (final prescriptionMap in prescriptionMaps) {
      final prescription = Prescription.fromDatabaseJson(prescriptionMap);
      final medications = await getMedicationsByPrescriptionId(prescription.id!);
      prescriptions.add(prescription.copyWith(medications: medications));
    }
    
    return prescriptions;
  }

  Future<Prescription?> getPrescriptionById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> prescriptionMaps = await db.query(
      'prescriptions',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (prescriptionMaps.isNotEmpty) {
      final prescription = Prescription.fromDatabaseJson(prescriptionMaps.first);
      final medications = await getMedicationsByPrescriptionId(id);
      return prescription.copyWith(medications: medications);
    }
    
    return null;
  }

  Future<void> updatePrescription(Prescription prescription) async {
    final db = await database;
    
    // Update prescription
    await db.update(
      'prescriptions',
      prescription.toDatabaseJson(),
      where: 'id = ?',
      whereArgs: [prescription.id],
    );
    
    // Delete existing medications
    await db.delete(
      'medications',
      where: 'prescription_id = ?',
      whereArgs: [prescription.id],
    );
    
    // Insert updated medications
    for (final medication in prescription.medications) {
      await db.insert(
        'medications',
        medication.copyWith(prescriptionId: prescription.id).toDatabaseJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> deletePrescription(int id) async {
    final db = await database;
    
    // Delete medications first
    await db.delete(
      'medications',
      where: 'prescription_id = ?',
      whereArgs: [id],
    );
    
    // Delete prescription
    await db.delete(
      'prescriptions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updatePrescriptionStatus(int id, String status) async {
    final db = await database;
    await db.update(
      'prescriptions',
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Medication operations
  Future<List<Medication>> getMedicationsByPrescriptionId(int prescriptionId) async {
    final db = await database;
    final List<Map<String, dynamic>> medicationMaps = await db.query(
      'medications',
      where: 'prescription_id = ?',
      whereArgs: [prescriptionId],
      orderBy: 'created_at ASC',
    );
    
    return List.generate(
      medicationMaps.length,
      (i) => Medication.fromDatabaseJson(medicationMaps[i]),
    );
  }

  Future<List<Prescription>> getActivePrescriptions() async {
    final db = await database;
    final List<Map<String, dynamic>> prescriptionMaps = await db.query(
      'prescriptions',
      where: 'status = ?',
      whereArgs: ['active'],
      orderBy: 'prescription_date DESC',
    );
    
    List<Prescription> prescriptions = [];
    for (final prescriptionMap in prescriptionMaps) {
      final prescription = Prescription.fromDatabaseJson(prescriptionMap);
      final medications = await getMedicationsByPrescriptionId(prescription.id!);
      prescriptions.add(prescription.copyWith(medications: medications));
    }
    
    return prescriptions;
  }

  Future<List<Prescription>> getUnsyncedPrescriptions() async {
    final db = await database;
    final List<Map<String, dynamic>> prescriptionMaps = await db.query(
      'prescriptions',
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'created_at DESC',
    );
    
    List<Prescription> prescriptions = [];
    for (final prescriptionMap in prescriptionMaps) {
      final prescription = Prescription.fromDatabaseJson(prescriptionMap);
      final medications = await getMedicationsByPrescriptionId(prescription.id!);
      prescriptions.add(prescription.copyWith(medications: medications));
    }
    
    return prescriptions;
  }

  Future<void> markPrescriptionAsSynced(int id) async {
    final db = await database;
    await db.update(
      'prescriptions',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, int>> getPrescriptionStats() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        status,
        COUNT(*) as count
      FROM prescriptions 
      GROUP BY status
    ''');
    
    Map<String, int> stats = {
      'active': 0,
      'completed': 0,
      'cancelled': 0,
    };
    
    for (final row in result) {
      final status = row['status'] as String;
      stats[status] = row['count'] as int;
    }
    
    return stats;
  }

  // Search prescriptions
  Future<List<Prescription>> searchPrescriptions(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> prescriptionMaps = await db.rawQuery('''
      SELECT DISTINCT p.* FROM prescriptions p
      LEFT JOIN medications m ON p.id = m.prescription_id
      WHERE p.diagnosis LIKE ? OR p.notes LIKE ? OR m.name LIKE ?
      ORDER BY p.prescription_date DESC
    ''', ['%$query%', '%$query%', '%$query%']);
    
    List<Prescription> prescriptions = [];
    for (final prescriptionMap in prescriptionMaps) {
      final prescription = Prescription.fromDatabaseJson(prescriptionMap);
      final medications = await getMedicationsByPrescriptionId(prescription.id!);
      prescriptions.add(prescription.copyWith(medications: medications));
    }
    
    return prescriptions;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // Add sample patients for testing
  Future<void> addSamplePatients() async {
    final db = await database;
    final patients = [
      Patient(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        dateOfBirth: DateTime(1988, 5, 15), // 35 years old
        phoneNumber: '1234567890',
        email: 'john.doe@example.com',
        address: '123 Main St, Anytown, USA',
        emergencyContact: 'Jane Doe (555-555-5555)',
        medicalHistory: 'Hypertension',
        allergies: 'Peanuts',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        synced: false,
      ),
      Patient(
        id: '2',
        firstName: 'Jane',
        lastName: 'Smith',
        dateOfBirth: DateTime(1995, 8, 22), // 28 years old
        phoneNumber: '0987654321',
        email: 'jane.smith@example.com',
        address: '456 Oak Ave, Anytown, USA',
        emergencyContact: 'John Smith (555-555-5555)',
        medicalHistory: 'Asthma',
        allergies: 'None',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        synced: false,
      ),
    ];

    for (final patient in patients) {
      await db.insert(
        'patients',
        patient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
