import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/prescription.dart';
import '../models/patient.dart';
import '../services/database_service.dart';

class BrandedPrescriptionScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorNMC;
  final String? doctorSpecialization;
  final String? doctorPhone;
  final String? doctorEmail;

  const BrandedPrescriptionScreen({
    Key? key,
    required this.doctorId,
    required this.doctorName,
    required this.doctorNMC,
    this.doctorSpecialization,
    this.doctorPhone,
    this.doctorEmail,
  }) : super(key: key);

  @override
  State<BrandedPrescriptionScreen> createState() => _BrandedPrescriptionScreenState();
}

class _BrandedPrescriptionScreenState extends State<BrandedPrescriptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();

  // Form controllers
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();
  
  Patient? _selectedPatient;
  List<Patient> _patients = [];
  List<MedicationItem> _medications = [];
  bool _isLoadingPatients = false;
  DateTime _prescriptionDate = DateTime.now();
  pw.ImageProvider? _logoImage;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoadingPatients = true);
    try {
      final patients = await _databaseService.getAllPatients();
      setState(() => _patients = patients);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading patients: $e')),
      );
    } finally {
      setState(() => _isLoadingPatients = false);
    }
  }

  void _addMedication() {
    showDialog(
      context: context,
      builder: (context) => _MedicationDialog(
        onAdd: (medication) {
          setState(() => _medications.add(medication));
        },
      ),
    );
  }

  void _showPreview() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient')),
      );
      return;
    }
    if (_medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one medication')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Prescription Preview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _generatePrescriptionPDF();
                        },
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Generate PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildPreviewContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue[700]!, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/dr_saathi_icon.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. Saathi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  Text(
                    'Your Health Companion',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'PRESCRIPTION',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  Text(
                    'Date: ${DateFormat('dd MMM yyyy').format(_prescriptionDate)}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 2),
          const SizedBox(height: 20),
          
          // Doctor details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctorName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.doctorSpecialization != null)
                  Text(
                    widget.doctorSpecialization!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                const SizedBox(height: 4),
                Text(
                  'NMC Reg. No: ${widget.doctorNMC}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                if (widget.doctorPhone != null)
                  Text(
                    'Phone: ${widget.doctorPhone}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                if (widget.doctorEmail != null)
                  Text(
                    'Email: ${widget.doctorEmail}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Patient details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient Details',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Name: ${_selectedPatient!.firstName} ${_selectedPatient!.lastName}',
                  style: const TextStyle(fontSize: 11),
                ),
                Text(
                  'Age: ${_selectedPatient!.age} years',
                  style: const TextStyle(fontSize: 11),
                ),
                Text(
                  'Phone: ${_selectedPatient!.phoneNumber}',
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Diagnosis
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Diagnosis:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _diagnosisController.text,
                style: const TextStyle(fontSize: 11),
              ),
              if (_notesController.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text(
                  'Notes:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _notesController.text,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          
          // Medications table
          Table(
            border: TableBorder.all(color: Colors.grey[300]!),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1),
              4: FlexColumnWidth(2),
            },
            children: [
              // Header
              TableRow(
                decoration: BoxDecoration(color: Colors.blue[100]),
                children: [
                  _buildPreviewTableCell('Medication', isHeader: true),
                  _buildPreviewTableCell('Dosage', isHeader: true),
                  _buildPreviewTableCell('Frequency', isHeader: true),
                  _buildPreviewTableCell('Duration', isHeader: true),
                  _buildPreviewTableCell('Instructions', isHeader: true),
                ],
              ),
              // Data rows
              ..._medications.map((med) => TableRow(
                children: [
                  _buildPreviewTableCell(med.name),
                  _buildPreviewTableCell(med.dosage),
                  _buildPreviewTableCell(med.frequency),
                  _buildPreviewTableCell(med.duration),
                  _buildPreviewTableCell(med.instructions),
                ],
              )),
            ],
          ),
          const SizedBox(height: 30),
          
          // Signature
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 150,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey[800]!),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Column(
                        children: [
                          Text(
                            widget.doctorName,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'NMC: ${widget.doctorNMC}',
                            style: const TextStyle(fontSize: 9, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.blue[200]!)),
            ),
            child: const Center(
              child: Text(
                'This is a digitally generated prescription from Dr. Saathi platform',
                style: TextStyle(fontSize: 8, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Future<void> _generatePrescriptionPDF() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient')),
      );
      return;
    }
    if (_medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one medication')),
      );
      return;
    }

    try {
      // Load the logo image
      final ByteData imageData = await rootBundle.load('assets/images/dr_saathi_icon.png');
      final Uint8List imageBytes = imageData.buffer.asUint8List();
      _logoImage = pw.MemoryImage(imageBytes);
      
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header with logo and branding
                _buildPDFHeader(),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 20),
                
                // Doctor details
                _buildDoctorDetails(),
                pw.SizedBox(height: 20),
                
                // Patient details
                _buildPatientDetails(),
                pw.SizedBox(height: 20),
                
                // Prescription details
                _buildPrescriptionDetails(),
                pw.SizedBox(height: 20),
                
                // Medications table
                _buildMedicationsTable(),
                pw.SizedBox(height: 30),
                
                // Doctor signature
                _buildSignature(),
                
                pw.Spacer(),
                
                // Footer
                _buildFooter(),
              ],
            );
          },
        ),
      );

      // Save PDF
      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/prescription_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Prescription saved: ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating prescription: $e')),
        );
      }
    }
  }

  pw.Widget _buildPDFHeader() {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Dr. Saathi Logo
        pw.Container(
          width: 60,
          height: 60,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            border: pw.Border.all(color: PdfColors.blue700, width: 2),
          ),
          child: pw.ClipOval(
            child: pw.Image(
              _logoImage!,
              width: 60,
              height: 60,
              fit: pw.BoxFit.cover,
            ),
          ),
        ),
        pw.SizedBox(width: 15),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Dr. Saathi',
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Your Health Companion',
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.blue700,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ],
        ),
        pw.Spacer(),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'PRESCRIPTION',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Date: ${DateFormat('dd MMM yyyy').format(_prescriptionDate)}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildDoctorDetails() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            widget.doctorName,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          if (widget.doctorSpecialization != null)
            pw.Text(
              widget.doctorSpecialization!,
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
          pw.SizedBox(height: 4),
          pw.Text(
            'NMC Reg. No: ${widget.doctorNMC}',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          if (widget.doctorPhone != null) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              'Phone: ${widget.doctorPhone}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
          if (widget.doctorEmail != null) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              'Email: ${widget.doctorEmail}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildPatientDetails() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Patient Details',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Name: ${_selectedPatient!.firstName} ${_selectedPatient!.lastName}',
                  style: const pw.TextStyle(fontSize: 11),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Age: ${_selectedPatient!.age} years',
                  style: const pw.TextStyle(fontSize: 11),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Phone: ${_selectedPatient!.phoneNumber}',
                  style: const pw.TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPrescriptionDetails() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Diagnosis:',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          _diagnosisController.text,
          style: const pw.TextStyle(fontSize: 11),
        ),
        if (_notesController.text.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Text(
            'Notes:',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            _notesController.text,
            style: const pw.TextStyle(fontSize: 11),
          ),
        ],
      ],
    );
  }

  pw.Widget _buildMedicationsTable() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue100),
          children: [
            _buildTableCell('Medication', isHeader: true),
            _buildTableCell('Dosage', isHeader: true),
            _buildTableCell('Frequency', isHeader: true),
            _buildTableCell('Duration', isHeader: true),
            _buildTableCell('Instructions', isHeader: true),
          ],
        ),
        // Data rows
        ..._medications.map((med) => pw.TableRow(
          children: [
            _buildTableCell(med.name),
            _buildTableCell(med.dosage),
            _buildTableCell(med.frequency),
            _buildTableCell(med.duration),
            _buildTableCell(med.instructions),
          ],
        )),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _buildSignature() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SizedBox(height: 40),
            pw.Container(
              width: 150,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: PdfColors.grey800),
                ),
              ),
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(top: 5),
                child: pw.Column(
                  children: [
                    pw.Text(
                      widget.doctorName,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'NMC: ${widget.doctorNMC}',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.blue200)),
      ),
      child: pw.Center(
        child: pw.Text(
          'This is a digitally generated prescription from Dr. Saathi platform',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Prescription'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: _showPreview,
            tooltip: 'Preview',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePrescriptionPDF,
            tooltip: 'Generate PDF',
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
              // Branding header
              _buildBrandingHeader(),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              
              // Doctor info display
              _buildDoctorInfoCard(),
              const SizedBox(height: 24),
              
              // Patient selection
              _buildPatientSelection(),
              const SizedBox(height: 20),
              
              // Diagnosis
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(
                  labelText: 'Diagnosis *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_information),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter diagnosis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Medications section
              _buildMedicationsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingHeader() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue[700]!, width: 2),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/dr_saathi_icon.png',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dr. Saathi',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            Text(
              'Your Health Companion',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDoctorInfoCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.doctorName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            if (widget.doctorSpecialization != null)
              Text(
                widget.doctorSpecialization!,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.badge, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'NMC Reg. No: ${widget.doctorNMC}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
            if (widget.doctorPhone != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(widget.doctorPhone!),
                ],
              ),
            ],
            if (widget.doctorEmail != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.email, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(widget.doctorEmail!),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPatientSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Patient',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_isLoadingPatients)
          const Center(child: CircularProgressIndicator())
        else
          DropdownButtonFormField<Patient>(
            value: _selectedPatient,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            hint: const Text('Choose a patient'),
            items: _patients.map((patient) {
              return DropdownMenuItem<Patient>(
                value: patient,
                child: Text('${patient.firstName} ${patient.lastName} - ${patient.phoneNumber}'),
              );
            }).toList(),
            onChanged: (patient) {
              setState(() => _selectedPatient = patient);
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a patient';
              }
              return null;
            },
          ),
      ],
    );
  }

  Widget _buildMedicationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Medications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _addMedication,
              icon: const Icon(Icons.add),
              label: const Text('Add Medicine'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_medications.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('No medications added yet'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _medications.length,
            itemBuilder: (context, index) {
              final med = _medications[index];
              return Card(
                child: ListTile(
                  title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${med.dosage} - ${med.frequency} for ${med.duration}\n${med.instructions}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() => _medications.removeAt(index));
                    },
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class MedicationItem {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String instructions;

  MedicationItem({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.instructions,
  });
}

class _MedicationDialog extends StatefulWidget {
  final Function(MedicationItem) onAdd;

  const _MedicationDialog({required this.onAdd});

  @override
  State<_MedicationDialog> createState() => _MedicationDialogState();
}

class _MedicationDialogState extends State<_MedicationDialog> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _durationController = TextEditingController();
  final _instructionsController = TextEditingController();
  String _frequency = 'Twice daily';

  final List<String> _frequencies = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Four times daily',
    'As needed',
    'Before meals',
    'After meals',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Medication'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Medicine Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage (e.g., 500mg) *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
              ),
              items: _frequencies.map((freq) {
                return DropdownMenuItem(value: freq, child: Text(freq));
              }).toList(),
              onChanged: (value) {
                setState(() => _frequency = value!);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (e.g., 7 days) *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instructions',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _dosageController.text.isNotEmpty &&
                _durationController.text.isNotEmpty) {
              widget.onAdd(MedicationItem(
                name: _nameController.text,
                dosage: _dosageController.text,
                frequency: _frequency,
                duration: _durationController.text,
                instructions: _instructionsController.text,
              ));
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
