import 'package:sqflite/sqflite.dart';
import '../models/appointment.dart';
import 'database_service.dart';
import 'refund_service.dart';
import 'payment_hold_service.dart';

class AppointmentService {
  final DatabaseService _databaseService = DatabaseService();

  Future<Database> get _database async => await _databaseService.database;

  // Initialize tables
  Future<void> initialize() async {
    final db = await _database;
    
    // Create appointments table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        doctor_id TEXT NOT NULL,
        patient_id TEXT NOT NULL,
        patient_name TEXT NOT NULL,
        patient_phone TEXT NOT NULL,
        patient_email TEXT,
        appointment_date TEXT NOT NULL,
        time_slot TEXT NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        chief_complaint TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Create doctor_availability table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS doctor_availability (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        doctor_id TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        start_time TEXT,
        end_time TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        UNIQUE(doctor_id, date)
      )
    ''');
  }

  // Appointment CRUD operations
  Future<int> createAppointment(Appointment appointment) async {
    final db = await _database;
    return await db.insert('appointments', appointment.toMap());
  }

  Future<List<Appointment>> getAppointmentsByDoctor(String doctorId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'doctor_id = ?',
      whereArgs: [doctorId],
      orderBy: 'appointment_date DESC, time_slot ASC',
    );
    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  Future<List<Appointment>> getAppointmentsByDate(String doctorId, DateTime date) async {
    final db = await _database;
    final dateStr = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'doctor_id = ? AND DATE(appointment_date) = ?',
      whereArgs: [doctorId, dateStr],
      orderBy: 'time_slot ASC',
    );
    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  Future<List<Appointment>> getUpcomingAppointments(String doctorId) async {
    final db = await _database;
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'appointments',
      where: 'doctor_id = ? AND appointment_date >= ? AND status = ?',
      whereArgs: [doctorId, now, 'scheduled'],
      orderBy: 'appointment_date ASC, time_slot ASC',
      limit: 10,
    );
    return List.generate(maps.length, (i) => Appointment.fromMap(maps[i]));
  }

  Future<int> updateAppointment(Appointment appointment) async {
    final db = await _database;
    return await db.update(
      'appointments',
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<int> updateAppointmentStatus(int appointmentId, String status) async {
    final db = await _database;
    return await db.update(
      'appointments',
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [appointmentId],
    );
  }

  Future<int> deleteAppointment(int appointmentId) async {
    final db = await _database;
    return await db.delete(
      'appointments',
      where: 'id = ?',
      whereArgs: [appointmentId],
    );
  }

  /// Cancel appointment with reason and auto-refund.
  /// If within 24-hour hold period → instant refund from held funds.
  /// If past 24 hours → refund via bank transfer.
  Future<RefundResult> cancelAppointmentWithRefund({
    required int appointmentId,
    required String cancellationReason,
    required String cancelledBy,
    required double refundAmount,
    String? patientBankName,
    String? patientAccountNumber,
    String? patientAccountName,
  }) async {
    final db = await _database;

    // Get appointment details
    final results = await db.query('appointments', where: 'id = ?', whereArgs: [appointmentId]);
    if (results.isEmpty) {
      return RefundResult(success: false, errorMessage: 'Appointment not found', status: RefundStatus.failed);
    }

    // 1. Update appointment status to cancelled with reason
    await db.update(
      'appointments',
      {
        'status': 'cancelled',
        'notes': 'Cancelled: $cancellationReason',
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [appointmentId],
    );

    // 2. Check if payment is still on 24-hour hold
    final holdService = PaymentHoldService();
    await holdService.initialize();
    final isOnHold = await holdService.isPaymentOnHold(appointmentId);

    if (isOnHold) {
      // Within 24 hours — instant refund from held funds (no bank API needed)
      return await holdService.refundFromHold(
        appointmentId: appointmentId,
        cancellationReason: cancellationReason,
        cancelledBy: cancelledBy,
      );
    } else {
      // Past 24 hours — refund via bank transfer
      final apt = results.first;
      final refundService = RefundService();
      await refundService.initialize();

      return await refundService.processRefund(
        appointmentId: appointmentId,
        patientId: apt['patient_id'] as String,
        patientName: apt['patient_name'] as String,
        amount: refundAmount,
        cancellationReason: cancellationReason,
        cancelledBy: cancelledBy,
        patientBankName: patientBankName,
        patientAccountNumber: patientAccountNumber,
        patientAccountName: patientAccountName,
      );
    }
  }

  // Availability CRUD operations
  Future<int> setAvailability(DoctorAvailability availability) async {
    final db = await _database;
    return await db.insert(
      'doctor_availability',
      availability.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DoctorAvailability?> getAvailability(String doctorId, DateTime date) async {
    final db = await _database;
    final dateStr = date.toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'doctor_availability',
      where: 'doctor_id = ? AND date = ?',
      whereArgs: [doctorId, dateStr],
    );
    
    if (maps.isEmpty) return null;
    return DoctorAvailability.fromMap(maps.first);
  }

  Future<List<DoctorAvailability>> getAvailabilityRange(
    String doctorId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _database;
    final startStr = startDate.toIso8601String().split('T')[0];
    final endStr = endDate.toIso8601String().split('T')[0];
    
    final List<Map<String, dynamic>> maps = await db.query(
      'doctor_availability',
      where: 'doctor_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [doctorId, startStr, endStr],
      orderBy: 'date ASC',
    );
    
    return List.generate(maps.length, (i) => DoctorAvailability.fromMap(maps[i]));
  }

  Future<int> updateAvailability(DoctorAvailability availability) async {
    final db = await _database;
    return await db.update(
      'doctor_availability',
      availability.toMap(),
      where: 'id = ?',
      whereArgs: [availability.id],
    );
  }

  Future<int> deleteAvailability(int availabilityId) async {
    final db = await _database;
    return await db.delete(
      'doctor_availability',
      where: 'id = ?',
      whereArgs: [availabilityId],
    );
  }

  // Statistics
  Future<Map<String, int>> getAppointmentStats(String doctorId) async {
    final db = await _database;
    
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM appointments WHERE doctor_id = ?',
      [doctorId],
    );
    
    final scheduledResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM appointments WHERE doctor_id = ? AND status = ?',
      [doctorId, 'scheduled'],
    );
    
    final completedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM appointments WHERE doctor_id = ? AND status = ?',
      [doctorId, 'completed'],
    );
    
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final todayResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM appointments WHERE doctor_id = ? AND DATE(appointment_date) = ?',
      [doctorId, todayStr],
    );
    
    return {
      'total': totalResult.first['count'] as int,
      'scheduled': scheduledResult.first['count'] as int,
      'completed': completedResult.first['count'] as int,
      'today': todayResult.first['count'] as int,
    };
  }

  // Get unique patients from appointments
  Future<List<Map<String, dynamic>>> getPatientsList(String doctorId) async {
    final db = await _database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT patient_id, patient_name, patient_phone, patient_email,
             MAX(appointment_date) as last_visit,
             COUNT(*) as visit_count
      FROM appointments
      WHERE doctor_id = ?
      GROUP BY patient_id, patient_name, patient_phone, patient_email
      ORDER BY MAX(appointment_date) DESC
    ''', [doctorId]);
    
    return maps;
  }
}
