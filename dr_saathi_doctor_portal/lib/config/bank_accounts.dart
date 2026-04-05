/*
 * Dr. Saathi - Platform Bank Account Configuration
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

class BankAccount {
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String branch;
  final String swiftCode;
  final String bankCode;
  final bool isPrimary;
  final String? logoAsset;

  const BankAccount({
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    required this.branch,
    required this.swiftCode,
    required this.bankCode,
    this.isPrimary = false,
    this.logoAsset,
  });
}

class PlatformBankAccounts {
  // Update these with your actual bank account details
  static const List<BankAccount> accounts = [
    BankAccount(
      bankName: 'Nepal Investment Bank Ltd.',
      accountName: 'Dr. Saathi Healthcare Pvt. Ltd.',
      accountNumber: '0123456789012345',
      branch: 'New Baneshwor Branch',
      swiftCode: 'NIBLNPKT',
      bankCode: 'NIBL',
      isPrimary: true,
    ),
    BankAccount(
      bankName: 'Nabil Bank Ltd.',
      accountName: 'Dr. Saathi Healthcare Pvt. Ltd.',
      accountNumber: '9876543210987654',
      branch: 'Kathmandu Main Branch',
      swiftCode: 'NARBNPKA',
      bankCode: 'NABIL',
      isPrimary: false,
    ),
    BankAccount(
      bankName: 'Standard Chartered Bank Nepal Ltd.',
      accountName: 'Dr. Saathi Healthcare Pvt. Ltd.',
      accountNumber: '5555666677778888',
      branch: 'New Road Branch',
      swiftCode: 'SCBLNPKA',
      bankCode: 'SCB',
      isPrimary: false,
    ),
  ];

  static BankAccount get primaryAccount => 
      accounts.firstWhere((account) => account.isPrimary);

  static List<BankAccount> get allAccounts => accounts;
}
