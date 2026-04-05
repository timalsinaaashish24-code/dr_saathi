import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import '../models/prescription.dart';
import '../models/patient.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';

class PrescriptionFormScreen extends StatefulWidget {
  final Patient patient;
  final Prescription? existingPrescription;

  const PrescriptionFormScreen({
    super.key,
    required this.patient,
    this.existingPrescription,
  });

  @override
  State<PrescriptionFormScreen> createState() => _PrescriptionFormScreenState();
}

class _PrescriptionFormScreenState extends State<PrescriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _databaseService = DatabaseService();
  
  late TextEditingController _diagnosisController;
  late TextEditingController _notesController;
  late TextEditingController _doctorNameController;
  late TextEditingController _doctorIdController;
  DateTime _prescriptionDate = DateTime.now();
  DateTime? _followUpDate;
  PrescriptionStatus _status = PrescriptionStatus.draft;
  
  List<Medication> _medications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (widget.existingPrescription != null) {
      _loadExistingPrescription();
    }
  }

  void _initializeControllers() {
    _diagnosisController = TextEditingController();
    _notesController = TextEditingController();
    _doctorNameController = TextEditingController(text: 'Dr. Saathi');
    _doctorIdController = TextEditingController(text: 'DOC001');
  }

  void _loadExistingPrescription() {
    final prescription = widget.existingPrescription!;
    _diagnosisController.text = prescription.diagnosis;
    _notesController.text = prescription.notes;
    _doctorNameController.text = prescription.doctorName;
    _doctorIdController.text = prescription.doctorId;
    _prescriptionDate = prescription.prescriptionDate;
    _followUpDate = prescription.followUpDate;
    _status = prescription.status;
    _medications = List.from(prescription.medications);
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _notesController.dispose();
    _doctorNameController.dispose();
    _doctorIdController.dispose();
    super.dispose();
  }

  void _addMedication() {
    setState(() {
      _medications.add(Medication(
        name: '',
        dosage: '',
        frequency: '',
        duration: '',
        instructions: '',
        quantity: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    });
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isFollowUp) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFollowUp ? _followUpDate ?? DateTime.now() : _prescriptionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFollowUp) {
          _followUpDate = picked;
        } else {
          _prescriptionDate = picked;
        }
      });
    }
  }

  Future<void> _savePrescription() async {
    if (!_formKey.currentState!.validate()) return;
    if (_medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one medication')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final prescription = Prescription(
        id: widget.existingPrescription?.id,
        patientId: widget.patient.id,
        patientName: '${widget.patient.firstName} ${widget.patient.lastName}',
        doctorName: _doctorNameController.text,
        doctorId: _doctorIdController.text,
        prescriptionDate: _prescriptionDate,
        diagnosis: _diagnosisController.text,
        notes: _notesController.text,
        medications: _medications,
        status: _status,
        followUpDate: _followUpDate,
        createdAt: widget.existingPrescription?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.existingPrescription == null) {
        await _databaseService.insertPrescription(prescription);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription created successfully')),
        );
      } else {
        await _databaseService.updatePrescription(prescription);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription updated successfully')),
        );
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving prescription: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _previewPrescription() async {
    if (!_formKey.currentState!.validate()) return;
    if (_medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one medication')),
      );
      return;
    }

    try {
      final now = DateTime.now();
      final prescription = Prescription(
        id: widget.existingPrescription?.id ?? 0,
        patientId: widget.patient.id,
        patientName: '${widget.patient.firstName} ${widget.patient.lastName}',
        doctorName: _doctorNameController.text,
        doctorId: _doctorIdController.text,
        prescriptionDate: _prescriptionDate,
        diagnosis: _diagnosisController.text,
        notes: _notesController.text,
        medications: _medications,
        status: _status,
        followUpDate: _followUpDate,
        createdAt: widget.existingPrescription?.createdAt ?? now,
        updatedAt: now,
      );

      await PdfService.printPrescription(prescription, widget.patient);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error previewing prescription: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingPrescription == null 
            ? 'Create Prescription' 
            : 'Edit Prescription'),
        actions: [
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: _previewPrescription,
            tooltip: 'Preview PDF',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Patient Information',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text('Name: ${widget.patient.firstName} ${widget.patient.lastName}'),
                            Text('Age: ${widget.patient.age} years'),
                            Text('Phone: ${widget.patient.phoneNumber}'),
                            if (widget.patient.allergies.isNotEmpty == true)
                              Text('Allergies: ${widget.patient.allergies}',
                                  style: const TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Doctor Information
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Doctor Information',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _doctorNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Doctor Name',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: ValidationBuilder().required().build(),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _doctorIdController,
                                    decoration: const InputDecoration(
                                      labelText: 'Doctor ID',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: ValidationBuilder().required().build(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Prescription Details
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prescription Details',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _diagnosisController,
                              decoration: const InputDecoration(
                                labelText: 'Diagnosis',
                                border: OutlineInputBorder(),
                              ),
                              validator: ValidationBuilder().required().build(),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: const Text('Prescription Date'),
                                    subtitle: Text(
                                      _prescriptionDate.toString().split(' ')[0],
                                    ),
                                    trailing: const Icon(Icons.calendar_today),
                                    onTap: () => _selectDate(context, false),
                                  ),
                                ),
                                Expanded(
                                  child: ListTile(
                                    title: const Text('Follow-up Date'),
                                    subtitle: Text(
                                      _followUpDate?.toString().split(' ')[0] ?? 'Not set',
                                    ),
                                    trailing: const Icon(Icons.calendar_today),
                                    onTap: () => _selectDate(context, true),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<PrescriptionStatus>(
                              value: _status,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                              ),
                              items: [PrescriptionStatus.draft, PrescriptionStatus.sent, PrescriptionStatus.completed, PrescriptionStatus.cancelled]
                                  .map((status) => DropdownMenuItem(
                                        value: status,
                                        child: Text(status.name.toUpperCase()),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _status = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                labelText: 'Additional Notes',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Medications Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Medications',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                ElevatedButton.icon(
                                  onPressed: _addMedication,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Medication'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ..._medications.asMap().entries.map((entry) {
                              final index = entry.key;
                              final medication = entry.value;
                              return _buildMedicationCard(index, medication);
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _savePrescription,
                        child: Text(widget.existingPrescription == null 
                            ? 'Create Prescription' 
                            : 'Update Prescription'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMedicationCard(int index, Medication medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Medication ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeMedication(index),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: medication.name,
              decoration: const InputDecoration(
                labelText: 'Medicine Name',
                border: OutlineInputBorder(),
              ),
              validator: ValidationBuilder().required().build(),
              onChanged: (value) {
                _medications[index] = medication.copyWith(name: value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: medication.dosage,
                    decoration: const InputDecoration(
                      labelText: 'Dosage',
                      border: OutlineInputBorder(),
                    ),
                    validator: ValidationBuilder().required().build(),
                    onChanged: (value) {
                      _medications[index] = medication.copyWith(dosage: value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: medication.form.isEmpty ? 'tablet' : medication.form,
                    decoration: const InputDecoration(
                      labelText: 'Form',
                      border: OutlineInputBorder(),
                    ),
                    items: ['tablet', 'capsule', 'syrup', 'injection', 'drops']
                        .map((form) => DropdownMenuItem(
                              value: form,
                              child: Text(form.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (value) {
                      _medications[index] = medication.copyWith(form: value!);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: medication.frequency,
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      hintText: 'e.g., 2 times daily',
                      border: OutlineInputBorder(),
                    ),
                    validator: ValidationBuilder().required().build(),
                    onChanged: (value) {
                      _medications[index] = medication.copyWith(frequency: value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: medication.duration,
                    decoration: const InputDecoration(
                      labelText: 'Duration',
                      hintText: 'e.g., 7 days',
                      border: OutlineInputBorder(),
                    ),
                    validator: ValidationBuilder().required().build(),
                    onChanged: (value) {
                      _medications[index] = medication.copyWith(duration: value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: medication.quantity.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: ValidationBuilder().required().build(),
                    onChanged: (value) {
                      _medications[index] = medication.copyWith(
                        quantity: int.tryParse(value) ?? 1,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: medication.genericName ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Generic Name (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _medications[index] = medication.copyWith(genericName: value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: medication.instructions,
              decoration: const InputDecoration(
                labelText: 'Instructions',
                hintText: 'e.g., Take after meals',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) {
                _medications[index] = medication.copyWith(instructions: value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
