import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

/// Refund status tracking
enum RefundStatus { pending, processing, completed, failed }

/// Result of a refund operation
class RefundResult {
  final bool success;
  final String? transactionId;
  final String? errorMessage;
  final RefundStatus status;

  RefundResult({
    required this.success,
    this.transactionId,
    this.errorMessage,
    required this.status,
  });
}

/// Service to process automatic bank refunds when appointments are cancelled
class RefundService {
  final DatabaseService _databaseService = DatabaseService();

  Future<Database> get _database async => await _databaseService.database;

  /// Initialize the refunds table
  Future<void> initialize() async {
    final db = await _database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS refunds (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        appointment_id INTEGER NOT NULL,
        patient_id TEXT NOT NULL,
        patient_name TEXT NOT NULL,
        patient_bank_name TEXT,
        patient_account_number TEXT,
        patient_account_name TEXT,
        amount REAL NOT NULL,
        cancellation_reason TEXT NOT NULL,
        cancelled_by TEXT NOT NULL,
        refund_status TEXT NOT NULL,
        transaction_id TEXT,
        error_message TEXT,
        created_at TEXT NOT NULL,
        processed_at TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_refunds_appointment
      ON refunds(appointment_id)
    ''');
  }

  /// Process a full refund to the patient's bank account
  /// This connects to the bank API and initiates the transfer
  Future<RefundResult> processRefund({
    required int appointmentId,
    required String patientId,
    required String patientName,
    required double amount,
    required String cancellationReason,
    required String cancelledBy,
    String? patientBankName,
    String? patientAccountNumber,
    String? patientAccountName,
  }) async {
    final db = await _database;
    final now = DateTime.now().toIso8601String();

    // 1. Create refund record as pending
    final refundId = await db.insert('refunds', {
      'appointment_id': appointmentId,
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_bank_name': patientBankName,
      'patient_account_number': patientAccountNumber,
      'patient_account_name': patientAccountName,
      'amount': amount,
      'cancellation_reason': cancellationReason,
      'cancelled_by': cancelledBy,
      'refund_status': 'processing',
      'created_at': now,
    });

    try {
      // 2. Connect to bank API and initiate refund transfer
      //    In production, this would call the actual bank API:
      //    - NIC Asia API / Nabil Bank API / Connect IPS / eSewa / Khalti
      //    - Send: amount, patient account details, reference ID
      //    - Receive: transaction ID, status
      final bankResult = await _initiateBankRefund(
        amount: amount,
        bankName: patientBankName ?? '',
        accountNumber: patientAccountNumber ?? '',
        accountName: patientAccountName ?? patientName,
        referenceId: 'REF-$appointmentId-$refundId',
      );

      // 3. Update refund record with result
      await db.update(
        'refunds',
        {
          'refund_status': bankResult.success ? 'completed' : 'failed',
          'transaction_id': bankResult.transactionId,
          'error_message': bankResult.errorMessage,
          'processed_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [refundId],
      );

      return bankResult;
    } catch (e) {
      // Mark as failed if bank connection fails
      await db.update(
        'refunds',
        {
          'refund_status': 'failed',
          'error_message': 'Bank connection error: $e',
          'processed_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [refundId],
      );

      return RefundResult(
        success: false,
        errorMessage: 'Bank connection error: $e',
        status: RefundStatus.failed,
      );
    }
  }

  /// Connect to bank and initiate refund transfer
  /// TODO: Replace with actual bank API integration (Connect IPS / eSewa / Khalti)
  Future<RefundResult> _initiateBankRefund({
    required double amount,
    required String bankName,
    required String accountNumber,
    required String accountName,
    required String referenceId,
  }) async {
    // Simulate bank API call
    // In production:
    // 1. Authenticate with bank API
    // 2. POST refund request with amount, account details
    // 3. Wait for confirmation
    // 4. Return transaction ID
    await Future.delayed(const Duration(seconds: 2));

    // Generate transaction ID (bank would provide this)
    final transactionId = 'TXN-RFD-${DateTime.now().millisecondsSinceEpoch}';

    return RefundResult(
      success: true,
      transactionId: transactionId,
      status: RefundStatus.completed,
    );
  }

  /// Get refund details for an appointment
  Future<Map<String, dynamic>?> getRefundByAppointment(int appointmentId) async {
    final db = await _database;
    final results = await db.query(
      'refunds',
      where: 'appointment_id = ?',
      whereArgs: [appointmentId],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get all refunds (for admin reporting)
  Future<List<Map<String, dynamic>>> getAllRefunds({String? status}) async {
    final db = await _database;
    if (status != null) {
      return await db.query('refunds', where: 'refund_status = ?', whereArgs: [status], orderBy: 'created_at DESC');
    }
    return await db.query('refunds', orderBy: 'created_at DESC');
  }

  /// Retry a failed refund
  Future<RefundResult> retryRefund(int refundId) async {
    final db = await _database;
    final results = await db.query('refunds', where: 'id = ?', whereArgs: [refundId]);
    if (results.isEmpty) {
      return RefundResult(success: false, errorMessage: 'Refund not found', status: RefundStatus.failed);
    }

    final refund = results.first;
    return processRefund(
      appointmentId: refund['appointment_id'] as int,
      patientId: refund['patient_id'] as String,
      patientName: refund['patient_name'] as String,
      amount: refund['amount'] as double,
      cancellationReason: refund['cancellation_reason'] as String,
      cancelledBy: refund['cancelled_by'] as String,
      patientBankName: refund['patient_bank_name'] as String?,
      patientAccountNumber: refund['patient_account_number'] as String?,
      patientAccountName: refund['patient_account_name'] as String?,
    );
  }
}
