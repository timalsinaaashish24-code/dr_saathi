import 'package:sqflite/sqflite.dart';
import '../models/feedback.dart';
import 'database_service.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();
  factory FeedbackService() => _instance;
  FeedbackService._internal();

  // Get all feedback
  Future<List<Feedback>> getAllFeedback() async {
    final db = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'feedback',
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Feedback.fromMap(map)).toList();
  }

  // Get feedback by status
  Future<List<Feedback>> getFeedbackByStatus(String status) async {
    final db = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'feedback',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Feedback.fromMap(map)).toList();
  }

  // Get feedback by user type
  Future<List<Feedback>> getFeedbackByUserType(String userType) async {
    final db = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'feedback',
      where: 'userType = ?',
      whereArgs: [userType],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Feedback.fromMap(map)).toList();
  }

  // Get feedback by category
  Future<List<Feedback>> getFeedbackByCategory(String category) async {
    final db = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'feedback',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Feedback.fromMap(map)).toList();
  }

  // Get new/unread feedback count
  Future<int> getNewFeedbackCount() async {
    final db = await DatabaseService().database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM feedback WHERE status = ?',
      ['new'],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  // Insert new feedback
  Future<void> insertFeedback(Feedback feedback) async {
    final db = await DatabaseService().database;
    await db.insert(
      'feedback',
      feedback.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Update feedback status
  Future<void> updateFeedbackStatus(String id, String status) async {
    final db = await DatabaseService().database;
    await db.update(
      'feedback',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Respond to feedback
  Future<void> respondToFeedback({
    required String id,
    required String response,
    required String respondedBy,
  }) async {
    final db = await DatabaseService().database;
    await db.update(
      'feedback',
      {
        'response': response,
        'respondedBy': respondedBy,
        'respondedAt': DateTime.now().toIso8601String(),
        'status': 'resolved',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete feedback
  Future<void> deleteFeedback(String id) async {
    final db = await DatabaseService().database;
    await db.delete(
      'feedback',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get feedback statistics
  Future<Map<String, int>> getFeedbackStatistics() async {
    final db = await DatabaseService().database;
    
    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM feedback');
    final newResult = await db.rawQuery('SELECT COUNT(*) as count FROM feedback WHERE status = ?', ['new']);
    final resolvedResult = await db.rawQuery('SELECT COUNT(*) as count FROM feedback WHERE status = ?', ['resolved']);
    final bugResult = await db.rawQuery('SELECT COUNT(*) as count FROM feedback WHERE category = ?', ['bug']);
    
    return {
      'total': (totalResult.first['count'] as int?) ?? 0,
      'new': (newResult.first['count'] as int?) ?? 0,
      'resolved': (resolvedResult.first['count'] as int?) ?? 0,
      'bugs': (bugResult.first['count'] as int?) ?? 0,
    };
  }

  // Get average rating
  Future<double> getAverageRating() async {
    final db = await DatabaseService().database;
    final result = await db.rawQuery('SELECT AVG(rating) as avg FROM feedback');
    final avg = result.first['avg'];
    if (avg == null) return 0.0;
    return (avg as num).toDouble();
  }

  // Get feedback by ID
  Future<Feedback?> getFeedbackById(String id) async {
    final db = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'feedback',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Feedback.fromMap(maps.first);
  }

  // Search feedback
  Future<List<Feedback>> searchFeedback(String query) async {
    final db = await DatabaseService().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'feedback',
      where: 'subject LIKE ? OR message LIKE ? OR userName LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Feedback.fromMap(map)).toList();
  }
}
