import 'dart:convert';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import '../models/prescription.dart';
import '../models/patient.dart';
import 'database_service.dart';
import 'notification_service.dart';

class DigitalPrescriptionService {
  static const String _prescriptionsTable = 'digital_prescriptions';
  static const String _medicationsTable = 'prescription_medications';
  static const String _prescriptionHistoryTable = 'prescription_history';
  
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  Future<void> initializeTables() async {
    final db = await _databaseService.database;
    
    // Create digital prescriptions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_prescriptionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        patient_id TEXT NOT NULL,
        patient_name TEXT NOT NULL,
        patient_phone TEXT,
        doctor_name TEXT NOT NULL,
        doctor_id TEXT NOT NULL,
        doctor_license_number TEXT,
        prescription_date TEXT NOT NULL,
        diagnosis TEXT NOT NULL,
        symptoms TEXT,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'draft',
        follow_up_date TEXT,
        sent_date TEXT,
        dispensed_date TEXT,
        pharmacy_id TEXT,
        pharmacy_name TEXT,
        qr_code TEXT,
        digital_signature TEXT,
        is_urgent INTEGER DEFAULT 0,
        is_synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create prescription medications table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_medicationsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        prescription_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        frequency TEXT NOT NULL,
        duration TEXT NOT NULL,
        instructions TEXT,
        form TEXT DEFAULT 'tablet',
        quantity INTEGER NOT NULL,
        generic_name TEXT,
        is_generic INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (prescription_id) REFERENCES $_prescriptionsTable (id)
      )
    ''');

    // Create prescription history table for tracking status changes
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_prescriptionHistoryTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        prescription_id INTEGER NOT NULL,
        status TEXT NOT NULL,
        changed_by TEXT NOT NULL,
        changed_by_type TEXT NOT NULL, -- 'doctor', 'patient', 'pharmacy'
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (prescription_id) REFERENCES $_prescriptionsTable (id)
      )
    ''');
  }

  // Create a new prescription
  Future<Prescription> createPrescription({
    required String patientId,
    required String patientName,
    String? patientPhone,
    required String doctorName,
    required String doctorId,
    String? doctorLicenseNumber,
    required String diagnosis,
    String? symptoms,
    String? notes,
    List<Medication>? medications,
    DateTime? followUpDate,
    bool isUrgent = false,
  }) async {
    final now = DateTime.now();
    final prescription = Prescription(
      patientId: patientId,
      patientName: patientName,
      patientPhone: patientPhone,
      doctorName: doctorName,
      doctorId: doctorId,
      doctorLicenseNumber: doctorLicenseNumber,
      prescriptionDate: now,
      diagnosis: diagnosis,
      symptoms: symptoms,
      notes: notes ?? '',
      medications: medications ?? [],
      followUpDate: followUpDate,
      isUrgent: isUrgent,
      createdAt: now,
      updatedAt: now,
    );

    final db = await _databaseService.database;
    final id = await db.insert(_prescriptionsTable, prescription.toDatabaseJson());
    
    return prescription.copyWith(id: id);
  }

  // Add medication to prescription
  Future<void> addMedicationToPrescription(int prescriptionId, Medication medication) async {
    final db = await _databaseService.database;
    
    final medicationWithPrescriptionId = medication.copyWith(
      prescriptionId: prescriptionId,
      updatedAt: DateTime.now(),
    );
    
    await db.insert(_medicationsTable, medicationWithPrescriptionId.toDatabaseJson());
    
    // Update prescription updated_at
    await _updatePrescriptionTimestamp(prescriptionId);
  }

  // Remove medication from prescription
  Future<void> removeMedicationFromPrescription(int prescriptionId, int medicationId) async {
    final db = await _databaseService.database;
    
    await db.delete(
      _medicationsTable,
      where: 'id = ? AND prescription_id = ?',
      whereArgs: [medicationId, prescriptionId],
    );
    
    // Update prescription updated_at
    await _updatePrescriptionTimestamp(prescriptionId);
  }

  // Update medication in prescription
  Future<void> updateMedicationInPrescription(Medication medication) async {
    final db = await _databaseService.database;
    
    final updatedMedication = medication.copyWith(updatedAt: DateTime.now());
    
    await db.update(
      _medicationsTable,
      updatedMedication.toDatabaseJson(),
      where: 'id = ?',
      whereArgs: [medication.id],
    );
    
    if (medication.prescriptionId != null) {
      await _updatePrescriptionTimestamp(medication.prescriptionId!);
    }
  }

  // Get prescription with medications
  Future<Prescription?> getPrescription(int prescriptionId) async {
    final db = await _databaseService.database;
    
    final prescriptionMaps = await db.query(
      _prescriptionsTable,
      where: 'id = ?',
      whereArgs: [prescriptionId],
    );
    
    if (prescriptionMaps.isEmpty) return null;
    
    final prescription = Prescription.fromDatabaseJson(prescriptionMaps.first);
    
    // Load medications
    final medicationMaps = await db.query(
      _medicationsTable,
      where: 'prescription_id = ?',
      whereArgs: [prescriptionId],
      orderBy: 'created_at ASC',
    );
    
    final medications = medicationMaps
        .map((map) => Medication.fromDatabaseJson(map))
        .toList();
    
    return prescription.copyWith(medications: medications);
  }

  // Get all prescriptions for a doctor
  Future<List<Prescription>> getPrescriptionsByDoctor(String doctorId) async {
    final db = await _databaseService.database;
    
    final prescriptionMaps = await db.query(
      _prescriptionsTable,
      where: 'doctor_id = ?',
      whereArgs: [doctorId],
      orderBy: 'created_at DESC',
    );
    
    final prescriptions = <Prescription>[];
    
    for (final map in prescriptionMaps) {
      final prescription = Prescription.fromDatabaseJson(map);
      
      // Load medications for each prescription
      final medicationMaps = await db.query(
        _medicationsTable,
        where: 'prescription_id = ?',
        whereArgs: [prescription.id],
        orderBy: 'created_at ASC',
      );
      
      final medications = medicationMaps
          .map((medMap) => Medication.fromDatabaseJson(medMap))
          .toList();
      
      prescriptions.add(prescription.copyWith(medications: medications));
    }
    
    return prescriptions;
  }

  // Get all prescriptions for a patient
  Future<List<Prescription>> getPrescriptionsByPatient(String patientId) async {
    final db = await _databaseService.database;
    
    final prescriptionMaps = await db.query(
      _prescriptionsTable,
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'created_at DESC',
    );
    
    final prescriptions = <Prescription>[];
    
    for (final map in prescriptionMaps) {
      final prescription = Prescription.fromDatabaseJson(map);
      
      // Load medications for each prescription
      final medicationMaps = await db.query(
        _medicationsTable,
        where: 'prescription_id = ?',
        whereArgs: [prescription.id],
        orderBy: 'created_at ASC',
      );
      
      final medications = medicationMaps
          .map((medMap) => Medication.fromDatabaseJson(medMap))
          .toList();
      
      prescriptions.add(prescription.copyWith(medications: medications));
    }
    
    return prescriptions;
  }

  // Send prescription to patient
  Future<bool> sendPrescriptionToPatient(int prescriptionId, {String? customMessage}) async {
    try {
      final prescription = await getPrescription(prescriptionId);
      if (prescription == null) return false;
      
      if (!prescription.canSend) return false;
      
      // Generate QR code and digital signature
      final qrCode = _generateQRCode(prescription);
      final digitalSignature = _generateDigitalSignature(prescription);
      
      // Update prescription status
      final updatedPrescription = prescription.copyWith(
        status: PrescriptionStatus.sent,
        sentDate: DateTime.now(),
        qrCode: qrCode,
        digitalSignature: digitalSignature,
        updatedAt: DateTime.now(),
      );
      
      await _updatePrescription(updatedPrescription);
      
      // Add to history
      await _addPrescriptionHistory(
        prescriptionId,
        PrescriptionStatus.sent,
        prescription.doctorId,
        'doctor',
        'Prescription sent to patient',
      );
      
      // Send notification to patient
      await _notificationService.sendPrescriptionNotification(
        recipientId: prescription.patientId,
        recipientType: 'patient',
        prescriptionId: prescriptionId,
        title: 'New Prescription Received',
        message: customMessage ?? 'You have received a new prescription from Dr. ${prescription.doctorName}',
        doctorName: prescription.doctorName,
      );
      
      return true;
    } catch (e) {
      print('Error sending prescription to patient: $e');
      return false;
    }
  }

  // Send prescription to pharmacy
  Future<bool> sendPrescriptionToPharmacy(
    int prescriptionId,
    String pharmacyId,
    String pharmacyName, {
    String? customMessage,
  }) async {
    try {
      final prescription = await getPrescription(prescriptionId);
      if (prescription == null) return false;
      
      // Update prescription with pharmacy details
      final updatedPrescription = prescription.copyWith(
        pharmacyId: pharmacyId,
        pharmacyName: pharmacyName,
        status: PrescriptionStatus.received,
        updatedAt: DateTime.now(),
      );
      
      await _updatePrescription(updatedPrescription);
      
      // Add to history
      await _addPrescriptionHistory(
        prescriptionId,
        PrescriptionStatus.received,
        prescription.patientId,
        'patient',
        'Prescription forwarded to pharmacy: $pharmacyName',
      );
      
      // Send notification to pharmacy
      await _notificationService.sendPrescriptionNotification(
        recipientId: pharmacyId,
        recipientType: 'pharmacy',
        prescriptionId: prescriptionId,
        title: 'New Prescription to Process',
        message: customMessage ?? 'New prescription received from ${prescription.patientName}',
        doctorName: prescription.doctorName,
        patientName: prescription.patientName,
      );
      
      return true;
    } catch (e) {
      print('Error sending prescription to pharmacy: $e');
      return false;
    }
  }

  // Mark prescription as dispensed (used by pharmacy)
  Future<bool> markPrescriptionDispensed(int prescriptionId, String pharmacyId) async {
    try {
      final prescription = await getPrescription(prescriptionId);
      if (prescription == null) return false;
      
      if (prescription.pharmacyId != pharmacyId) return false;
      
      final updatedPrescription = prescription.copyWith(
        status: PrescriptionStatus.dispensed,
        dispensedDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _updatePrescription(updatedPrescription);
      
      // Add to history
      await _addPrescriptionHistory(
        prescriptionId,
        PrescriptionStatus.dispensed,
        pharmacyId,
        'pharmacy',
        'Prescription dispensed to patient',
      );
      
      // Send notification to patient
      await _notificationService.sendPrescriptionNotification(
        recipientId: prescription.patientId,
        recipientType: 'patient',
        prescriptionId: prescriptionId,
        title: 'Prescription Ready',
        message: 'Your prescription has been prepared and is ready for pickup at ${prescription.pharmacyName}',
        pharmacyName: prescription.pharmacyName,
      );
      
      // Send notification to doctor
      await _notificationService.sendPrescriptionNotification(
        recipientId: prescription.doctorId,
        recipientType: 'doctor',
        prescriptionId: prescriptionId,
        title: 'Prescription Dispensed',
        message: 'Prescription for ${prescription.patientName} has been dispensed at ${prescription.pharmacyName}',
        patientName: prescription.patientName,
        pharmacyName: prescription.pharmacyName,
      );
      
      return true;
    } catch (e) {
      print('Error marking prescription as dispensed: $e');
      return false;
    }
  }

  // Cancel prescription
  Future<bool> cancelPrescription(int prescriptionId, String cancelledBy, String reason) async {
    try {
      final prescription = await getPrescription(prescriptionId);
      if (prescription == null) return false;
      
      if (!prescription.canCancel) return false;
      
      final updatedPrescription = prescription.copyWith(
        status: PrescriptionStatus.cancelled,
        updatedAt: DateTime.now(),
      );
      
      await _updatePrescription(updatedPrescription);
      
      // Add to history
      await _addPrescriptionHistory(
        prescriptionId,
        PrescriptionStatus.cancelled,
        cancelledBy,
        'doctor', // or determine type based on cancelledBy
        'Prescription cancelled: $reason',
      );
      
      return true;
    } catch (e) {
      print('Error cancelling prescription: $e');
      return false;
    }
  }

  // Get prescription history
  Future<List<Map<String, dynamic>>> getPrescriptionHistory(int prescriptionId) async {
    final db = await _databaseService.database;
    
    return await db.query(
      _prescriptionHistoryTable,
      where: 'prescription_id = ?',
      whereArgs: [prescriptionId],
      orderBy: 'created_at DESC',
    );
  }

  // Search prescriptions
  Future<List<Prescription>> searchPrescriptions(String query, {String? doctorId, String? patientId}) async {
    final db = await _databaseService.database;
    
    String whereClause = '''
      (patient_name LIKE ? OR doctor_name LIKE ? OR diagnosis LIKE ?)
    ''';
    List<dynamic> whereArgs = ['%$query%', '%$query%', '%$query%'];
    
    if (doctorId != null) {
      whereClause += ' AND doctor_id = ?';
      whereArgs.add(doctorId);
    }
    
    if (patientId != null) {
      whereClause += ' AND patient_id = ?';
      whereArgs.add(patientId);
    }
    
    final prescriptionMaps = await db.query(
      _prescriptionsTable,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    
    final prescriptions = <Prescription>[];
    
    for (final map in prescriptionMaps) {
      final prescription = Prescription.fromDatabaseJson(map);
      
      // Load medications for each prescription
      final medicationMaps = await db.query(
        _medicationsTable,
        where: 'prescription_id = ?',
        whereArgs: [prescription.id],
        orderBy: 'created_at ASC',
      );
      
      final medications = medicationMaps
          .map((medMap) => Medication.fromDatabaseJson(medMap))
          .toList();
      
      prescriptions.add(prescription.copyWith(medications: medications));
    }
    
    return prescriptions;
  }

  // Private helper methods
  Future<void> _updatePrescription(Prescription prescription) async {
    final db = await _databaseService.database;
    
    await db.update(
      _prescriptionsTable,
      prescription.toDatabaseJson(),
      where: 'id = ?',
      whereArgs: [prescription.id],
    );
  }

  Future<void> _updatePrescriptionTimestamp(int prescriptionId) async {
    final db = await _databaseService.database;
    
    await db.update(
      _prescriptionsTable,
      {'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [prescriptionId],
    );
  }

  Future<void> _addPrescriptionHistory(
    int prescriptionId,
    PrescriptionStatus status,
    String changedBy,
    String changedByType,
    String? notes,
  ) async {
    final db = await _databaseService.database;
    
    await db.insert(_prescriptionHistoryTable, {
      'prescription_id': prescriptionId,
      'status': status.toString().split('.').last,
      'changed_by': changedBy,
      'changed_by_type': changedByType,
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  String _generateQRCode(Prescription prescription) {
    // Generate a unique QR code for the prescription
    final data = '${prescription.id}-${prescription.doctorId}-${prescription.patientId}-${DateTime.now().millisecondsSinceEpoch}';
    return base64Encode(utf8.encode(data));
  }

  String _generateDigitalSignature(Prescription prescription) {
    // Generate a digital signature for the prescription
    final data = '${prescription.id}${prescription.doctorId}${prescription.patientId}${prescription.diagnosis}${prescription.prescriptionDate.toIso8601String()}';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Get prescriptions by pharmacy (for pharmacy portal)
  Future<List<Prescription>> getPrescriptionsByPharmacy(String pharmacyId) async {
    final db = await _databaseService.database;
    
    final prescriptionMaps = await db.query(
      _prescriptionsTable,
      where: 'pharmacy_id = ? AND status IN (?, ?)',
      whereArgs: [pharmacyId, 'received', 'dispensed'],
      orderBy: 'created_at DESC',
    );
    
    final prescriptions = <Prescription>[];
    
    for (final map in prescriptionMaps) {
      final prescription = Prescription.fromDatabaseJson(map);
      
      // Load medications for each prescription
      final medicationMaps = await db.query(
        _medicationsTable,
        where: 'prescription_id = ?',
        whereArgs: [prescription.id],
        orderBy: 'created_at ASC',
      );
      
      final medications = medicationMaps
          .map((medMap) => Medication.fromDatabaseJson(medMap))
          .toList();
      
      prescriptions.add(prescription.copyWith(medications: medications));
    }
    
    return prescriptions;
  }

  // Delete prescription (only drafts can be deleted)
  Future<bool> deletePrescription(int prescriptionId) async {
    try {
      final prescription = await getPrescription(prescriptionId);
      if (prescription == null || prescription.status != PrescriptionStatus.draft) {
        return false;
      }

      final db = await _databaseService.database;
      
      // Delete medications first (foreign key constraint)
      await db.delete(
        _medicationsTable,
        where: 'prescription_id = ?',
        whereArgs: [prescriptionId],
      );
      
      // Delete prescription history
      await db.delete(
        _prescriptionHistoryTable,
        where: 'prescription_id = ?',
        whereArgs: [prescriptionId],
      );
      
      // Delete prescription
      await db.delete(
        _prescriptionsTable,
        where: 'id = ?',
        whereArgs: [prescriptionId],
      );
      
      return true;
    } catch (e) {
      print('Error deleting prescription: $e');
      return false;
    }
  }
}
