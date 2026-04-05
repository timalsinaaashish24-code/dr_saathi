import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import 'refund_service.dart';

/// Status of a held payment
enum HoldStatus { held, released, refunded, expired }

/// Service that holds patient payments for 24 hours before releasing to doctor.
/// If the user cancels within 24 hours, the money is refunded instantly
/// from the held funds — no need to wait for admin approval.
class PaymentHoldService {
  static const int holdDurationHours = 24;
  final DatabaseService _databaseService = DatabaseService();

  Future<Database> get _database async => await _databaseService.database;

  /// Initialize the payment_holds table
  Future<void> initialize() async {
    final db = await _database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS payment_holds (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        appointment_id INTEGER NOT NULL,
        patient_id TEXT NOT NULL,
        patient_name TEXT NOT NULL,
        patient_bank_name TEXT,
        patient_account_number TEXT,
        patient_account_name TEXT,
        doctor_id TEXT NOT NULL,
        amount REAL NOT NULL,
        hold_status TEXT NOT NULL DEFAULT 'held',
        held_at TEXT NOT NULL,
        release_at TEXT NOT NULL,
        released_at TEXT,
        refunded_at TEXT,
        refund_transaction_id TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_holds_appointment ON payment_holds(appointment_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_holds_status ON payment_holds(hold_status)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_holds_release ON payment_holds(release_at)');
  }

  /// Hold a patient's payment for 24 hours after booking
  /// Called when patient completes payment for an appointment
  Future<int> holdPayment({
    required int appointmentId,
    required String patientId,
    required String patientName,
    required String doctorId,
    required double amount,
    String? patientBankName,
    String? patientAccountNumber,
    String? patientAccountName,
  }) async {
    final db = await _database;
    final now = DateTime.now();
    final releaseAt = now.add(const Duration(hours: holdDurationHours));

    return await db.insert('payment_holds', {
      'appointment_id': appointmentId,
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_bank_name': patientBankName,
      'patient_account_number': patientAccountNumber,
      'patient_account_name': patientAccountName,
      'doctor_id': doctorId,
      'amount': amount,
      'hold_status': 'held',
      'held_at': now.toIso8601String(),
      'release_at': releaseAt.toIso8601String(),
      'created_at': now.toIso8601String(),
    });
  }

  /// Check if a payment is still on hold (within 24 hours)
  Future<bool> isPaymentOnHold(int appointmentId) async {
    final db = await _database;
    final results = await db.query(
      'payment_holds',
      where: 'appointment_id = ? AND hold_status = ?',
      whereArgs: [appointmentId, 'held'],
    );

    if (results.isEmpty) return false;

    final releaseAt = DateTime.parse(results.first['release_at'] as String);
    return DateTime.now().isBefore(releaseAt);
  }

  /// Get hold details for an appointment
  Future<Map<String, dynamic>?> getHoldByAppointment(int appointmentId) async {
    final db = await _database;
    final results = await db.query(
      'payment_holds',
      where: 'appointment_id = ?',
      whereArgs: [appointmentId],
      orderBy: 'created_at DESC',
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// Get remaining hold time for an appointment
  Future<Duration?> getRemainingHoldTime(int appointmentId) async {
    final hold = await getHoldByAppointment(appointmentId);
    if (hold == null || hold['hold_status'] != 'held') return null;

    final releaseAt = DateTime.parse(hold['release_at'] as String);
    final remaining = releaseAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Refund from held funds — instant, no bank API delay needed
  /// because the money hasn't left the platform yet
  Future<RefundResult> refundFromHold({
    required int appointmentId,
    required String cancellationReason,
    required String cancelledBy,
  }) async {
    final db = await _database;
    final hold = await getHoldByAppointment(appointmentId);

    if (hold == null) {
      return RefundResult(
        success: false,
        errorMessage: 'No payment hold found for this appointment',
        status: RefundStatus.failed,
      );
    }

    if (hold['hold_status'] != 'held') {
      // Payment already released to doctor — need bank refund
      return _refundViaBank(hold, cancellationReason, cancelledBy);
    }

    final releaseAt = DateTime.parse(hold['release_at'] as String);
    final now = DateTime.now();

    if (now.isBefore(releaseAt)) {
      // Within 24 hours — instant refund from held funds
      final txnId = 'HOLD-RFD-${now.millisecondsSinceEpoch}';

      await db.update(
        'payment_holds',
        {
          'hold_status': 'refunded',
          'refunded_at': now.toIso8601String(),
          'refund_transaction_id': txnId,
        },
        where: 'id = ?',
        whereArgs: [hold['id']],
      );

      // Record the refund
      final refundService = RefundService();
      await refundService.initialize();
      await refundService.processRefund(
        appointmentId: appointmentId,
        patientId: hold['patient_id'] as String,
        patientName: hold['patient_name'] as String,
        amount: hold['amount'] as double,
        cancellationReason: cancellationReason,
        cancelledBy: cancelledBy,
        patientBankName: hold['patient_bank_name'] as String?,
        patientAccountNumber: hold['patient_account_number'] as String?,
        patientAccountName: hold['patient_account_name'] as String?,
      );

      return RefundResult(
        success: true,
        transactionId: txnId,
        status: RefundStatus.completed,
      );
    } else {
      // Past 24 hours — payment should have been released, refund via bank
      return _refundViaBank(hold, cancellationReason, cancelledBy);
    }
  }

  /// Refund via bank API when payment has already been released
  Future<RefundResult> _refundViaBank(
    Map<String, dynamic> hold,
    String cancellationReason,
    String cancelledBy,
  ) async {
    final refundService = RefundService();
    await refundService.initialize();
    return await refundService.processRefund(
      appointmentId: hold['appointment_id'] as int,
      patientId: hold['patient_id'] as String,
      patientName: hold['patient_name'] as String,
      amount: hold['amount'] as double,
      cancellationReason: cancellationReason,
      cancelledBy: cancelledBy,
      patientBankName: hold['patient_bank_name'] as String?,
      patientAccountNumber: hold['patient_account_number'] as String?,
      patientAccountName: hold['patient_account_name'] as String?,
    );
  }

  /// Release payments that have passed the 24-hour hold period
  /// This should be called periodically (e.g., every hour via WorkManager)
  /// Once released, money is transferred to the doctor
  Future<int> releaseExpiredHolds() async {
    final db = await _database;
    final now = DateTime.now().toIso8601String();

    return await db.update(
      'payment_holds',
      {
        'hold_status': 'released',
        'released_at': now,
      },
      where: 'hold_status = ? AND release_at <= ?',
      whereArgs: ['held', now],
    );
  }

  /// Get all currently held payments (for admin dashboard)
  Future<List<Map<String, dynamic>>> getActiveHolds() async {
    final db = await _database;
    return await db.query(
      'payment_holds',
      where: 'hold_status = ?',
      whereArgs: ['held'],
      orderBy: 'release_at ASC',
    );
  }

  /// Get hold statistics
  Future<Map<String, dynamic>> getHoldStats() async {
    final db = await _database;

    final heldResult = await db.rawQuery(
      "SELECT COUNT(*) as count, COALESCE(SUM(amount), 0) as total FROM payment_holds WHERE hold_status = 'held'"
    );
    final releasedResult = await db.rawQuery(
      "SELECT COUNT(*) as count, COALESCE(SUM(amount), 0) as total FROM payment_holds WHERE hold_status = 'released'"
    );
    final refundedResult = await db.rawQuery(
      "SELECT COUNT(*) as count, COALESCE(SUM(amount), 0) as total FROM payment_holds WHERE hold_status = 'refunded'"
    );

    return {
      'held_count': heldResult.first['count'],
      'held_amount': heldResult.first['total'],
      'released_count': releasedResult.first['count'],
      'released_amount': releasedResult.first['total'],
      'refunded_count': refundedResult.first['count'],
      'refunded_amount': refundedResult.first['total'],
    };
  }
}
