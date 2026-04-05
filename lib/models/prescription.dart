enum PrescriptionStatus {
  draft,
  sent,
  received,
  dispensed,
  completed,
  cancelled
}

class Prescription {
  final int? id;
  final String patientId;
  final String patientName;
  final String? patientPhone;
  final String doctorName;
  final String doctorId;
  final String? doctorLicenseNumber;
  final DateTime prescriptionDate;
  final String diagnosis;
  final String? symptoms;
  final String notes;
  final List<Medication> medications;
  final PrescriptionStatus status;
  final DateTime? followUpDate;
  final DateTime? sentDate;
  final DateTime? dispensedDate;
  final String? pharmacyId;
  final String? pharmacyName;
  final String? qrCode;
  final String? digitalSignature;
  final bool isUrgent;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  Prescription({
    this.id,
    required this.patientId,
    required this.patientName,
    this.patientPhone,
    required this.doctorName,
    required this.doctorId,
    this.doctorLicenseNumber,
    required this.prescriptionDate,
    required this.diagnosis,
    this.symptoms,
    this.notes = '',
    required this.medications,
    this.status = PrescriptionStatus.draft,
    this.followUpDate,
    this.sentDate,
    this.dispensedDate,
    this.pharmacyId,
    this.pharmacyName,
    this.qrCode,
    this.digitalSignature,
    this.isUrgent = false,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_phone': patientPhone,
      'doctor_name': doctorName,
      'doctor_id': doctorId,
      'doctor_license_number': doctorLicenseNumber,
      'prescription_date': prescriptionDate.toIso8601String(),
      'diagnosis': diagnosis,
      'symptoms': symptoms,
      'notes': notes,
      'medications': medications.map((m) => m.toJson()).toList(),
      'status': status.toString().split('.').last,
      'follow_up_date': followUpDate?.toIso8601String(),
      'sent_date': sentDate?.toIso8601String(),
      'dispensed_date': dispensedDate?.toIso8601String(),
      'pharmacy_id': pharmacyId,
      'pharmacy_name': pharmacyName,
      'qr_code': qrCode,
      'digital_signature': digitalSignature,
      'is_urgent': isUrgent,
      'is_synced': isSynced ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      patientId: json['patient_id'],
      patientName: json['patient_name'],
      patientPhone: json['patient_phone'],
      doctorName: json['doctor_name'],
      doctorId: json['doctor_id'],
      doctorLicenseNumber: json['doctor_license_number'],
      prescriptionDate: DateTime.parse(json['prescription_date']),
      diagnosis: json['diagnosis'],
      symptoms: json['symptoms'],
      notes: json['notes'] ?? '',
      medications: (json['medications'] as List<dynamic>?)
          ?.map((m) => Medication.fromJson(m))
          .toList() ?? [],
      status: PrescriptionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PrescriptionStatus.draft,
      ),
      followUpDate: json['follow_up_date'] != null 
          ? DateTime.parse(json['follow_up_date'])
          : null,
      sentDate: json['sent_date'] != null 
          ? DateTime.parse(json['sent_date'])
          : null,
      dispensedDate: json['dispensed_date'] != null 
          ? DateTime.parse(json['dispensed_date'])
          : null,
      pharmacyId: json['pharmacy_id'],
      pharmacyName: json['pharmacy_name'],
      qrCode: json['qr_code'],
      digitalSignature: json['digital_signature'],
      isUrgent: json['is_urgent'] ?? false,
      isSynced: json['is_synced'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toDatabaseJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'patient_name': patientName,
      'patient_phone': patientPhone,
      'doctor_name': doctorName,
      'doctor_id': doctorId,
      'doctor_license_number': doctorLicenseNumber,
      'prescription_date': prescriptionDate.toIso8601String(),
      'diagnosis': diagnosis,
      'symptoms': symptoms,
      'notes': notes,
      'status': status.toString().split('.').last,
      'follow_up_date': followUpDate?.toIso8601String(),
      'sent_date': sentDate?.toIso8601String(),
      'dispensed_date': dispensedDate?.toIso8601String(),
      'pharmacy_id': pharmacyId,
      'pharmacy_name': pharmacyName,
      'qr_code': qrCode,
      'digital_signature': digitalSignature,
      'is_urgent': isUrgent ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Prescription.fromDatabaseJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      patientId: json['patient_id'],
      patientName: json['patient_name'],
      patientPhone: json['patient_phone'],
      doctorName: json['doctor_name'],
      doctorId: json['doctor_id'],
      doctorLicenseNumber: json['doctor_license_number'],
      prescriptionDate: DateTime.parse(json['prescription_date']),
      diagnosis: json['diagnosis'],
      symptoms: json['symptoms'],
      notes: json['notes'] ?? '',
      medications: [], // Will be loaded separately
      status: PrescriptionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PrescriptionStatus.draft,
      ),
      followUpDate: json['follow_up_date'] != null 
          ? DateTime.parse(json['follow_up_date'])
          : null,
      sentDate: json['sent_date'] != null 
          ? DateTime.parse(json['sent_date'])
          : null,
      dispensedDate: json['dispensed_date'] != null 
          ? DateTime.parse(json['dispensed_date'])
          : null,
      pharmacyId: json['pharmacy_id'],
      pharmacyName: json['pharmacy_name'],
      qrCode: json['qr_code'],
      digitalSignature: json['digital_signature'],
      isUrgent: json['is_urgent'] == 1,
      isSynced: json['is_synced'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Prescription copyWith({
    int? id,
    String? patientId,
    String? patientName,
    String? patientPhone,
    String? doctorName,
    String? doctorId,
    String? doctorLicenseNumber,
    DateTime? prescriptionDate,
    String? diagnosis,
    String? symptoms,
    String? notes,
    List<Medication>? medications,
    PrescriptionStatus? status,
    DateTime? followUpDate,
    DateTime? sentDate,
    DateTime? dispensedDate,
    String? pharmacyId,
    String? pharmacyName,
    String? qrCode,
    String? digitalSignature,
    bool? isUrgent,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Prescription(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      doctorName: doctorName ?? this.doctorName,
      doctorId: doctorId ?? this.doctorId,
      doctorLicenseNumber: doctorLicenseNumber ?? this.doctorLicenseNumber,
      prescriptionDate: prescriptionDate ?? this.prescriptionDate,
      diagnosis: diagnosis ?? this.diagnosis,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      medications: medications ?? this.medications,
      status: status ?? this.status,
      followUpDate: followUpDate ?? this.followUpDate,
      sentDate: sentDate ?? this.sentDate,
      dispensedDate: dispensedDate ?? this.dispensedDate,
      pharmacyId: pharmacyId ?? this.pharmacyId,
      pharmacyName: pharmacyName ?? this.pharmacyName,
      qrCode: qrCode ?? this.qrCode,
      digitalSignature: digitalSignature ?? this.digitalSignature,
      isUrgent: isUrgent ?? this.isUrgent,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  String get statusDisplay {
    switch (status) {
      case PrescriptionStatus.draft:
        return 'Draft';
      case PrescriptionStatus.sent:
        return 'Sent';
      case PrescriptionStatus.received:
        return 'Received';
      case PrescriptionStatus.dispensed:
        return 'Dispensed';
      case PrescriptionStatus.completed:
        return 'Completed';
      case PrescriptionStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get canEdit => status == PrescriptionStatus.draft;
  bool get canSend => status == PrescriptionStatus.draft && medications.isNotEmpty;
  bool get canCancel => status != PrescriptionStatus.completed && status != PrescriptionStatus.cancelled;
}

class Medication {
  final int? id;
  final int? prescriptionId;
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String instructions;
  final String form; // 'tablet', 'capsule', 'syrup', 'injection', etc.
  final int quantity;
  final String? genericName;
  final bool isGeneric;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medication({
    this.id,
    this.prescriptionId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions = '',
    this.form = 'tablet',
    required this.quantity,
    this.genericName,
    this.isGeneric = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prescription_id': prescriptionId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
      'form': form,
      'quantity': quantity,
      'generic_name': genericName,
      'is_generic': isGeneric,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      prescriptionId: json['prescription_id'],
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      duration: json['duration'],
      instructions: json['instructions'] ?? '',
      form: json['form'] ?? 'tablet',
      quantity: json['quantity'],
      genericName: json['generic_name'],
      isGeneric: json['is_generic'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toDatabaseJson() {
    return {
      'id': id,
      'prescription_id': prescriptionId,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      'instructions': instructions,
      'form': form,
      'quantity': quantity,
      'generic_name': genericName,
      'is_generic': isGeneric ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Medication.fromDatabaseJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      prescriptionId: json['prescription_id'],
      name: json['name'],
      dosage: json['dosage'],
      frequency: json['frequency'],
      duration: json['duration'],
      instructions: json['instructions'] ?? '',
      form: json['form'] ?? 'tablet',
      quantity: json['quantity'],
      genericName: json['generic_name'],
      isGeneric: json['is_generic'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Medication copyWith({
    int? id,
    int? prescriptionId,
    String? name,
    String? dosage,
    String? frequency,
    String? duration,
    String? instructions,
    String? form,
    int? quantity,
    String? genericName,
    bool? isGeneric,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medication(
      id: id ?? this.id,
      prescriptionId: prescriptionId ?? this.prescriptionId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      instructions: instructions ?? this.instructions,
      form: form ?? this.form,
      quantity: quantity ?? this.quantity,
      genericName: genericName ?? this.genericName,
      isGeneric: isGeneric ?? this.isGeneric,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
