class Appointment {
  final int? id;
  final String doctorId;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String patientEmail;
  final DateTime appointmentDate;
  final String timeSlot;
  final String status; // scheduled, completed, cancelled, no_show
  final String? notes;
  final String? chiefComplaint;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Appointment({
    this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.patientEmail,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    this.notes,
    this.chiefComplaint,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_phone': patientPhone,
      'patient_email': patientEmail,
      'appointment_date': appointmentDate.toIso8601String(),
      'time_slot': timeSlot,
      'status': status,
      'notes': notes,
      'chief_complaint': chiefComplaint,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      doctorId: map['doctor_id'],
      patientId: map['patient_id'],
      patientName: map['patient_name'],
      patientPhone: map['patient_phone'],
      patientEmail: map['patient_email'],
      appointmentDate: DateTime.parse(map['appointment_date']),
      timeSlot: map['time_slot'],
      status: map['status'],
      notes: map['notes'],
      chiefComplaint: map['chief_complaint'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}

class DoctorAvailability {
  final int? id;
  final String doctorId;
  final DateTime date;
  final String status; // available, unavailable, busy
  final String? startTime;
  final String? endTime;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DoctorAvailability({
    this.id,
    required this.doctorId,
    required this.date,
    required this.status,
    this.startTime,
    this.endTime,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'date': date.toIso8601String().split('T')[0],
      'status': status,
      'start_time': startTime,
      'end_time': endTime,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory DoctorAvailability.fromMap(Map<String, dynamic> map) {
    return DoctorAvailability(
      id: map['id'],
      doctorId: map['doctor_id'],
      date: DateTime.parse(map['date']),
      status: map['status'],
      startTime: map['start_time'],
      endTime: map['end_time'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}
