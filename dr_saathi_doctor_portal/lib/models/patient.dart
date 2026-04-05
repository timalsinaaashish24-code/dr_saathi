import 'insurance.dart';

class Patient {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String phoneNumber;
  final String email;
  final String address;
  final String emergencyContact;
  final String medicalHistory;
  final String allergies;
  final Insurance? insurance;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool synced;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.emergencyContact,
    required this.medicalHistory,
    required this.allergies,
    this.insurance,
    required this.createdAt,
    required this.updatedAt,
    this.synced = false,
  });

  // Computed property to get current age
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'age': age, // Keep for legacy compatibility
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'emergencyContact': emergencyContact,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
    
    if (insurance != null) {
      map.addAll({
        'insurance_company': insurance!.company ?? '',
        'insurance_policy_number': insurance!.policyNumber ?? '',
        'insurance_member_id': insurance!.memberId ?? '',
        'insurance_group_number': insurance!.groupNumber ?? '',
        'insurance_type': insurance!.type.toString().split('.').last,
        'insurance_expiry_date': insurance!.expiryDate?.toIso8601String() ?? '',
      });
    }
    
    return map;
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    Insurance? insurance;
    
    // Check if insurance data exists in the map
    if ((map['insurance_company'] != null && map['insurance_company'] != '') || 
        (map['insurance_policy_number'] != null && map['insurance_policy_number'] != '') || 
        (map['insurance_member_id'] != null && map['insurance_member_id'] != '')) {
      insurance = Insurance(
        company: (map['insurance_company'] != null && map['insurance_company'] != '') 
            ? map['insurance_company'] : null,
        policyNumber: (map['insurance_policy_number'] != null && map['insurance_policy_number'] != '') 
            ? map['insurance_policy_number'] : null,
        memberId: (map['insurance_member_id'] != null && map['insurance_member_id'] != '') 
            ? map['insurance_member_id'] : null,
        groupNumber: (map['insurance_group_number'] != null && map['insurance_group_number'] != '') 
            ? map['insurance_group_number'] : null,
        type: map['insurance_type'] != null && map['insurance_type'] != ''
            ? InsuranceType.values.firstWhere(
                (type) => type.toString().split('.').last == map['insurance_type'],
                orElse: () => InsuranceType.health,
              )
            : InsuranceType.health,
        expiryDate: (map['insurance_expiry_date'] != null && map['insurance_expiry_date'] != '') 
            ? DateTime.parse(map['insurance_expiry_date'])
            : null,
      );
    }
    
    // Handle both new dateOfBirth field and legacy age field
    DateTime dateOfBirth;
    if (map['dateOfBirth'] != null && map['dateOfBirth'] != '') {
      dateOfBirth = DateTime.parse(map['dateOfBirth']);
    } else {
      // Legacy: calculate dateOfBirth from age
      final ageValue = map['age'] ?? 0;
      final age = ageValue is int ? ageValue : (ageValue as num).toInt();
      final now = DateTime.now();
      dateOfBirth = DateTime(now.year - age, now.month, now.day);
    }

    return Patient(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      dateOfBirth: dateOfBirth,
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      emergencyContact: map['emergencyContact'] ?? '',
      medicalHistory: map['medicalHistory'] ?? '',
      allergies: map['allergies'] ?? '',
      insurance: insurance,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      synced: map['synced'] == 1,
    );
  }

  String get fullName => '$firstName $lastName';

  // Alias for legacy compatibility
  String get name => fullName;
  String get phone => phoneNumber;

  factory Patient.fromDatabaseJson(Map<String, dynamic> map) {
    return Patient.fromMap(map);
  }

  Patient copyWith({
    String? id,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? email,
    String? address,
    String? emergencyContact,
    String? medicalHistory,
    String? allergies,
    Insurance? insurance,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? synced,
  }) {
    return Patient(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      allergies: allergies ?? this.allergies,
      insurance: insurance ?? this.insurance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
    );
  }

  @override
  String toString() {
    return 'Patient{id: $id, firstName: $firstName, lastName: $lastName, dateOfBirth: $dateOfBirth, age: $age, phoneNumber: $phoneNumber, address: $address, emergencyContact: $emergencyContact, medicalHistory: $medicalHistory, allergies: $allergies, createdAt: $createdAt, updatedAt: $updatedAt, synced: $synced}';
  }
}
