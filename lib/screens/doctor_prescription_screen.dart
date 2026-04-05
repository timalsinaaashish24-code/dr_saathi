import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/prescription.dart';
import '../models/patient.dart';
import '../services/digital_prescription_service.dart';
import '../services/database_service.dart';
import '../generated/l10n/app_localizations.dart';

class DoctorPrescriptionScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String? doctorLicenseNumber;
  final Patient? selectedPatient;

  const DoctorPrescriptionScreen({
    super.key,
    this.doctorId = 'DOC001',
    this.doctorName = 'Dr. Default',
    this.doctorLicenseNumber,
    this.selectedPatient,
  });

  @override
  State<DoctorPrescriptionScreen> createState() => _DoctorPrescriptionScreenState();
}

class _DoctorPrescriptionScreenState extends State<DoctorPrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _digitalPrescriptionService = DigitalPrescriptionService();
  final _databaseService = DatabaseService();

  // Form controllers
  final _diagnosisController = TextEditingController();
  final _symptomsController = TextEditingController();
  final _notesController = TextEditingController();
  final _followUpController = TextEditingController();

  // Selected patient
  Patient? _selectedPatient;
  List<Patient> _patients = [];
  bool _isLoadingPatients = false;

  // Medications list
  final List<Medication> _medications = [];
  bool _isUrgent = false;
  bool _isLoading = false;

  // Medicine form controllers
  final _medicineNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _quantityController = TextEditingController();
  String _selectedForm = 'tablet';

  final List<String> _medicineFrequencies = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Four times daily',
    'As needed',
    'Before meals',
    'After meals',
    'At bedtime',
  ];

  final List<String> _medicineForms = [
    'tablet',
    'capsule',
    'syrup',
    'injection',
    'cream',
    'ointment',
    'drops',
    'inhaler',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPatient = widget.selectedPatient;
    _loadPatients();
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _symptomsController.dispose();
    _notesController.dispose();
    _followUpController.dispose();
    _medicineNameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoadingPatients = true;
    });

    try {
      final patients = await _databaseService.getAllPatients();
      setState(() {
        _patients = patients;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load patients: $e');
    } finally {
      setState(() {
        _isLoadingPatients = false;
      });
    }
  }

  void _showAddMedicineDialog() {
    // Clear controllers
    _medicineNameController.clear();
    _dosageController.clear();
    _frequencyController.text = _medicineFrequencies.first;
    _durationController.clear();
    _instructionsController.clear();
    _quantityController.clear();
    _selectedForm = _medicineForms.first;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add Medication'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _medicineNameController,
                  decoration: InputDecoration(
                    labelText: 'Medicine Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Medicine name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dosageController,
                        decoration: InputDecoration(
                          labelText: 'Dosage *',
                          hintText: '500mg',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Dosage is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedForm,
                        decoration: InputDecoration(
                          labelText: 'Form',
                          border: OutlineInputBorder(),
                        ),
                        items: _medicineForms.map((form) {
                          return DropdownMenuItem(
                            value: form,
                            child: Text(form.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            _selectedForm = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _frequencyController.text.isEmpty ? _medicineFrequencies.first : _frequencyController.text,
                      decoration: InputDecoration(
                        labelText: 'Frequency *',
                        border: OutlineInputBorder(),
                      ),
                      items: _medicineFrequencies.map((freq) {
                        return DropdownMenuItem(
                          value: freq,
                          child: Text(freq),
                        );
                      }).toList(),
                      onChanged: (value) {
                        _frequencyController.text = value!;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Quantity is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _durationController,
                  decoration: InputDecoration(
                    labelText: 'Duration *',
                    hintText: '7 days',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Duration is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _instructionsController,
                  decoration: InputDecoration(
                    labelText: 'Instructions',
                    hintText: 'Take with food',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addMedication,
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _addMedication() {
    if (_medicineNameController.text.trim().isEmpty ||
        _dosageController.text.trim().isEmpty ||
        _quantityController.text.trim().isEmpty ||
        _durationController.text.trim().isEmpty) {
      _showErrorSnackBar('Please fill all required fields');
      return;
    }

    final medication = Medication(
      name: _medicineNameController.text.trim(),
      dosage: _dosageController.text.trim(),
      frequency: _frequencyController.text,
      duration: _durationController.text.trim(),
      instructions: _instructionsController.text.trim(),
      form: _selectedForm,
      quantity: int.tryParse(_quantityController.text) ?? 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      _medications.add(medication);
    });

    Navigator.of(context).pop();
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  Future<void> _savePrescription({bool sendToPatient = false}) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPatient == null) {
      _showErrorSnackBar('Please select a patient');
      return;
    }

    if (_medications.isEmpty) {
      _showErrorSnackBar('Please add at least one medication');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prescription = await _digitalPrescriptionService.createPrescription(
        patientId: _selectedPatient!.id.toString(),
        patientName: '${_selectedPatient!.firstName} ${_selectedPatient!.lastName}',
        patientPhone: _selectedPatient!.phoneNumber,
        doctorName: widget.doctorName,
        doctorId: widget.doctorId,
        doctorLicenseNumber: widget.doctorLicenseNumber,
        diagnosis: _diagnosisController.text.trim(),
        symptoms: _symptomsController.text.trim().isNotEmpty ? _symptomsController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        medications: _medications,
        followUpDate: _followUpController.text.trim().isNotEmpty ? DateTime.tryParse(_followUpController.text.trim()) : null,
        isUrgent: _isUrgent,
      );

      // Add medications to the prescription
      for (final medication in _medications) {
        await _digitalPrescriptionService.addMedicationToPrescription(
          prescription.id!,
          medication,
        );
      }

      if (sendToPatient) {
        final success = await _digitalPrescriptionService.sendPrescriptionToPatient(prescription.id!);
        if (success) {
          _showSuccessSnackBar('Prescription sent to patient successfully');
        } else {
          _showErrorSnackBar('Prescription saved but failed to send to patient');
        }
      } else {
        _showSuccessSnackBar('Prescription saved as draft');
      }

      Navigator.of(context).pop();
    } catch (e) {
      _showErrorSnackBar('Failed to save prescription: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Prescription'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Selection
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Patient Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      if (_isLoadingPatients)
                        Center(child: CircularProgressIndicator())
                      else
                        DropdownButtonFormField<Patient>(
                          value: _selectedPatient,
                          decoration: InputDecoration(
                            labelText: 'Select Patient *',
                            border: OutlineInputBorder(),
                          ),
                          items: _patients.map((patient) {
                            return DropdownMenuItem(
                              value: patient,
                              child: Text('${patient.firstName} ${patient.lastName}'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPatient = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a patient';
                            }
                            return null;
                          },
                        ),
                      if (_selectedPatient != null) ...[
                        SizedBox(height: 8),
                        Text(
                          'Phone: ${_selectedPatient!.phoneNumber}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          'Age: ${_selectedPatient!.age}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Diagnosis and Symptoms
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medical Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _diagnosisController,
                        decoration: InputDecoration(
                          labelText: 'Diagnosis *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Diagnosis is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _symptomsController,
                        decoration: InputDecoration(
                          labelText: 'Symptoms',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'General Notes',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _followUpController,
                              decoration: InputDecoration(
                                labelText: 'Follow-up Date',
                                hintText: 'YYYY-MM-DD',
                                border: OutlineInputBorder(),
                              ),
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now().add(Duration(days: 7)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(Duration(days: 365)),
                                );
                                if (date != null) {
                                  _followUpController.text = date.toString().split(' ')[0];
                                }
                              },
                              readOnly: true,
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Urgent?'),
                              Switch(
                                value: _isUrgent,
                                onChanged: (value) {
                                  setState(() {
                                    _isUrgent = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Medications
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Medications',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          ElevatedButton.icon(
                            onPressed: _showAddMedicineDialog,
                            icon: Icon(Icons.add),
                            label: Text('Add Medicine'),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      if (_medications.isEmpty)
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'No medications added yet',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _medications.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (context, index) {
                            final medication = _medications[index];
                            return ListTile(
                              title: Text(medication.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${medication.dosage} ${medication.form} - ${medication.frequency}'),
                                  Text('Duration: ${medication.duration} | Quantity: ${medication.quantity}'),
                                  if (medication.instructions.isNotEmpty)
                                    Text('Instructions: ${medication.instructions}'),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeMedication(index),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => _savePrescription(sendToPatient: false),
                      child: _isLoading 
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text('Save Draft'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _savePrescription(sendToPatient: true),
                      child: _isLoading 
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text('Send to Patient'),
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
}
