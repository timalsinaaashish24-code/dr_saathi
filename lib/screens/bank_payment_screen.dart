import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For clipboard functionality
import 'video_call_screen.dart';
import '../models/communication.dart';

class BankPaymentScreen extends StatefulWidget {
  final String? doctorId;
  final String? appointmentId;
  final double amount;
  final String serviceType;
  final String serviceName;
  final Map<String, dynamic>? customerInfo;

  const BankPaymentScreen({
    Key? key,
    this.doctorId,
    this.appointmentId,
    required this.amount,
    required this.serviceType,
    required this.serviceName,
    this.customerInfo,
  }) : super(key: key);

  @override
  _BankPaymentScreenState createState() => _BankPaymentScreenState();
}

class _BankPaymentScreenState extends State<BankPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitted = false;
  
  // Bank details form controllers
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountHolderController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _swiftCodeController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _amountPaidController = TextEditingController();
  final TextEditingController _transactionIdController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  // My bank account details (you can update these with your actual details)
  final Map<String, String> myBankDetails = {
    'bankName': 'Nepal Investment Bank Ltd.',
    'accountHolder': 'Dr. Saathi Healthcare Pvt. Ltd.',
    'accountNumber': '01234567890123456',
    'swiftCode': 'NIBLNPKT',
    'branch': 'New Baneshwor Branch, Kathmandu',
  };

  @override
  void initState() {
    super.initState();
    _amountPaidController.text = widget.amount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _swiftCodeController.dispose();
    _branchController.dispose();
    _amountPaidController.dispose();
    _transactionIdController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Transfer Payment'),
        backgroundColor: Colors.lightBlue[600],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Summary Card
            _buildPaymentSummaryCard(),
            
            const SizedBox(height: 20),
            
            // My Bank Details Card
            _buildMyBankDetailsCard(),
            
            const SizedBox(height: 20),
            
            // Instructions Card
            _buildInstructionsCard(),
            
            const SizedBox(height: 20),
            
            // Payment Confirmation Form
            _buildPaymentConfirmationForm(),
            
            const SizedBox(height: 30),
            
            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getServiceIcon(),
                  color: Colors.lightBlue[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Payment Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Service', widget.serviceName),
            _buildSummaryRow('Type', _getServiceTypeDisplay()),
            if (widget.doctorId != null)
              _buildSummaryRow('Doctor ID', widget.doctorId!),
            if (widget.appointmentId != null)
              _buildSummaryRow('Appointment', widget.appointmentId!),
            const Divider(),
            _buildSummaryRow(
              'Total Amount',
              'NPR ${widget.amount.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16 : 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16 : 14,
                color: isTotal ? Colors.lightBlue[600] : null,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyBankDetailsCard() {
    return Card(
      elevation: 4,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance,
                  color: Colors.green.shade600,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Transfer Money To',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBankDetailRow('Bank Name', myBankDetails['bankName']!),
            _buildBankDetailRow('Account Holder', myBankDetails['accountHolder']!),
            _buildBankDetailRow('Account Number', myBankDetails['accountNumber']!, copyable: true),
            _buildBankDetailRow('SWIFT Code', myBankDetails['swiftCode']!, copyable: true),
            _buildBankDetailRow('Branch', myBankDetails['branch']!),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please transfer exactly NPR ${widget.amount.toStringAsFixed(2)} and fill the form below after transfer',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetailRow(String label, String value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (copyable) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$label copied to clipboard'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.copy,
                      size: 16,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Payment Instructions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...[
              '1. Transfer the exact amount to the bank account above',
              '2. Keep your bank transfer receipt/screenshot',
              '3. Fill out the confirmation form below',
              '4. Submit the form to complete your payment',
              '5. You will receive confirmation within 24 hours',
            ].map((instruction) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                instruction,
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 13,
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentConfirmationForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Confirmation Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Your Bank Name
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Your Bank Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                  hintText: 'e.g. Nabil Bank, Standard Chartered',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your bank name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Your Account Holder Name
              TextFormField(
                controller: _accountHolderController,
                decoration: const InputDecoration(
                  labelText: 'Your Account Holder Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  hintText: 'As per bank records',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account holder name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Your Account Number (last 4 digits)
              TextFormField(
                controller: _accountNumberController,
                decoration: const InputDecoration(
                  labelText: 'Your Account Number (Last 4 digits) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                  hintText: 'e.g. 1234',
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter last 4 digits of account number';
                  }
                  if (value.length != 4) {
                    return 'Please enter exactly 4 digits';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Amount Transferred
              TextFormField(
                controller: _amountPaidController,
                decoration: const InputDecoration(
                  labelText: 'Amount Transferred (NPR) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the amount transferred';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount != widget.amount) {
                    return 'Amount must be exactly NPR ${widget.amount.toStringAsFixed(2)}';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Transaction ID/Reference
              TextFormField(
                controller: _transactionIdController,
                decoration: const InputDecoration(
                  labelText: 'Transaction ID/Reference Number *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt),
                  hintText: 'From your bank receipt',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter transaction ID or reference number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Additional Remarks
              TextFormField(
                controller: _remarkController,
                decoration: const InputDecoration(
                  labelText: 'Additional Remarks (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                  hintText: 'Any additional information',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitted ? null : _submitPaymentConfirmation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlue[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSubmitted
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Submitting...'),
                ],
              )
            : const Text(
                'Submit Payment Confirmation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  IconData _getServiceIcon() {
    switch (widget.serviceType) {
      case 'consultation':
        return Icons.medical_services;
      case 'prescription':
        return Icons.medication;
      case 'app_feature':
      case 'health_card':
        return Icons.mobile_friendly;
      default:
        return Icons.payment;
    }
  }

  String _getServiceTypeDisplay() {
    switch (widget.serviceType) {
      case 'consultation':
        return 'Doctor Consultation';
      case 'prescription':
        return 'Prescription Service';
      case 'app_feature':
        return 'App Feature';
      case 'health_card':
        return 'Digital Health Card';
      default:
        return 'Service';
    }
  }

  void _submitPaymentConfirmation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitted = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Create payment confirmation data
    final paymentData = {
      'service': widget.serviceName,
      'serviceType': widget.serviceType,
      'amount': widget.amount,
      'customerInfo': widget.customerInfo,
      'bankDetails': {
        'bankName': _bankNameController.text,
        'accountHolder': _accountHolderController.text,
        'accountNumber': '****${_accountNumberController.text}',
        'amountPaid': double.parse(_amountPaidController.text),
        'transactionId': _transactionIdController.text,
        'remarks': _remarkController.text,
      },
      'submittedAt': DateTime.now().toIso8601String(),
    };

    // Here you would normally send this data to your backend API
    print('Payment confirmation submitted: $paymentData');

    setState(() {
      _isSubmitted = false;
    });

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    final isConsultation = widget.serviceType == 'consultation';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 48,
        ),
        title: const Text('Payment Confirmation Submitted!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your payment confirmation has been submitted successfully.'),
            const SizedBox(height: 12),
            const Text('We will verify your payment within 24 hours and send you a confirmation.'),
            const SizedBox(height: 12),
            Text(
              'Amount: NPR ${widget.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (isConsultation) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Ready to start your consultation?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You can now connect with your doctor via video or audio call.',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          if (isConsultation) ...[
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      _launchVideoCall();
                    },
                    icon: const Icon(Icons.video_call, size: 18),
                    label: const Text('Video Call'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.lightBlue[600],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      _launchAudioCall();
                    },
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Audio Call'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close payment screen
            },
            child: Text(isConsultation ? 'Maybe Later' : 'OK'),
          ),
        ],
      ),
    );
  }

  void _launchVideoCall() {
    if (widget.doctorId != null && widget.appointmentId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(
            appointmentId: widget.appointmentId!,
            doctorId: widget.doctorId!,
            patientId: widget.customerInfo?['patientId'] ?? 'PAT001',
            doctorName: _extractDoctorName(),
            patientName: widget.customerInfo?['name'] ?? 'Patient',
            callType: CallType.video,
          ),
        ),
      );
    }
  }

  void _launchAudioCall() {
    if (widget.doctorId != null && widget.appointmentId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(
            appointmentId: widget.appointmentId!,
            doctorId: widget.doctorId!,
            patientId: widget.customerInfo?['patientId'] ?? 'PAT001',
            doctorName: _extractDoctorName(),
            patientName: widget.customerInfo?['name'] ?? 'Patient',
            callType: CallType.audio,
          ),
        ),
      );
    }
  }

  String _extractDoctorName() {
    // Extract doctor name from service name
    // Example: "Cardiology Consultation with Dr. Sita Patel" -> "Dr. Sita Patel"
    final serviceName = widget.serviceName;
    final withIndex = serviceName.indexOf(' with ');
    if (withIndex != -1 && withIndex + 6 < serviceName.length) {
      return serviceName.substring(withIndex + 6);
    }
    return 'Doctor';
  }
}
