class DoctorBankAccount {
  final String id;
  final String doctorId;
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String? branchName;
  final String? swiftCode;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? verifiedAt;
  final String? verifiedBy;

  DoctorBankAccount({
    required this.id,
    required this.doctorId,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    this.branchName,
    this.swiftCode,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    this.verifiedAt,
    this.verifiedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'bankName': bankName,
      'accountName': accountName,
      'accountNumber': accountNumber,
      'branchName': branchName,
      'swiftCode': swiftCode,
      'isVerified': isVerified ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'verifiedBy': verifiedBy,
    };
  }

  factory DoctorBankAccount.fromMap(Map<String, dynamic> map) {
    return DoctorBankAccount(
      id: map['id'] as String,
      doctorId: map['doctorId'] as String,
      bankName: map['bankName'] as String,
      accountName: map['accountName'] as String,
      accountNumber: map['accountNumber'] as String,
      branchName: map['branchName'] as String?,
      swiftCode: map['swiftCode'] as String?,
      isVerified: (map['isVerified'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      verifiedAt: map['verifiedAt'] != null 
          ? DateTime.parse(map['verifiedAt'] as String)
          : null,
      verifiedBy: map['verifiedBy'] as String?,
    );
  }

  DoctorBankAccount copyWith({
    String? id,
    String? doctorId,
    String? bankName,
    String? accountName,
    String? accountNumber,
    String? branchName,
    String? swiftCode,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? verifiedAt,
    String? verifiedBy,
  }) {
    return DoctorBankAccount(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      bankName: bankName ?? this.bankName,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      branchName: branchName ?? this.branchName,
      swiftCode: swiftCode ?? this.swiftCode,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
    );
  }
}
