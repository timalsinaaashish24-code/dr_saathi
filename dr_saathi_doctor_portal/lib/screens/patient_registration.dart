import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:dr_saathi_doctor_portal/generated/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/patient.dart';
import '../models/insurance.dart';
import '../services/database_service.dart';
import '../widgets/insurance_form_widget.dart';
import '../screens/bank_payment_screen.dart';

class PatientRegistration extends StatefulWidget {
  final Patient? patient; // For editing existing patient
  
  const PatientRegistration({Key? key, this.patient}) : super(key: key);

  @override
  _PatientRegistrationState createState() => _PatientRegistrationState();
}

class _PatientRegistrationState extends State<PatientRegistration> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  bool _isOffline = false;
  bool _isLoading = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  DateTime? _selectedDateOfBirth;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _medicalHistoryController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  
  Insurance? _insurance;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadPatientData();
  }
  
  void _loadPatientData() {
    if (widget.patient != null) {
      final patient = widget.patient!;
      _firstNameController.text = patient.firstName;
      _lastNameController.text = patient.lastName;
      _selectedDateOfBirth = patient.dateOfBirth;
      _dateOfBirthController.text = _formatDate(patient.dateOfBirth);
      _phoneNumberController.text = patient.phoneNumber;
      _emailController.text = patient.email;
      _addressController.text = patient.address;
      _emergencyContactController.text = patient.emergencyContact;
      _medicalHistoryController.text = patient.medicalHistory;
      _allergiesController.text = patient.allergies;
      _insurance = patient.insurance;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 25)), // Default to 25 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select Date of Birth',
      cancelText: 'Cancel',
      confirmText: 'OK',
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dateOfBirthController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = connectivityResult.contains(ConnectivityResult.none);
    });
  }

  Future<void> _registerPatient() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final now = DateTime.now();
        final isEditing = widget.patient != null;
        
        final patient = Patient(
          id: isEditing ? widget.patient!.id : const Uuid().v4(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          dateOfBirth: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 30)), // Default to 30 years ago
          phoneNumber: _phoneNumberController.text.trim(),
          email: _emailController.text.trim(),
          address: _addressController.text.trim(),
          emergencyContact: _emergencyContactController.text.trim(),
          medicalHistory: _medicalHistoryController.text.trim(),
          allergies: _allergiesController.text.trim(),
          insurance: _insurance,
          createdAt: isEditing ? widget.patient!.createdAt : now,
          updatedAt: now,
          synced: !_isOffline, // Mark as synced if online
        );

        if (isEditing) {
          await _databaseService.updatePatient(patient);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.patientUpdated),
            backgroundColor: Colors.green,
          ));
          Navigator.pop(context, patient); // Return updated patient
        } else {
          await _databaseService.insertPatient(patient);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.patientRegistered),
            backgroundColor: Colors.green,
          ));
          // Clear the form for new registration
          _clearForm();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _dateOfBirthController.clear();
    _phoneNumberController.clear();
    _emailController.clear();
    _addressController.clear();
    _emergencyContactController.clear();
    _medicalHistoryController.clear();
    _allergiesController.clear();
    setState(() {
      _insurance = null;
      _selectedDateOfBirth = null;
    });
    _formKey.currentState?.reset();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _medicalHistoryController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient != null 
            ? AppLocalizations.of(context)!.editPatient 
            : AppLocalizations.of(context)!.patientRegistration),
        actions: [
          if (_isOffline)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: Text(AppLocalizations.of(context)!.offlineMode),
                backgroundColor: Colors.orange,
                labelStyle: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_isOffline)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.syncPending,
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.firstName,
                  border: const OutlineInputBorder(),
                ),
                validator: ValidationBuilder().required(AppLocalizations.of(context)!.requiredField).build(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.lastName,
                  border: const OutlineInputBorder(),
                ),
                validator: ValidationBuilder().required(AppLocalizations.of(context)!.requiredField).build(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateOfBirthController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today),
                  hintText: 'DD/MM/YYYY',
                ),
                readOnly: true,
                onTap: _selectDateOfBirth,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select date of birth';
                  }
                  return null;
                },
              ),
              if (_selectedDateOfBirth != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Age: ${DateTime.now().year - _selectedDateOfBirth!.year} years',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.phoneNumber,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: ValidationBuilder().phone(AppLocalizations.of(context)!.invalidPhoneNumber).build(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.email,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: ValidationBuilder().email('Please enter a valid email address').build(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.address,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emergencyContactController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.emergencyContact,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _medicalHistoryController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.medicalHistory,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _allergiesController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.allergies,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              // Insurance Information Widget
              InsuranceFormWidget(
                initialInsurance: _insurance,
                onInsuranceChanged: (insurance) {
                  setState(() {
                    _insurance = insurance;
                  });
                },
                isRequired: false,
              ),
              
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _registerPatient,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.patient != null 
                            ? AppLocalizations.of(context)!.update 
                            : AppLocalizations.of(context)!.register,
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            const SizedBox(height: 24),
            
            // Free Registration Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Free Patient Registration',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Registration is completely free! No charges for creating your patient profile.',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Optional Premium Services
            Text(
              'Optional Premium Services',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            
            // Digital Health Card Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.credit_card, color: Colors.blue.shade600, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Digital Health Card',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your complete digital health identity with:',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...['• Unique Health ID with QR code',
                      '• Secure cloud storage of medical records',
                      '• Emergency medical information access',
                      '• Multi-device synchronization',
                      '• Insurance integration',
                      '• Priority appointment booking'].map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      feature,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 12,
                      ),
                    ),
                  )).toList(),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Digital Health Card - Optional Premium Service
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
builder: (context) => BankPaymentScreen(
                      doctorId: null,
                      appointmentId: null,
                      amount: 150.0,  // Health card fee
                      serviceType: 'health_card',
                      serviceName: 'Digital Health Card',
                      customerInfo: {
                        'name': _firstNameController.text.trim(),
                        'email': _emailController.text.trim(),
                        'phone': _phoneNumberController.text.trim(),
                        'patientId': 'CARD-${DateTime.now().millisecondsSinceEpoch}',
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.credit_card),
              label: const Text('Get Digital Health Card (NPR 150)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Divider
            const Divider(
              thickness: 1,
              color: Colors.grey,
            ),
            
            const SizedBox(height: 16),
            
            TextButton(
              onPressed: _isLoading ? null : () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
