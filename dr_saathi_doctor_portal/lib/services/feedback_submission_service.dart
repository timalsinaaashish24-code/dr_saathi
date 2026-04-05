import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FeedbackSubmissionService {
  static final FeedbackSubmissionService _instance = FeedbackSubmissionService._internal();
  factory FeedbackSubmissionService() => _instance;
  FeedbackSubmissionService._internal();

  final _uuid = const Uuid();

  // Submit feedback (saves to admin database)
  Future<bool> submitFeedback({
    required String userId,
    required String userName,
    required String userType, // 'patient' or 'doctor'
    required String subject,
    required String message,
    required String category, // 'bug', 'feature', 'complaint', 'suggestion', 'other'
    required int rating, // 1-5
    String? userEmail,
    String? userPhone,
  }) async {
    try {
      // Get admin database path
      final databasesPath = await getDatabasesPath();
      final adminDbPath = join(databasesPath, 'dr_saathi_admin.db');
      
      // Open admin database
      final db = await openDatabase(adminDbPath);
      
      // Insert feedback
      await db.insert(
        'feedback',
        {
          'id': _uuid.v4(),
          'userId': userId,
          'userName': userName,
          'userType': userType,
          'subject': subject,
          'message': message,
          'category': category,
          'rating': rating,
          'status': 'new',
          'response': null,
          'respondedBy': null,
          'createdAt': DateTime.now().toIso8601String(),
          'respondedAt': null,
          'userEmail': userEmail,
          'userPhone': userPhone,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      await db.close();
      return true;
    } catch (e) {
      print('Error submitting feedback: $e');
      return false;
    }
  }

  // Get user's feedback history
  Future<List<Map<String, dynamic>>> getUserFeedback(String userId) async {
    try {
      final databasesPath = await getDatabasesPath();
      final adminDbPath = join(databasesPath, 'dr_saathi_admin.db');
      
      final db = await openDatabase(adminDbPath);
      
      final result = await db.query(
        'feedback',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC',
      );
      
      await db.close();
      return result;
    } catch (e) {
      print('Error getting user feedback: $e');
      return [];
    }
  }

  // Check if feedback has been responded to
  Future<bool> checkForResponse(String feedbackId) async {
    try {
      final databasesPath = await getDatabasesPath();
      final adminDbPath = join(databasesPath, 'dr_saathi_admin.db');
      
      final db = await openDatabase(adminDbPath);
      
      final result = await db.query(
        'feedback',
        where: 'id = ? AND response IS NOT NULL',
        whereArgs: [feedbackId],
      );
      
      await db.close();
      return result.isNotEmpty;
    } catch (e) {
      print('Error checking feedback response: $e');
      return false;
    }
  }
}
