import 'package:sqflite/sqflite.dart';
import '../models/doctor_bank_account.dart';
import 'database_service.dart';

class DoctorBankService {
  static const String tableName = 'doctor_bank_accounts';

  // Create bank account
  Future<void> createBankAccount(DoctorBankAccount account) async {
    final db = await DatabaseService().database;
    await db.insert(
      tableName,
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get bank account by doctor ID
  Future<DoctorBankAccount?> getBankAccountByDoctorId(String doctorId) async {
    final db = await DatabaseService().database;
    final List<Map<String, dynamic>> results = await db.query(
      tableName,
      where: 'doctorId = ?',
      whereArgs: [doctorId],
    );

    if (results.isEmpty) {
      return null;
    }

    return DoctorBankAccount.fromMap(results.first);
  }

  // Update bank account
  Future<void> updateBankAccount(DoctorBankAccount account) async {
    final db = await DatabaseService().database;
    await db.update(
      tableName,
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  // Delete bank account
  Future<void> deleteBankAccount(String id) async {
    final db = await DatabaseService().database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get all unverified accounts (for admin)
  Future<List<DoctorBankAccount>> getUnverifiedAccounts() async {
    final db = await DatabaseService().database;
    final List<Map<String, dynamic>> results = await db.query(
      tableName,
      where: 'isVerified = ?',
      whereArgs: [0],
      orderBy: 'createdAt DESC',
    );

    return results.map((map) => DoctorBankAccount.fromMap(map)).toList();
  }

  // Verify bank account (admin function)
  Future<void> verifyBankAccount(String accountId, String adminId) async {
    final db = await DatabaseService().database;
    await db.update(
      tableName,
      {
        'isVerified': 1,
        'verifiedAt': DateTime.now().toIso8601String(),
        'verifiedBy': adminId,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  // Get all verified accounts
  Future<List<DoctorBankAccount>> getVerifiedAccounts() async {
    final db = await DatabaseService().database;
    final List<Map<String, dynamic>> results = await db.query(
      tableName,
      where: 'isVerified = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );

    return results.map((map) => DoctorBankAccount.fromMap(map)).toList();
  }
}
