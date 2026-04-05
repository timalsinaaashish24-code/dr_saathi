class Insurance {
  final String? company;
  final String? policyNumber;
  final String? memberId;
  final String? groupNumber;
  final InsuranceType type;
  final DateTime? expiryDate;

  Insurance({
    this.company,
    this.policyNumber,
    this.memberId,
    this.groupNumber,
    this.type = InsuranceType.health,
    this.expiryDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'company': company,
      'policy_number': policyNumber,
      'member_id': memberId,
      'group_number': groupNumber,
      'type': type.toString().split('.').last,
      'expiry_date': expiryDate?.toIso8601String(),
    };
  }

  factory Insurance.fromMap(Map<String, dynamic> map) {
    return Insurance(
      company: map['company'],
      policyNumber: map['policy_number'],
      memberId: map['member_id'],
      groupNumber: map['group_number'],
      type: InsuranceType.values.firstWhere(
        (type) => type.toString().split('.').last == map['type'],
        orElse: () => InsuranceType.health,
      ),
      expiryDate: map['expiry_date'] != null 
          ? DateTime.parse(map['expiry_date'])
          : null,
    );
  }

  factory Insurance.fromJson(Map<String, dynamic> json) {
    return Insurance.fromMap(json);
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  Insurance copyWith({
    String? company,
    String? policyNumber,
    String? memberId,
    String? groupNumber,
    InsuranceType? type,
    DateTime? expiryDate,
  }) {
    return Insurance(
      company: company ?? this.company,
      policyNumber: policyNumber ?? this.policyNumber,
      memberId: memberId ?? this.memberId,
      groupNumber: groupNumber ?? this.groupNumber,
      type: type ?? this.type,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  bool get isValid {
    return company != null && 
           company!.isNotEmpty && 
           (policyNumber != null && policyNumber!.isNotEmpty || 
            memberId != null && memberId!.isNotEmpty);
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  @override
  String toString() {
    return 'Insurance{company: $company, policyNumber: $policyNumber, memberId: $memberId, groupNumber: $groupNumber, type: $type, expiryDate: $expiryDate}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Insurance &&
          runtimeType == other.runtimeType &&
          company == other.company &&
          policyNumber == other.policyNumber &&
          memberId == other.memberId &&
          groupNumber == other.groupNumber &&
          type == other.type &&
          expiryDate == other.expiryDate;

  @override
  int get hashCode =>
      company.hashCode ^
      policyNumber.hashCode ^
      memberId.hashCode ^
      groupNumber.hashCode ^
      type.hashCode ^
      expiryDate.hashCode;
}

enum InsuranceType {
  health,
  dental,
  vision,
  comprehensive,
}

extension InsuranceTypeExtension on InsuranceType {
  String get displayName {
    switch (this) {
      case InsuranceType.health:
        return 'Health Insurance';
      case InsuranceType.dental:
        return 'Dental Insurance';
      case InsuranceType.vision:
        return 'Vision Insurance';
      case InsuranceType.comprehensive:
        return 'Comprehensive Insurance';
    }
  }

  String get shortName {
    switch (this) {
      case InsuranceType.health:
        return 'Health';
      case InsuranceType.dental:
        return 'Dental';
      case InsuranceType.vision:
        return 'Vision';
      case InsuranceType.comprehensive:
        return 'Comprehensive';
    }
  }
}

// List of common insurance companies in Nepal
class InsuranceCompanies {
  static const List<String> nepalInsuranceCompanies = [
    'National Life Insurance Company Ltd.',
    'Life Insurance Corporation (Nepal) Ltd.',
    'Asian Life Insurance Co. Ltd.',
    'Gurans Life Insurance Company Ltd.',
    'Jyoti Life Insurance Company Ltd.',
    'Reliable Nepal Life Insurance Ltd.',
    'Prime Life Insurance Company Ltd.',
    'Nepal Life Insurance Co. Ltd.',
    'Surya Life Insurance Company Ltd.',
    'Mahabir Life Insurance Ltd.',
    'Citizens Life Insurance Ltd.',
    'IME Life Insurance Ltd.',
    'Shikhar Insurance Co. Ltd.',
    'Premier Insurance Company (Nepal) Ltd.',
    'Sagarmatha Insurance Company Ltd.',
    'Rastriya Beema Company Ltd.',
    'United Insurance Co. (Nepal) Ltd.',
    'Himalayan General Insurance Co. Ltd.',
    'NLG Insurance Company Ltd.',
    'Siddhartha Insurance Ltd.',
    'Neco Insurance Ltd.',
    'Lumbini General Insurance Co. Ltd.',
    'Prudential Insurance Company Ltd.',
    'General Insurance Company Ltd.',
    'Oriental Insurance Co. Ltd.',
    'Everest Insurance Company Ltd.',
    'Other',
  ];

  static List<String> searchCompanies(String query) {
    if (query.isEmpty) return nepalInsuranceCompanies;
    
    return nepalInsuranceCompanies
        .where((company) => 
            company.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
