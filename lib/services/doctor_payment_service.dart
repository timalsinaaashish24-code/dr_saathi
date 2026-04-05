/*
 * Dr. Saathi - Doctor Payment Distribution Service
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/doctor_payment.dart';
import '../services/database_service.dart';

class DoctorPaymentService {
  static const String tableName = 'doctor_payments';
  final CommissionConfig commissionConfig;

  DoctorPaymentService({
    CommissionConfig? config,
  }) : commissionConfig = config ?? const CommissionConfig();

  // Initialize database table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        id TEXT PRIMARY KEY,
        doctorId TEXT NOT NULL,
        appointmentId TEXT,
        invoiceId TEXT,
        patientPaymentId TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        platformCommission REAL NOT NULL,
        platformCommissionRate REAL NOT NULL,
        doctorAmount REAL NOT NULL,
        taxDeducted REAL NOT NULL,
        netPayable REAL NOT NULL,
        status INTEGER NOT NULL,
        paymentMethod INTEGER NOT NULL,
        doctorBankName TEXT,
        doctorAccountNumber TEXT,
        doctorAccountName TEXT,
        transactionId TEXT,
        transactionProof TEXT,
        paymentDate TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        processedAt TEXT,
        completedAt TEXT,
        processedBy TEXT,
        failureReason TEXT,
        remarks TEXT
      )
    ''');

    // Create indexes
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_doctor_payments_doctor 
      ON $tableName(doctorId)
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_doctor_payments_status 
      ON $tableName(status)
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_doctor_payments_patient_payment 
      ON $tableName(patientPaymentId)
    ''');
  }

  // Create doctor payment when patient payment is verified
  Future<DoctorPayment> createDoctorPayment({
    required String doctorId,
    required String patientPaymentId,
    required double totalAmount,
    String? appointmentId,
    String? invoiceId,
    required String doctorBankName,
    required String doctorAccountNumber,
    required String doctorAccountName,
    PaymentMethod paymentMethod = PaymentMethod.bankTransfer,
  }) async {
    final db = await DatabaseService().database;

    // Calculate amounts
    final commission = commissionConfig.calculateCommission(totalAmount);
    final doctorAmount = totalAmount - commission;
    final tax = commissionConfig.calculateTax(doctorAmount);
    final netPayable = doctorAmount - tax;

    final payment = DoctorPayment(
      id: const Uuid().v4(),
      doctorId: doctorId,
      appointmentId: appointmentId,
      invoiceId: invoiceId,
      patientPaymentId: patientPaymentId,
      totalAmount: totalAmount,
      platformCommission: commission,
      platformCommissionRate: commissionConfig.defaultRate,
      doctorAmount: doctorAmount,
      taxDeducted: tax,
      netPayable: netPayable,
      status: PaymentStatus.pending,
      paymentMethod: paymentMethod,
      doctorBankName: doctorBankName,
      doctorAccountNumber: doctorAccountNumber,
      doctorAccountName: doctorAccountName,
      paymentDate: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await db.insert(
      tableName,
      payment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return payment;
  }

  // Get payment by ID
  Future<DoctorPayment?> getPaymentById(String id) async {
    final db = await DatabaseService().database;
    final results = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return DoctorPayment.fromMap(results.first);
  }

  // Get all payments for a doctor
  Future<List<DoctorPayment>> getPaymentsByDoctor(String doctorId) async {
    final db = await DatabaseService().database;
    final results = await db.query(
      tableName,
      where: 'doctorId = ?',
      whereArgs: [doctorId],
      orderBy: 'createdAt DESC',
    );

    return results.map((map) => DoctorPayment.fromMap(map)).toList();
  }

  // Get payments by status
  Future<List<DoctorPayment>> getPaymentsByStatus(PaymentStatus status) async {
    final db = await DatabaseService().database;
    final results = await db.query(
      tableName,
      where: 'status = ?',
      whereArgs: [status.index],
      orderBy: 'createdAt DESC',
    );

    return results.map((map) => DoctorPayment.fromMap(map)).toList();
  }

  // Get pending payments (to be processed)
  Future<List<DoctorPayment>> getPendingPayments() async {
    return getPaymentsByStatus(PaymentStatus.pending);
  }

  // Mark payment as processing
  Future<DoctorPayment> markAsProcessing(
    String paymentId,
    String processedBy,
  ) async {
    final db = await DatabaseService().database;
    final payment = await getPaymentById(paymentId);
    
    if (payment == null) {
      throw Exception('Payment not found');
    }

    final updated = payment.copyWith(
      status: PaymentStatus.processing,
      processedAt: DateTime.now(),
      processedBy: processedBy,
    );

    await db.update(
      tableName,
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [paymentId],
    );

    return updated;
  }

  // Mark payment as completed
  Future<DoctorPayment> markAsCompleted(
    String paymentId,
    String transactionId, {
    String? transactionProof,
  }) async {
    final db = await DatabaseService().database;
    final payment = await getPaymentById(paymentId);
    
    if (payment == null) {
      throw Exception('Payment not found');
    }

    final updated = payment.copyWith(
      status: PaymentStatus.completed,
      transactionId: transactionId,
      transactionProof: transactionProof,
      completedAt: DateTime.now(),
    );

    await db.update(
      tableName,
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [paymentId],
    );

    return updated;
  }

  // Mark payment as failed
  Future<DoctorPayment> markAsFailed(
    String paymentId,
    String failureReason,
  ) async {
    final db = await DatabaseService().database;
    final payment = await getPaymentById(paymentId);
    
    if (payment == null) {
      throw Exception('Payment not found');
    }

    final updated = payment.copyWith(
      status: PaymentStatus.failed,
      failureReason: failureReason,
      completedAt: DateTime.now(),
    );

    await db.update(
      tableName,
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [paymentId],
    );

    return updated;
  }

  // Get doctor earnings statistics
  Future<Map<String, dynamic>> getDoctorEarningStats(String doctorId) async {
    final db = await DatabaseService().database;
    
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count, SUM(netPayable) as total FROM $tableName WHERE doctorId = ?',
      [doctorId]
    );
    
    final completedResult = await db.rawQuery(
      'SELECT COUNT(*) as count, SUM(netPayable) as total FROM $tableName WHERE doctorId = ? AND status = ?',
      [doctorId, PaymentStatus.completed.index]
    );
    
    final pendingResult = await db.rawQuery(
      'SELECT COUNT(*) as count, SUM(netPayable) as total FROM $tableName WHERE doctorId = ? AND status = ?',
      [doctorId, PaymentStatus.pending.index]
    );

    return {
      'total_payments': totalResult.first['count'] as int? ?? 0,
      'total_earned': (totalResult.first['total'] as num?)?.toDouble() ?? 0.0,
      'completed_payments': completedResult.first['count'] as int? ?? 0,
      'completed_amount': (completedResult.first['total'] as num?)?.toDouble() ?? 0.0,
      'pending_payments': pendingResult.first['count'] as int? ?? 0,
      'pending_amount': (pendingResult.first['total'] as num?)?.toDouble() ?? 0.0,
    };
  }

  // Get platform revenue statistics
  Future<Map<String, dynamic>> getPlatformRevenueStats() async {
    final db = await DatabaseService().database;
    
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count, SUM(platformCommission) as commission, SUM(taxDeducted) as tax FROM $tableName'
    );
    
    final completedResult = await db.rawQuery(
      'SELECT COUNT(*) as count, SUM(platformCommission) as commission, SUM(taxDeducted) as tax FROM $tableName WHERE status = ?',
      [PaymentStatus.completed.index]
    );

    return {
      'total_transactions': totalResult.first['count'] as int? ?? 0,
      'total_commission': (totalResult.first['commission'] as num?)?.toDouble() ?? 0.0,
      'total_tax_collected': (totalResult.first['tax'] as num?)?.toDouble() ?? 0.0,
      'completed_transactions': completedResult.first['count'] as int? ?? 0,
      'completed_commission': (completedResult.first['commission'] as num?)?.toDouble() ?? 0.0,
      'completed_tax': (completedResult.first['tax'] as num?)?.toDouble() ?? 0.0,
    };
  }

  // Batch process pending payments (for automated processing)
  Future<List<DoctorPayment>> batchProcessPayments(
    List<String> paymentIds,
    String processedBy,
  ) async {
    final List<DoctorPayment> processed = [];
    
    for (final id in paymentIds) {
      try {
        final payment = await markAsProcessing(id, processedBy);
        processed.add(payment);
      } catch (e) {
        print('Error processing payment $id: $e');
      }
    }
    
    return processed;
  }

  // Get monthly earnings for a doctor (for reports)
  Future<Map<String, double>> getMonthlyEarnings(
    String doctorId,
    DateTime month,
  ) async {
    final db = await DatabaseService().database;
    
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as count,
        SUM(totalAmount) as total,
        SUM(platformCommission) as commission,
        SUM(doctorAmount) as gross,
        SUM(taxDeducted) as tax,
        SUM(netPayable) as net
      FROM $tableName 
      WHERE doctorId = ? 
      AND status = ?
      AND completedAt BETWEEN ? AND ?
    ''', [
      doctorId,
      PaymentStatus.completed.index,
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    ]);

    final row = result.first;
    return {
      'count': (row['count'] as int?)?.toDouble() ?? 0.0,
      'total_amount': (row['total'] as num?)?.toDouble() ?? 0.0,
      'commission': (row['commission'] as num?)?.toDouble() ?? 0.0,
      'gross_earnings': (row['gross'] as num?)?.toDouble() ?? 0.0,
      'tax_deducted': (row['tax'] as num?)?.toDouble() ?? 0.0,
      'net_earnings': (row['net'] as num?)?.toDouble() ?? 0.0,
    };
  }
}
