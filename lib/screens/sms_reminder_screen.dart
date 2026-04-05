import 'package:flutter/material.dart';
import 'package:dr_saathi/generated/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import '../models/patient.dart';
import '../models/sms_reminder.dart';
import '../services/sms_service.dart';
import '../services/database_service.dart';

class SmsReminderScreen extends StatefulWidget {
  final Patient? patient;

  const SmsReminderScreen({super.key, this.patient});

  @override
  _SmsReminderScreenState createState() => _SmsReminderScreenState();
}

class _SmsReminderScreenState extends State<SmsReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final SmsService _smsService = SmsService();
  final DatabaseService _databaseService = DatabaseService();
  
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  
  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  SmsReminderType _selectedType = SmsReminderType.appointment;
  SmsTemplate? _selectedTemplate;
  List<SmsTemplate> _templates = [];
  List<Patient> _patients = [];
  Patient? _selectedPatient;
  bool _isLoading = false;
  bool _sendImmediately = false;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
    _loadPatients();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.patient != null) {
      _selectedPatient = widget.patient;
      _patientNameController.text = widget.patient!.fullName;
      _phoneController.text = widget.patient!.phoneNumber;
    }
  }

  Future<void> _loadTemplates() async {
    try {
      final templates = await _databaseService.getAllSmsTemplates();
      setState(() {
        _templates = templates;
      });
    } catch (e) {
      print('Error loading templates: $e');
    }
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await _databaseService.getAllPatients();
      setState(() {
        _patients = patients;
      });
      print('Loaded ${patients.length} patients'); // Debug info
    } catch (e) {
      print('Error loading patients: $e');
      _showSnackBar('Error loading patients: $e', Colors.red);
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _onTemplateSelected(SmsTemplate? template) {
    if (template != null) {
      setState(() {
        _selectedTemplate = template;
        _selectedType = template.type;
        _messageController.text = template.generateMessage(
          patientName: _patientNameController.text,
          clinicName: 'Dr. Saathi Clinic',
          appointmentTime: _selectedDateTime,
          doctorName: 'Dr. Smith',
          additionalInfo: '',
        );
      });
    }
  }

  void _onPatientSelected(Patient? patient) {
    if (patient != null) {
      setState(() {
        _selectedPatient = patient;
        _patientNameController.text = patient.fullName;
        _phoneController.text = patient.phoneNumber;
      });
    }
  }

  Future<void> _sendReminder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final reminder = SmsReminder(
        id: const Uuid().v4(),
        patientId: _selectedPatient?.id ?? '',
        patientName: _patientNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        message: _messageController.text.trim(),
        scheduledTime: _sendImmediately ? DateTime.now() : _selectedDateTime,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        type: _selectedType,
      );

      if (_sendImmediately) {
        await _smsService.sendImmediateSms(
          patientId: reminder.patientId,
          patientName: reminder.patientName,
          phoneNumber: reminder.phoneNumber,
          message: reminder.message,
          type: reminder.type,
        );
        
        _showSnackBar('SMS sent immediately!', Colors.green);
      } else {
        await _smsService.scheduleReminder(reminder);
        _showSnackBar('SMS reminder scheduled successfully!', Colors.green);
      }

      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.smsReminder),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _sendReminder,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Selection
              _buildSectionTitle('Patient Information'),
              if (widget.patient == null) ...[
                _patients.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.orange.withOpacity(0.1),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'No patients found',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Please register patients first, or enter patient details manually below.',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : DropdownButtonFormField<Patient>(
                        value: _selectedPatient,
                        decoration: const InputDecoration(
                          labelText: 'Select Patient',
                          border: OutlineInputBorder(),
                        ),
                        items: _patients.map((patient) {
                          return DropdownMenuItem(
                            value: patient,
                            child: Text('${patient.fullName} - ${patient.phoneNumber}'),
                          );
                        }).toList(),
                        onChanged: _onPatientSelected,
                        validator: (value) {
                          if (value == null && _patients.isNotEmpty) {
                            return 'Please select a patient';
                          }
                          return null;
                        },
                      ),
                const SizedBox(height: 16),
              ],

              // Patient Name
              TextFormField(
                controller: _patientNameController,
                decoration: const InputDecoration(
                  labelText: 'Patient Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter patient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Message Configuration
              _buildSectionTitle('Message Configuration'),
              
              // Reminder Type
              DropdownButtonFormField<SmsReminderType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Reminder Type',
                  border: OutlineInputBorder(),
                ),
                items: SmsReminderType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Template Selection
              DropdownButtonFormField<SmsTemplate>(
                value: _selectedTemplate,
                decoration: const InputDecoration(
                  labelText: 'Message Template (Optional)',
                  border: OutlineInputBorder(),
                ),
                items: _templates.where((t) => t.type == _selectedType).map((template) {
                  return DropdownMenuItem(
                    value: template,
                    child: Text(template.name),
                  );
                }).toList(),
                onChanged: _onTemplateSelected,
              ),
              const SizedBox(height: 16),

              // Message
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                  hintText: 'Enter your SMS message...',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Scheduling
              _buildSectionTitle('Scheduling'),
              
              // Send Immediately Toggle
              CheckboxListTile(
                title: const Text('Send Immediately'),
                value: _sendImmediately,
                onChanged: (value) {
                  setState(() {
                    _sendImmediately = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Date Time Selection
              if (!_sendImmediately) ...[
                GestureDetector(
                  onTap: _selectDateTime,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Schedule: ${_selectedDateTime.day}/${_selectedDateTime.month}/${_selectedDateTime.year} at ${_selectedDateTime.hour}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendReminder,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Text(_sendImmediately ? 'Send SMS' : 'Schedule SMS'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _phoneController.dispose();
    _patientNameController.dispose();
    super.dispose();
  }
}
