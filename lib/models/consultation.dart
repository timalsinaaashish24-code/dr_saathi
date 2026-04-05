class Consultation {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final DateTime consultationDate;
  final String consultationType; // 'video', 'in-person', 'phone'
  final String status; // 'scheduled', 'ongoing', 'completed', 'cancelled'
  final double consultationFee;
  final String? diagnosis;
  final String? prescription;
  final String? notes;
  final DateTime? completedAt;
  final bool billGenerated;
  final String? billId;

  Consultation({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.consultationDate,
    required this.consultationType,
    required this.status,
    required this.consultationFee,
    this.diagnosis,
    this.prescription,
    this.notes,
    this.completedAt,
    this.billGenerated = false,
    this.billId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'consultation_date': consultationDate.toIso8601String(),
      'consultation_type': consultationType,
      'status': status,
      'consultation_fee': consultationFee,
      'diagnosis': diagnosis,
      'prescription': prescription,
      'notes': notes,
      'completed_at': completedAt?.toIso8601String(),
      'bill_generated': billGenerated ? 1 : 0,
      'bill_id': billId,
    };
  }

  factory Consultation.fromMap(Map<String, dynamic> map) {
    return Consultation(
      id: map['id'],
      patientId: map['patient_id'],
      patientName: map['patient_name'],
      doctorId: map['doctor_id'],
      doctorName: map['doctor_name'],
      consultationDate: DateTime.parse(map['consultation_date']),
      consultationType: map['consultation_type'],
      status: map['status'],
      consultationFee: (map['consultation_fee'] as num).toDouble(),
      diagnosis: map['diagnosis'],
      prescription: map['prescription'],
      notes: map['notes'],
      completedAt: map['completed_at'] != null 
          ? DateTime.parse(map['completed_at']) 
          : null,
      billGenerated: map['bill_generated'] == 1,
      billId: map['bill_id'],
    );
  }

  Consultation copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? doctorId,
    String? doctorName,
    DateTime? consultationDate,
    String? consultationType,
    String? status,
    double? consultationFee,
    String? diagnosis,
    String? prescription,
    String? notes,
    DateTime? completedAt,
    bool? billGenerated,
    String? billId,
  }) {
    return Consultation(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      consultationDate: consultationDate ?? this.consultationDate,
      consultationType: consultationType ?? this.consultationType,
      status: status ?? this.status,
      consultationFee: consultationFee ?? this.consultationFee,
      diagnosis: diagnosis ?? this.diagnosis,
      prescription: prescription ?? this.prescription,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
      billGenerated: billGenerated ?? this.billGenerated,
      billId: billId ?? this.billId,
    );
  }
}
