import 'package:flutter/material.dart';
import 'package:dr_saathi/models/payment.dart';
import 'package:dr_saathi/services/payment_service.dart';
import 'package:dr_saathi/services/esewa_service.dart';
import 'package:dr_saathi/services/khalti_service.dart';
import 'package:uuid/uuid.dart';

class PaymentScreen extends StatefulWidget {
  final String? doctorId;
  final String? appointmentId;
  final double amount;
  final String serviceType; // 'consultation', 'prescription', 'app_feature'
  final String serviceName;
  final Map<String, dynamic>? customerInfo;

  const PaymentScreen({
    Key? key,
    this.doctorId,
    this.appointmentId,
    required this.amount,
    required this.serviceType,
    required this.serviceName,
    this.customerInfo,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  String? _selectedPaymentMethod;
  bool _isProcessing = false;
  
  // Customer information
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.customerInfo?['name'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.customerInfo?['email'] ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.customerInfo?['phone'] ?? '',
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
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
            
            // Customer Information
            _buildCustomerInfoSection(),
            
            const SizedBox(height: 20),
            
            // Payment Methods
            _buildPaymentMethodsSection(),
            
            const SizedBox(height: 30),
            
            // Payment Button
            if (_selectedPaymentMethod != null)
              _buildPaymentButton(),
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
  
  Widget _buildCustomerInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentMethodsSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Payment Method',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // eSewa Option
            _buildPaymentOption(
              id: 'esewa',
              name: 'eSewa',
              description: 'Digital wallet payment',
              logoPath: 'assets/images/payment_logos/esewa_logo.png',
              color: Colors.green,
              isRecommended: true,
            ),
            
            const SizedBox(height: 12),
            
            // Khalti Option
            _buildPaymentOption(
              id: 'khalti',
              name: 'Khalti',
              description: 'Mobile wallet payment',
              logoPath: 'assets/images/payment_logos/khalti_logo.png',
              color: Colors.purple,
            ),
            
            const SizedBox(height: 12),
            
            // IME Pay Option
            _buildPaymentOption(
              id: 'ime',
              name: 'IME Pay',
              description: 'Bank transfer and wallet',
              logoPath: 'assets/images/payment_logos/ime_pay_logo.png',
              color: Colors.blue,
            ),
            
            const SizedBox(height: 12),
            
            // ConnectIPS Option
            _buildPaymentOption(
              id: 'connectips',
              name: 'ConnectIPS',
              description: 'Internet banking',
              logoPath: 'assets/images/payment_logos/connectips_logo.png',
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentOption({
    required String id,
    required String name,
    required String description,
    required String logoPath,
    required Color color,
    bool isRecommended = false,
  }) {
    final isSelected = _selectedPaymentMethod == id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? color.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  logoPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to icon if image fails to load
                    return Icon(
                      _getPaymentIcon(id),
                      color: color,
                      size: 24,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'RECOMMENDED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: id,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getPaymentIcon(String id) {
    switch (id) {
      case 'esewa':
        return Icons.account_balance_wallet;
      case 'khalti':
        return Icons.phone_android;
      case 'ime':
        return Icons.account_balance;
      case 'connectips':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }
  
  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlue[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isProcessing
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
                  Text('Processing...'),
                ],
              )
            : Text(
                'Pay NPR ${widget.amount.toStringAsFixed(2)} with ${_getPaymentMethodName()}',
                style: const TextStyle(
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
      default:
        return 'Service';
    }
  }
  
  String _getPaymentMethodName() {
    switch (_selectedPaymentMethod) {
      case 'esewa':
        return 'eSewa';
      case 'khalti':
        return 'Khalti';
      case 'ime':
        return 'IME Pay';
      case 'connectips':
        return 'ConnectIPS';
      default:
        return 'Selected Method';
    }
  }
  
  void _processPayment() async {
    // Validate customer information
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all customer information'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // Create payment object
      final payment = Payment(
        id: const Uuid().v4(),
        patientId: widget.customerInfo?['patientId'] ?? 'guest',
        doctorId: widget.doctorId ?? 'system',
        appointmentId: widget.appointmentId ?? '',
        amount: widget.amount,
        currency: 'NPR',
        paymentMethod: _getPaymentMethodName(),
        paymentGateway: _selectedPaymentMethod!,
        status: PaymentStatus.pending,
        transactionId: '',
        gatewayTransactionId: '',
        gatewayResponse: {},
        createdAt: DateTime.now(),
      );
      
      // Process payment based on selected method
      if (_selectedPaymentMethod == 'esewa') {
        _processESewaPayment(payment);
      } else if (_selectedPaymentMethod == 'khalti') {
        _processKhaltiPayment(payment);
      } else {
        // For other payment methods, show coming soon
        _showComingSoonDialog();
      }
    } catch (e) {
      _showErrorDialog('Payment initialization failed: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  void _processESewaPayment(Payment payment) {
    ESewaService.launchPayment(
      context: context,
      payment: payment,
      onPaymentComplete: (success, refId) {
        if (success && refId != null) {
          _showSuccessDialog(refId);
        } else {
          _showErrorDialog('eSewa payment failed');
        }
      },
    );
  }
  
  void _processKhaltiPayment(Payment payment) {
    KhaltiService.launchPayment(
      context: context,
      payment: payment,
      customerName: _nameController.text,
      customerEmail: _emailController.text,
      customerPhone: _phoneController.text,
      onPaymentComplete: (success, pidx) {
        if (success && pidx != null) {
          _showSuccessDialog(pidx);
        } else {
          _showErrorDialog('Khalti payment failed');
        }
      },
    );
  }
  
  void _showSuccessDialog(String transactionId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 48,
        ),
        title: const Text('Payment Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Transaction ID: $transactionId'),
            const SizedBox(height: 8),
            Text('Amount: NPR ${widget.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            const Text('Your payment has been processed successfully.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close payment screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.error,
          color: Colors.red,
          size: 48,
        ),
        title: const Text('Payment Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.info,
          color: Colors.blue,
          size: 48,
        ),
        title: const Text('Coming Soon'),
        content: Text('${_getPaymentMethodName()} integration is coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
