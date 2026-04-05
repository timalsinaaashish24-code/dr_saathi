/*
 * Dr. Saathi - Submit Bank Transfer Screen (Patient)
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../config/bank_accounts.dart';
import '../models/bank_transfer.dart';
import '../services/bank_transfer_service.dart';

class SubmitBankTransferScreen extends StatefulWidget {
  final String patientId;
  final double amount;
  final String? appointmentId;
  final String? invoiceId;

  const SubmitBankTransferScreen({
    Key? key,
    required this.patientId,
    required this.amount,
    this.appointmentId,
    this.invoiceId,
  }) : super(key: key);

  @override
  _SubmitBankTransferScreenState createState() =>
      _SubmitBankTransferScreenState();
}

class _SubmitBankTransferScreenState extends State<SubmitBankTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankTransferService = BankTransferService();
  final _imagePicker = ImagePicker();

  // Form controllers
  final TextEditingController _senderBankController = TextEditingController();
  final TextEditingController _senderNameController = TextEditingController();
  final TextEditingController _senderAccountController = TextEditingController();
  final TextEditingController _transactionIdController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  BankAccount? _selectedReceivingAccount;
  DateTime _transferDate = DateTime.now();
  File? _proofImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedReceivingAccount = PlatformBankAccounts.primaryAccount;
  }

  @override
  void dispose() {
    _senderBankController.dispose();
    _senderNameController.dispose();
    _senderAccountController.dispose();
    _transactionIdController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _proofImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _submitTransfer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_proofImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload payment proof'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final transfer = BankTransfer(
        id: const Uuid().v4(),
        patientId: widget.patientId,
        appointmentId: widget.appointmentId,
        invoiceId: widget.invoiceId,
        amount: widget.amount,
        senderBankName: _senderBankController.text,
        senderAccountName: _senderNameController.text,
        senderAccountNumber: _senderAccountController.text,
        receiverBankName: _selectedReceivingAccount!.bankName,
        receiverAccountNumber: _selectedReceivingAccount!.accountNumber,
        transactionId: _transactionIdController.text,
        transactionProofPath: _proofImage!.path,
        status: BankTransferStatus.pending,
        transferDate: _transferDate,
        createdAt: DateTime.now(),
        remarks: _remarksController.text.isNotEmpty
            ? _remarksController.text
            : null,
      );

      await _bankTransferService.submitTransfer(transfer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transfer submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting transfer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Transfer Payment'),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPaymentAmountCard(),
              const SizedBox(height: 20),
              _buildPlatformBankAccountsCard(),
              const SizedBox(height: 20),
              _buildInstructionsCard(),
              const SizedBox(height: 20),
              _buildTransferDetailsForm(),
              const SizedBox(height: 20),
              _buildUploadProofSection(),
              const SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentAmountCard() {
    return Card(
      color: Colors.blue[50],
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Amount to Pay:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'NPR ${widget.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformBankAccountsCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Transfer to Our Bank Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Select receiving account:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ...PlatformBankAccounts.allAccounts.map((account) {
              return RadioListTile<BankAccount>(
                title: Text(account.bankName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    _buildBankDetailRow('Account Name', account.accountName),
                    _buildBankDetailRow(
                        'Account Number', account.accountNumber),
                    _buildBankDetailRow('Branch', account.branch),
                    _buildBankDetailRow('SWIFT', account.swiftCode),
                  ],
                ),
                value: account,
                groupValue: _selectedReceivingAccount,
                onChanged: (BankAccount? value) {
                  setState(() {
                    _selectedReceivingAccount = value;
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      color: Colors.amber[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber[700]),
                const SizedBox(width: 8),
                const Text(
                  'Instructions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '1. Transfer the exact amount to one of our bank accounts above\n'
              '2. Keep your transaction receipt/screenshot\n'
              '3. Fill in the details below\n'
              '4. Upload proof of payment\n'
              '5. Submit for verification\n\n'
              'Your payment will be verified within 24 hours.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferDetailsForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Transfer Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _senderBankController,
              decoration: const InputDecoration(
                labelText: 'Your Bank Name *',
                hintText: 'e.g., Nepal Investment Bank',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your bank name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _senderNameController,
              decoration: const InputDecoration(
                labelText: 'Account Holder Name *',
                hintText: 'As shown in your bank account',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter account holder name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _senderAccountController,
              decoration: const InputDecoration(
                labelText: 'Your Account Number *',
                hintText: 'Account number you transferred from',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your account number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _transactionIdController,
              decoration: const InputDecoration(
                labelText: 'Transaction/Reference ID *',
                hintText: 'Transaction ID from your bank',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.receipt_long),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter transaction ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Transfer Date'),
              subtitle: Text(
                '${_transferDate.day}/${_transferDate.month}/${_transferDate.year}',
              ),
              trailing: const Icon(Icons.edit),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _transferDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _transferDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _remarksController,
              decoration: const InputDecoration(
                labelText: 'Remarks (Optional)',
                hintText: 'Any additional information',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadProofSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Payment Proof *',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload a screenshot or photo of your transaction receipt',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (_proofImage != null) ...[
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _proofImage!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.red,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _proofImage = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload_file),
              label: Text(_proofImage == null
                  ? 'Choose Image'
                  : 'Change Image'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitTransfer,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          disabledBackgroundColor: Colors.grey,
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Submit for Verification',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
