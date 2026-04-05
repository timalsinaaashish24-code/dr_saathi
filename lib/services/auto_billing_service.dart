import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import 'invoice_service.dart';
import 'notification_service.dart';
import '../models/consultation.dart';
import '../models/invoice.dart';
import '../models/billing_item.dart';

class AutoBillingService {
  final DatabaseService _databaseService = DatabaseService();
  final InvoiceService _invoiceService = InvoiceService();
  final NotificationService _notificationService = NotificationService();

  Future<Database> get _database async => await _databaseService.database;

  /// Initialize consultations table
  Future<void> initialize() async {
    final db = await _database;
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS consultations (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        patient_name TEXT NOT NULL,
        doctor_id TEXT NOT NULL,
        doctor_name TEXT NOT NULL,
        consultation_date TEXT NOT NULL,
        consultation_type TEXT NOT NULL,
        status TEXT NOT NULL,
        consultation_fee REAL NOT NULL,
        diagnosis TEXT,
        prescription TEXT,
        notes TEXT,
        completed_at TEXT,
        bill_generated INTEGER DEFAULT 0,
        bill_id TEXT,
        FOREIGN KEY (patient_id) REFERENCES patients (id)
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_consultation_patient 
      ON consultations(patient_id)
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_consultation_status 
      ON consultations(status)
    ''');
  }

  /// Complete a consultation and automatically generate bill
  Future<String?> completeConsultationAndGenerateBill({
    required String consultationId,
    String? diagnosis,
    String? prescription,
    String? additionalNotes,
    List<BillingItem>? additionalCharges,
  }) async {
    try {
      final db = await _database;
      
      // Get consultation details
      final consultationMaps = await db.query(
        'consultations',
        where: 'id = ?',
        whereArgs: [consultationId],
      );

      if (consultationMaps.isEmpty) {
        throw Exception('Consultation not found');
      }

      final consultation = Consultation.fromMap(consultationMaps.first);
      
      if (consultation.status == 'completed') {
        throw Exception('Consultation already completed');
      }

      // Update consultation status
      await db.update(
        'consultations',
        {
          'status': 'completed',
          'completed_at': DateTime.now().toIso8601String(),
          'diagnosis': diagnosis,
          'prescription': prescription,
          'notes': additionalNotes,
        },
        where: 'id = ?',
        whereArgs: [consultationId],
      );

      // Generate bill automatically
      final billId = await _generateBillForConsultation(
        consultation: consultation,
        diagnosis: diagnosis,
        prescription: prescription,
        additionalCharges: additionalCharges,
      );

      // Update consultation with bill ID
      await db.update(
        'consultations',
        {
          'bill_generated': 1,
          'bill_id': billId,
        },
        where: 'id = ?',
        whereArgs: [consultationId],
      );

      // Send notification to patient
      await _sendBillNotificationToPatient(
        patientId: consultation.patientId,
        patientName: consultation.patientName,
        billId: billId,
        amount: consultation.consultationFee,
      );

      print('✓ Bill generated and sent: $billId');
      return billId;
    } catch (e) {
      print('Error completing consultation and generating bill: $e');
      return null;
    }
  }

  /// Generate bill for completed consultation
  Future<String> _generateBillForConsultation({
    required Consultation consultation,
    String? diagnosis,
    String? prescription,
    List<BillingItem>? additionalCharges,
  }) async {
    // Build billing items list
    final billingItems = <BillingItem>[];

    // Add consultation fee
    billingItems.add(
      BillingItem.create(
        description: 'Doctor Consultation - ${consultation.doctorName}',
        type: BillingItemType.consultation,
        quantity: 1,
        unitPrice: consultation.consultationFee,
        category: 'Consultation',
      ),
    );

    // Add additional charges if any
    if (additionalCharges != null && additionalCharges.isNotEmpty) {
      billingItems.addAll(additionalCharges);
    }

    // Calculate totals
    final subtotal = billingItems.fold<double>(
      0.0,
      (sum, item) => sum + item.total,
    );

    final vatAmount = subtotal * 0.13; // 13% VAT in Nepal
    final totalAmount = subtotal + vatAmount;

    // Create invoice using the service's generateInvoice method
    final invoice = await _invoiceService.generateInvoice(
      patientId: consultation.patientId,
      patientName: consultation.patientName,
      doctorId: consultation.doctorId,
      doctorName: consultation.doctorName,
      items: billingItems,
      vatRate: 13.0,
      taxRate: 0.0,
      notes: 'Consultation Date: ${consultation.consultationDate.toString().split(' ')[0]}\n'
          '${diagnosis != null ? 'Diagnosis: $diagnosis\n' : ''}'
          '${prescription != null ? 'Prescription: $prescription\n' : ''}'
          'Payment due within 30 days.',
    );

    return invoice.id;
  }

  /// Generate unique invoice number
  String _generateInvoiceNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final timestamp = now.millisecondsSinceEpoch.toString().substring(8);
    
    return 'DS-$year$month$day-$timestamp';
  }

  /// Send bill notification to patient
  Future<void> _sendBillNotificationToPatient({
    required String patientId,
    required String patientName,
    required String billId,
    required double amount,
  }) async {
    try {
      // Get patient phone number
      final db = await _database;
      final patientMaps = await db.query(
        'patients',
        columns: ['phone_number', 'email'],
        where: 'id = ?',
        whereArgs: [patientId],
      );

      if (patientMaps.isEmpty) return;

      final phoneNumber = patientMaps.first['phone_number'] as String?;
      final email = patientMaps.first['email'] as String?;

      // Send SMS notification
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        await _notificationService.sendSMSNotification(
          phoneNumber,
          'Dear $patientName, your consultation bill #${billId.substring(0, 15)} for NPR ${amount.toStringAsFixed(2)} has been generated. Visit Dr. Saathi app to view and pay.',
        );
      }

      // Send email notification (if email available)
      if (email != null && email.isNotEmpty) {
        await _notificationService.sendEmailNotification(
          email,
          'Dr. Saathi - Consultation Bill Generated',
          _buildBillEmailBody(
            patientName: patientName,
            billId: billId,
            amount: amount,
          ),
        );
      }

      print('✓ Notifications sent to patient: $patientName');
    } catch (e) {
      print('Error sending bill notification: $e');
    }
  }

  String _buildBillEmailBody({
    required String patientName,
    required String billId,
    required double amount,
  }) {
    return '''
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background-color: #03A9F4; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; background-color: #f9f9f9; }
        .bill-info { background-color: white; padding: 15px; margin: 15px 0; border-left: 4px solid #03A9F4; }
        .footer { text-align: center; padding: 20px; color: #666; }
        .button { background-color: #03A9F4; color: white; padding: 12px 30px; text-decoration: none; display: inline-block; border-radius: 5px; margin: 15px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Dr. Saathi</h1>
            <p>Your Health Partner</p>
        </div>
        
        <div class="content">
            <h2>Dear $patientName,</h2>
            
            <p>Your recent consultation has been completed successfully.</p>
            
            <div class="bill-info">
                <h3>Bill Details</h3>
                <p><strong>Bill ID:</strong> $billId</p>
                <p><strong>Amount:</strong> NPR ${amount.toStringAsFixed(2)}</p>
                <p><strong>Due Date:</strong> ${DateTime.now().add(const Duration(days: 30)).toString().split(' ')[0]}</p>
            </div>
            
            <p>You can view and pay your bill through the Dr. Saathi mobile app.</p>
            
            <center>
                <a href="#" class="button">View Bill in App</a>
            </center>
            
            <p>If you have any questions, please contact our support team.</p>
        </div>
        
        <div class="footer">
            <p>Thank you for choosing Dr. Saathi</p>
            <p>© 2026 Dr. Saathi. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
    ''';
  }

  /// Create a new consultation
  Future<String> createConsultation({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required DateTime consultationDate,
    required String consultationType,
    required double consultationFee,
  }) async {
    try {
      final db = await _database;
      final consultationId = 'CONS-${DateTime.now().millisecondsSinceEpoch}';

      final consultation = Consultation(
        id: consultationId,
        patientId: patientId,
        patientName: patientName,
        doctorId: doctorId,
        doctorName: doctorName,
        consultationDate: consultationDate,
        consultationType: consultationType,
        status: 'scheduled',
        consultationFee: consultationFee,
      );

      await db.insert('consultations', consultation.toMap());
      print('✓ Consultation created: $consultationId');
      return consultationId;
    } catch (e) {
      print('Error creating consultation: $e');
      rethrow;
    }
  }

  /// Get consultation by ID
  Future<Consultation?> getConsultation(String consultationId) async {
    try {
      final db = await _database;
      final maps = await db.query(
        'consultations',
        where: 'id = ?',
        whereArgs: [consultationId],
      );

      if (maps.isEmpty) return null;
      return Consultation.fromMap(maps.first);
    } catch (e) {
      print('Error getting consultation: $e');
      return null;
    }
  }

  /// Get all consultations for a patient
  Future<List<Consultation>> getPatientConsultations(String patientId) async {
    try {
      final db = await _database;
      final maps = await db.query(
        'consultations',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'consultation_date DESC',
      );

      return maps.map((map) => Consultation.fromMap(map)).toList();
    } catch (e) {
      print('Error getting patient consultations: $e');
      return [];
    }
  }

  /// Get pending consultations (scheduled or ongoing)
  Future<List<Consultation>> getPendingConsultations() async {
    try {
      final db = await _database;
      final maps = await db.query(
        'consultations',
        where: 'status IN (?, ?)',
        whereArgs: ['scheduled', 'ongoing'],
        orderBy: 'consultation_date ASC',
      );

      return maps.map((map) => Consultation.fromMap(map)).toList();
    } catch (e) {
      print('Error getting pending consultations: $e');
      return [];
    }
  }

  /// Update consultation status
  Future<void> updateConsultationStatus(
    String consultationId,
    String status,
  ) async {
    try {
      final db = await _database;
      await db.update(
        'consultations',
        {'status': status},
        where: 'id = ?',
        whereArgs: [consultationId],
      );
    } catch (e) {
      print('Error updating consultation status: $e');
    }
  }
}
