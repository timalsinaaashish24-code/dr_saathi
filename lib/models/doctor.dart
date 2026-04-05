class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String hospital;
  final String phone;
  final String email;
  final String address;
  final double rating;
  final int experience; // years of experience
  final String profileImage;
  final List<String> qualifications;
  final List<String> languages;
  final double consultationFee;
  final String about;
  final List<AvailabilitySlot> availabilitySlots;
  final bool isActive;
  final String nmcRegistrationNumber;
  final bool isNmcVerified;
  final DateTime? nmcVerificationDate;
  final String? nmcCertificateUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.hospital,
    required this.phone,
    required this.email,
    required this.address,
    required this.rating,
    required this.experience,
    required this.profileImage,
    required this.qualifications,
    required this.languages,
    required this.consultationFee,
    required this.about,
    required this.availabilitySlots,
    required this.isActive,
    required this.nmcRegistrationNumber,
    required this.isNmcVerified,
    this.nmcVerificationDate,
    this.nmcCertificateUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      specialization: json['specialization'],
      hospital: json['hospital'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      rating: json['rating'].toDouble(),
      experience: json['experience'],
      profileImage: json['profile_image'],
      qualifications: List<String>.from(json['qualifications']),
      languages: List<String>.from(json['languages']),
      consultationFee: json['consultation_fee'].toDouble(),
      about: json['about'],
      availabilitySlots: (json['availability_slots'] as List)
          .map((slot) => AvailabilitySlot.fromJson(slot))
          .toList(),
      isActive: json['is_active'],
      nmcRegistrationNumber: json['nmc_registration_number'] ?? '',
      isNmcVerified: json['is_nmc_verified'] ?? false,
      nmcVerificationDate: json['nmc_verification_date'] != null 
          ? DateTime.parse(json['nmc_verification_date']) 
          : null,
      nmcCertificateUrl: json['nmc_certificate_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'hospital': hospital,
      'phone': phone,
      'email': email,
      'address': address,
      'rating': rating,
      'experience': experience,
      'profile_image': profileImage,
      'qualifications': qualifications,
      'languages': languages,
      'consultation_fee': consultationFee,
      'about': about,
      'availability_slots': availabilitySlots.map((slot) => slot.toJson()).toList(),
      'is_active': isActive,
      'nmc_registration_number': nmcRegistrationNumber,
      'is_nmc_verified': isNmcVerified,
      'nmc_verification_date': nmcVerificationDate?.toIso8601String(),
      'nmc_certificate_url': nmcCertificateUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Doctor copyWith({
    String? id,
    String? name,
    String? specialization,
    String? hospital,
    String? phone,
    String? email,
    String? address,
    double? rating,
    int? experience,
    String? profileImage,
    List<String>? qualifications,
    List<String>? languages,
    double? consultationFee,
    String? about,
    List<AvailabilitySlot>? availabilitySlots,
    bool? isActive,
    String? nmcRegistrationNumber,
    bool? isNmcVerified,
    DateTime? nmcVerificationDate,
    String? nmcCertificateUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      hospital: hospital ?? this.hospital,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      experience: experience ?? this.experience,
      profileImage: profileImage ?? this.profileImage,
      qualifications: qualifications ?? this.qualifications,
      languages: languages ?? this.languages,
      consultationFee: consultationFee ?? this.consultationFee,
      about: about ?? this.about,
      availabilitySlots: availabilitySlots ?? this.availabilitySlots,
      isActive: isActive ?? this.isActive,
      nmcRegistrationNumber: nmcRegistrationNumber ?? this.nmcRegistrationNumber,
      isNmcVerified: isNmcVerified ?? this.isNmcVerified,
      nmcVerificationDate: nmcVerificationDate ?? this.nmcVerificationDate,
      nmcCertificateUrl: nmcCertificateUrl ?? this.nmcCertificateUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AvailabilitySlot {
  final String id;
  final String doctorId;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final bool isBooked;
  final String? patientId;
  final String? appointmentId;
  final String dayOfWeek; // Monday, Tuesday, etc.
  final ConsultationType consultationType;
  final DateTime createdAt;
  final DateTime updatedAt;

  AvailabilitySlot({
    required this.id,
    required this.doctorId,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.isBooked,
    this.patientId,
    this.appointmentId,
    required this.dayOfWeek,
    required this.consultationType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      id: json['id'],
      doctorId: json['doctor_id'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      isAvailable: json['is_available'],
      isBooked: json['is_booked'],
      patientId: json['patient_id'],
      appointmentId: json['appointment_id'],
      dayOfWeek: json['day_of_week'],
      consultationType: ConsultationType.values.firstWhere(
        (type) => type.toString() == json['consultation_type'],
        orElse: () => ConsultationType.inPerson,
      ),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_available': isAvailable,
      'is_booked': isBooked,
      'patient_id': patientId,
      'appointment_id': appointmentId,
      'day_of_week': dayOfWeek,
      'consultation_type': consultationType.toString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AvailabilitySlot copyWith({
    String? id,
    String? doctorId,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAvailable,
    bool? isBooked,
    String? patientId,
    String? appointmentId,
    String? dayOfWeek,
    ConsultationType? consultationType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AvailabilitySlot(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
      isBooked: isBooked ?? this.isBooked,
      patientId: patientId ?? this.patientId,
      appointmentId: appointmentId ?? this.appointmentId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      consultationType: consultationType ?? this.consultationType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum ConsultationType {
  inPerson,
  telehealth,
  both,
}

class Appointment {
  final String id;
  final String patientId;
  final String doctorId;
  final String slotId;
  final DateTime appointmentDate;
  final DateTime startTime;
  final DateTime endTime;
  final AppointmentStatus status;
  final ConsultationType consultationType;
  final String? notes;
  final String? symptoms;
  final String? diagnosis;
  final String? prescription;
  final double? consultationFee;
  final bool isPaid;
  final DateTime createdAt;
  final DateTime updatedAt;

  Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.slotId,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.consultationType,
    this.notes,
    this.symptoms,
    this.diagnosis,
    this.prescription,
    this.consultationFee,
    required this.isPaid,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      patientId: json['patient_id'],
      doctorId: json['doctor_id'],
      slotId: json['slot_id'],
      appointmentDate: DateTime.parse(json['appointment_date']),
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      status: AppointmentStatus.values.firstWhere(
        (status) => status.toString() == json['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      consultationType: ConsultationType.values.firstWhere(
        (type) => type.toString() == json['consultation_type'],
        orElse: () => ConsultationType.inPerson,
      ),
      notes: json['notes'],
      symptoms: json['symptoms'],
      diagnosis: json['diagnosis'],
      prescription: json['prescription'],
      consultationFee: json['consultation_fee']?.toDouble(),
      isPaid: json['is_paid'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'slot_id': slotId,
      'appointment_date': appointmentDate.toIso8601String(),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'status': status.toString(),
      'consultation_type': consultationType.toString(),
      'notes': notes,
      'symptoms': symptoms,
      'diagnosis': diagnosis,
      'prescription': prescription,
      'consultation_fee': consultationFee,
      'is_paid': isPaid,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Appointment copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? slotId,
    DateTime? appointmentDate,
    DateTime? startTime,
    DateTime? endTime,
    AppointmentStatus? status,
    ConsultationType? consultationType,
    String? notes,
    String? symptoms,
    String? diagnosis,
    String? prescription,
    double? consultationFee,
    bool? isPaid,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      slotId: slotId ?? this.slotId,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      consultationType: consultationType ?? this.consultationType,
      notes: notes ?? this.notes,
      symptoms: symptoms ?? this.symptoms,
      diagnosis: diagnosis ?? this.diagnosis,
      prescription: prescription ?? this.prescription,
      consultationFee: consultationFee ?? this.consultationFee,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum AppointmentStatus {
  scheduled,
  confirmed,
  inProgress,
  completed,
  cancelled,
  noShow,
}

// Specializations enum for easy management
enum Specialization {
  generalPractitioner,
  cardiologist,
  dermatologist,
  endocrinologist,
  gastroenterologist,
  neurologist,
  orthopedic,
  pediatrician,
  psychiatrist,
  pulmonologist,
  radiologist,
  surgeon,
  urologist,
  gynecologist,
  ophthalmologist,
  dentist,
  physiotherapist,
  psychologist,
  nutritionist,
  other,
}

extension SpecializationExtension on Specialization {
  String get displayName {
    switch (this) {
      case Specialization.generalPractitioner:
        return 'General Practitioner';
      case Specialization.cardiologist:
        return 'Cardiologist';
      case Specialization.dermatologist:
        return 'Dermatologist';
      case Specialization.endocrinologist:
        return 'Endocrinologist';
      case Specialization.gastroenterologist:
        return 'Gastroenterologist';
      case Specialization.neurologist:
        return 'Neurologist';
      case Specialization.orthopedic:
        return 'Orthopedic';
      case Specialization.pediatrician:
        return 'Pediatrician';
      case Specialization.psychiatrist:
        return 'Psychiatrist';
      case Specialization.pulmonologist:
        return 'Pulmonologist';
      case Specialization.radiologist:
        return 'Radiologist';
      case Specialization.surgeon:
        return 'Surgeon';
      case Specialization.urologist:
        return 'Urologist';
      case Specialization.gynecologist:
        return 'Gynecologist';
      case Specialization.ophthalmologist:
        return 'Ophthalmologist';
      case Specialization.dentist:
        return 'Dentist';
      case Specialization.physiotherapist:
        return 'Physiotherapist';
      case Specialization.psychologist:
        return 'Psychologist';
      case Specialization.nutritionist:
        return 'Nutritionist';
      case Specialization.other:
        return 'Other';
    }
  }
}
