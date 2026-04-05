/*
 * Dr. Saathi - Bank Transfer Service
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

import 'package:sqflite/sqflite.dart';
import '../models/bank_transfer.dart';
import '../services/database_service.dart';
import 'dart:io';

class BankTransferService {
  static const String tableName = 'bank_transfers';

  // Initialize database table
  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
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
        transactionId TEXT NOT NULL,
        transactionProofPath TEXT,
        status INTEGER NOT NULL,
        transferDate TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        verifiedAt TEXT,
        verifiedBy TEXT,
        rejectionReason TEXT,
        remarks TEXT
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_bank_transfers_patient 
      ON $tableName(patientId)
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_bank_transfers_status 
      ON $tableName(status)
    ''');
    
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_bank_transfers_appointment 
      ON $tableName(appointmentId)
    ''');
  }

  // Submit a new bank transfer
  Future<BankTransfer> submitTransfer(BankTransfer transfer) async {
    final db = await DatabaseService().database;
    await db.insert(
      tableName,
      transfer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return transfer;
  }

  // Get transfer by ID
  Future<BankTransfer?> getTransferById(String id) async {
    final db = await DatabaseService().database;
    final results = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isEmpty) return null;
    return BankTransfer.fromMap(results.first);
  }

  // Get all transfers for a patient
  Future<List<BankTransfer>> getTransfersByPatient(String patientId) async {
    final db = await DatabaseService().database;
    final results = await db.query(
      tableName,
      where: 'patientId = ?',
      whereArgs: [patientId],
      orderBy: 'createdAt DESC',
    );

    return results.map((map) => BankTransfer.fromMap(map)).toList();
  }

  // Get transfers by status
  Future<List<BankTransfer>> getTransfersByStatus(
    BankTransferStatus status,
  ) async {
    final db = await DatabaseService().database;
    final results = await db.query(
      tableName,
      where: 'status = ?',
      whereArgs: [status.index],
      orderBy: 'createdAt DESC',
    );

    return results.map((map) => BankTransfer.fromMap(map)).toList();
  }

  // Get pending transfers (for admin verification)
  Future<List<BankTransfer>> getPendingTransfers() async {
    return getTransfersByStatus(BankTransferStatus.pending);
  }

  // Verify a transfer (admin action)
  Future<BankTransfer> verifyTransfer(
    String transferId,
    String verifiedBy,
  ) async {
    final db = await DatabaseService().database;
    final transfer = await getTransferById(transferId);
    
    if (transfer == null) {
      throw Exception('Transfer not found');
    }

    final updatedTransfer = transfer.copyWith(
      status: BankTransferStatus.verified,
      verifiedAt: DateTime.now(),
      verifiedBy: verifiedBy,
    );

    await db.update(
      tableName,
      updatedTransfer.toMap(),
      where: 'id = ?',
      whereArgs: [transferId],
    );

    return updatedTransfer;
  }

  // Reject a transfer (admin action)
  Future<BankTransfer> rejectTransfer(
    String transferId,
    String rejectionReason,
    String rejectedBy,
  ) async {
    final db = await DatabaseService().database;
    final transfer = await getTransferById(transferId);
    
    if (transfer == null) {
      throw Exception('Transfer not found');
    }

    final updatedTransfer = transfer.copyWith(
      status: BankTransferStatus.rejected,
      verifiedAt: DateTime.now(),
      verifiedBy: rejectedBy,
      rejectionReason: rejectionReason,
    );

    await db.update(
      tableName,
      updatedTransfer.toMap(),
      where: 'id = ?',
      whereArgs: [transferId],
    );

    return updatedTransfer;
  }

  // Get transfer statistics
  Future<Map<String, dynamic>> getTransferStats() async {
    final db = await DatabaseService().database;
    
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count, SUM(amount) as total FROM $tableName'
    );
    
    final verifiedResult = await db.rawQuery(
      'SELECT COUNT(*) as count, SUM(amount) as total FROM $tableName WHERE status = ?',
      [BankTransferStatus.verified.index]
    );
    
    final pendingResult = await db.rawQuery(
      'SELECT COUNT(*) as count, SUM(amount) as total FROM $tableName WHERE status = ?',
      [BankTransferStatus.pending.index]
    );

    return {
      'total_count': totalResult.first['count'] ?? 0,
      'total_amount': totalResult.first['total'] ?? 0.0,
      'verified_count': verifiedResult.first['count'] ?? 0,
      'verified_amount': verifiedResult.first['total'] ?? 0.0,
      'pending_count': pendingResult.first['count'] ?? 0,
      'pending_amount': pendingResult.first['total'] ?? 0.0,
    };
  }

  // Delete transfer proof file
  Future<void> deleteTransferProof(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting transfer proof: $e');
    }
  }

  // Clean up expired pending transfers (optional - run periodically)
  Future<int> cleanupExpiredTransfers({int daysOld = 7}) async {
    final db = await DatabaseService().database;
    final expiryDate = DateTime.now().subtract(Duration(days: daysOld));
    
    return await db.update(
      tableName,
      {'status': BankTransferStatus.expired.index},
      where: 'status = ? AND createdAt < ?',
      whereArgs: [
        BankTransferStatus.pending.index,
        expiryDate.toIso8601String(),
      ],
    );
  }
}
