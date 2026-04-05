import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/doctor_bank_service.dart';
import '../models/doctor_bank_account.dart';

class DoctorBankAccountScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  const DoctorBankAccountScreen({
    Key? key,
    required this.doctorId,
    required this.doctorName,
  }) : super(key: key);

  @override
  State<DoctorBankAccountScreen> createState() => _DoctorBankAccountScreenState();
}

class _DoctorBankAccountScreenState extends State<DoctorBankAccountScreen> {
  final DoctorBankService _bankService = DoctorBankService();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = true;
  bool _isEditing = false;
  DoctorBankAccount? _bankAccount;
  
  // Form controllers
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _swiftCodeController = TextEditingController();
  
  // Common Nepal banks
  final List<String> _nepaliBanks = [
    'Nepal Rastra Bank',
    'Nepal Investment Bank Ltd. (NIBL)',
    'Nabil Bank Limited',
    'Standard Chartered Bank Nepal',
    'Himalayan Bank Limited',
    'Nepal SBI Bank Limited',
    'Nepal Bangladesh Bank Limited',
    'Everest Bank Limited',
    'Kumari Bank Limited',
    'Laxmi Bank Limited',
    'Citizens Bank International',
    'Prime Commercial Bank',
    'Sunrise Bank Limited',
    'Century Commercial Bank',
    'Sanima Bank Limited',
    'Machhapuchchhre Bank Limited',
    'NIC Asia Bank Limited',
    'Global IME Bank Limited',
    'NMB Bank Limited',
    'Prabhu Bank Limited',
    'Siddhartha Bank Limited',
    'Bank of Kathmandu Limited',
    'Civil Bank Limited',
    'Nepal Credit and Commerce Bank',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadBankAccount();
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _branchController.dispose();
    _swiftCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadBankAccount() async {
    setState(() => _isLoading = true);
    try {
      final account = await _bankService.getBankAccountByDoctorId(widget.doctorId);
      if (account != null) {
        setState(() {
          _bankAccount = account;
          _bankNameController.text = account.bankName;
          _accountNameController.text = account.accountName;
          _accountNumberController.text = account.accountNumber;
          _branchController.text = account.branchName ?? '';
          _swiftCodeController.text = account.swiftCode ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading bank details: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveBankAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_bankAccount == null) {
        // Create new
        final newAccount = DoctorBankAccount(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          doctorId: widget.doctorId,
          bankName: _bankNameController.text,
          accountName: _accountNameController.text,
          accountNumber: _accountNumberController.text,
          branchName: _branchController.text.isEmpty ? null : _branchController.text,
          swiftCode: _swiftCodeController.text.isEmpty ? null : _swiftCodeController.text,
          isVerified: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _bankService.createBankAccount(newAccount);
      } else {
        // Update existing
        final updatedAccount = _bankAccount!.copyWith(
          bankName: _bankNameController.text,
          accountName: _accountNameController.text,
          accountNumber: _accountNumberController.text,
          branchName: _branchController.text.isEmpty ? null : _branchController.text,
          swiftCode: _swiftCodeController.text.isEmpty ? null : _swiftCodeController.text,
          updatedAt: DateTime.now(),
        );
        await _bankService.updateBankAccount(updatedAccount);
      }

      await _loadBankAccount();
      setState(() => _isEditing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bank account details saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving bank details: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Account Details'),
        backgroundColor: Colors.teal[700],
        actions: [
          if (!_isEditing && _bankAccount != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Add your bank account details to receive payments directly from the platform.',
                              style: TextStyle(color: Colors.blue[900]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_bankAccount == null || _isEditing)
                    _buildForm()
                  else
                    _buildBankAccountDisplay(),
                ],
              ),
            ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bank Account Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Bank Name Dropdown
          DropdownButtonFormField<String>(
            value: _nepaliBanks.contains(_bankNameController.text)
                ? _bankNameController.text
                : null,
            decoration: const InputDecoration(
              labelText: 'Bank Name *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_balance),
            ),
            items: _nepaliBanks.map((bank) {
              return DropdownMenuItem(
                value: bank,
                child: Text(bank),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                _bankNameController.text = value;
              }
            },
            validator: (value) {
              if (_bankNameController.text.isEmpty) {
                return 'Please select a bank';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Account Name
          TextFormField(
            controller: _accountNameController,
            decoration: const InputDecoration(
              labelText: 'Account Holder Name *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
              hintText: 'As per bank records',
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter account holder name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Account Number
          TextFormField(
            controller: _accountNumberController,
            decoration: const InputDecoration(
              labelText: 'Account Number *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.numbers),
              hintText: 'Enter your account number',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter account number';
              }
              if (value.length < 10) {
                return 'Account number must be at least 10 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Branch Name
          TextFormField(
            controller: _branchController,
            decoration: const InputDecoration(
              labelText: 'Branch Name (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
              hintText: 'e.g., New Road, Kathmandu',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),

          // SWIFT Code
          TextFormField(
            controller: _swiftCodeController,
            decoration: const InputDecoration(
              labelText: 'SWIFT/BIC Code (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.code),
              hintText: 'For international transfers',
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saveBankAccount,
              icon: const Icon(Icons.save),
              label: Text(_bankAccount == null ? 'Save Bank Account' : 'Update Bank Account'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700],
                foregroundColor: Colors.white,
              ),
            ),
          ),

          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _isEditing = false);
                    _loadBankAccount();
                  },
                  child: const Text('Cancel'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBankAccountDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Saved Bank Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_bankAccount!.isVerified)
              Chip(
                label: const Text('Verified'),
                avatar: const Icon(Icons.verified, size: 16, color: Colors.white),
                backgroundColor: Colors.green,
                labelStyle: const TextStyle(color: Colors.white),
              )
            else
              Chip(
                label: const Text('Pending Verification'),
                avatar: const Icon(Icons.pending, size: 16, color: Colors.white),
                backgroundColor: Colors.orange,
                labelStyle: const TextStyle(color: Colors.white),
              ),
          ],
        ),
        const SizedBox(height: 20),

        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(Icons.account_balance, 'Bank Name', _bankAccount!.bankName),
                const Divider(height: 32),
                _buildDetailRow(Icons.person, 'Account Holder', _bankAccount!.accountName),
                const Divider(height: 32),
                _buildDetailRow(Icons.numbers, 'Account Number', _bankAccount!.accountNumber),
                if (_bankAccount!.branchName != null) ...[
                  const Divider(height: 32),
                  _buildDetailRow(Icons.location_on, 'Branch', _bankAccount!.branchName!),
                ],
                if (_bankAccount!.swiftCode != null) ...[
                  const Divider(height: 32),
                  _buildDetailRow(Icons.code, 'SWIFT Code', _bankAccount!.swiftCode!),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        if (!_bankAccount!.isVerified)
          Card(
            color: Colors.orange[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your bank account is pending verification. You will be able to receive payments once verified by the admin.',
                      style: TextStyle(color: Colors.orange[900]),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal[700], size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
