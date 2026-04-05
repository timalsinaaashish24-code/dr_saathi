import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service for generating professional prescription PDFs with letterhead
class PrescriptionService {
  /// Generate a prescription PDF with professional letterhead
  static Future<File> generatePrescription({
    required String doctorName,
    required String doctorSpecialty,
    required String doctorRegistrationNo,
    required String doctorPhone,
    required String doctorEmail,
    required String clinicName,
    required String clinicAddress,
    required String patientName,
    required String patientAge,
    required String patientGender,
    required String patientContact,
    required String diagnosis,
    required List<Medication> medications,
    required String additionalInstructions,
    required DateTime prescriptionDate,
    String? followUpDate,
    String? clinicLogo,
  }) async {
    final pdf = pw.Document();
    
    // Load fonts for better rendering
    final ttf = await PdfGoogleFonts.robotoRegular();
    final ttfBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(30),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Letterhead Header
              _buildLetterhead(
                doctorName: doctorName,
                doctorSpecialty: doctorSpecialty,
                doctorRegistrationNo: doctorRegistrationNo,
                doctorPhone: doctorPhone,
                doctorEmail: doctorEmail,
                clinicName: clinicName,
                clinicAddress: clinicAddress,
                ttf: ttf,
                ttfBold: ttfBold,
              ),
              
              pw.Divider(thickness: 2, color: PdfColors.blue800),
              pw.SizedBox(height: 20),
              
              // Prescription Title
              pw.Center(
                child: pw.Text(
                  'PRESCRIPTION',
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 18,
                    color: PdfColors.blue800,
                    letterSpacing: 2,
                  ),
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Date and Prescription Number
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Date: ${_formatDate(prescriptionDate)}',
                    style: pw.TextStyle(font: ttf, fontSize: 10),
                  ),
                  pw.Text(
                    'Rx No: ${_generatePrescriptionNumber(prescriptionDate)}',
                    style: pw.TextStyle(font: ttf, fontSize: 10),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 15),
              
              // Patient Information
              _buildPatientInfo(
                patientName: patientName,
                patientAge: patientAge,
                patientGender: patientGender,
                patientContact: patientContact,
                ttf: ttf,
                ttfBold: ttfBold,
              ),
              
              pw.SizedBox(height: 15),
              
              // Diagnosis
              pw.Container(
                padding: pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Diagnosis: ',
                      style: pw.TextStyle(font: ttfBold, fontSize: 11),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        diagnosis,
                        style: pw.TextStyle(font: ttf, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Rx Symbol
              pw.Row(
                children: [
                  pw.Text(
                    'Rx',
                    style: pw.TextStyle(
                      font: ttfBold,
                      fontSize: 24,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Divider(thickness: 1),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 15),
              
              // Medications
              _buildMedicationsList(medications, ttf, ttfBold),
              
              pw.SizedBox(height: 20),
              
              // Additional Instructions
              if (additionalInstructions.isNotEmpty)
                pw.Container(
                  padding: pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.blue300),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Additional Instructions:',
                        style: pw.TextStyle(font: ttfBold, fontSize: 11),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        additionalInstructions,
                        style: pw.TextStyle(font: ttf, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              
              pw.SizedBox(height: 15),
              
              // Follow-up Date
              if (followUpDate != null)
                pw.Container(
                  padding: pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.amber100,
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Icon(
                        pw.IconData(0xe192), // calendar icon
                        size: 16,
                        color: PdfColors.orange800,
                      ),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        'Follow-up Date: $followUpDate',
                        style: pw.TextStyle(
                          font: ttfBold,
                          fontSize: 10,
                          color: PdfColors.orange800,
                        ),
                      ),
                    ],
                  ),
                ),
              
              pw.Spacer(),
              
              // Doctor's Signature
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        width: 150,
                        height: 40,
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          doctorName,
                          style: pw.TextStyle(
                            font: ttfBold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 150,
                        height: 1,
                        color: PdfColors.black,
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Doctor\'s Signature',
                        style: pw.TextStyle(font: ttf, fontSize: 9),
                      ),
                      pw.Text(
                        'Reg. No: $doctorRegistrationNo',
                        style: pw.TextStyle(font: ttf, fontSize: 8),
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.SizedBox(height: 10),
              
              // Footer
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  'This is a computer-generated prescription from Dr. Saathi Healthcare Platform',
                  style: pw.TextStyle(font: ttf, fontSize: 8, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save PDF to file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/prescription_${_generatePrescriptionNumber(prescriptionDate)}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  /// Build letterhead header
  static pw.Widget _buildLetterhead({
    required String doctorName,
    required String doctorSpecialty,
    required String doctorRegistrationNo,
    required String doctorPhone,
    required String doctorEmail,
    required String clinicName,
    required String clinicAddress,
    required pw.Font ttf,
    required pw.Font ttfBold,
  }) {
    return pw.Container(
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [PdfColors.blue50, PdfColors.cyan50],
        ),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColors.blue800, width: 2),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Medical Symbol/Logo
          pw.Container(
            width: 60,
            height: 60,
            decoration: pw.BoxDecoration(
              color: PdfColors.blue800,
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Icon(
                pw.IconData(0xe3be), // medical services icon
                size: 35,
                color: PdfColors.white,
              ),
            ),
          ),
          
          pw.SizedBox(width: 15),
          
          // Clinic and Doctor Information
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  clinicName,
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 16,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  'Dr. $doctorName',
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 13,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.Text(
                  doctorSpecialty,
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 11,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  clinicAddress,
                  style: pw.TextStyle(font: ttf, fontSize: 9),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          
          // Contact Information
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Row(
                children: [
                  pw.Icon(pw.IconData(0xe0b0), size: 10),
                  pw.SizedBox(width: 3),
                  pw.Text(
                    doctorPhone,
                    style: pw.TextStyle(font: ttf, fontSize: 9),
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Row(
                children: [
                  pw.Icon(pw.IconData(0xe0be), size: 10),
                  pw.SizedBox(width: 3),
                  pw.Text(
                    doctorEmail,
                    style: pw.TextStyle(font: ttf, fontSize: 9),
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Reg: $doctorRegistrationNo',
                style: pw.TextStyle(font: ttf, fontSize: 8, color: PdfColors.grey600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build patient information section
  static pw.Widget _buildPatientInfo({
    required String patientName,
    required String patientAge,
    required String patientGender,
    required String patientContact,
    required pw.Font ttf,
    required pw.Font ttfBold,
  }) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: _buildInfoRow('Patient Name:', patientName, ttf, ttfBold),
          ),
          pw.SizedBox(width: 20),
          _buildInfoRow('Age:', patientAge, ttf, ttfBold),
          pw.SizedBox(width: 20),
          _buildInfoRow('Gender:', patientGender, ttf, ttfBold),
          pw.SizedBox(width: 20),
          _buildInfoRow('Contact:', patientContact, ttf, ttfBold),
        ],
      ),
    );
  }

  /// Build information row
  static pw.Widget _buildInfoRow(String label, String value, pw.Font ttf, pw.Font ttfBold) {
    return pw.Row(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(font: ttfBold, fontSize: 10),
        ),
        pw.SizedBox(width: 5),
        pw.Text(
          value,
          style: pw.TextStyle(font: ttf, fontSize: 10),
        ),
      ],
    );
  }

  /// Build medications list
  static pw.Widget _buildMedicationsList(
    List<Medication> medications,
    pw.Font ttf,
    pw.Font ttfBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: medications.asMap().entries.map((entry) {
        final index = entry.key;
        final med = entry.value;
        
        return pw.Container(
          margin: pw.EdgeInsets.only(bottom: 12),
          padding: pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: index % 2 == 0 ? PdfColors.blue50 : PdfColors.white,
            border: pw.Border.all(color: PdfColors.blue200),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 25,
                height: 25,
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue800,
                  shape: pw.BoxShape.circle,
                ),
                child: pw.Center(
                  child: pw.Text(
                    '${index + 1}',
                    style: pw.TextStyle(
                      font: ttfBold,
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      med.name,
                      style: pw.TextStyle(font: ttfBold, fontSize: 12),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'Dosage: ${med.dosage}',
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                    pw.Text(
                      'Frequency: ${med.frequency}',
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                    pw.Text(
                      'Duration: ${med.duration}',
                      style: pw.TextStyle(font: ttf, fontSize: 10),
                    ),
                    if (med.instructions.isNotEmpty)
                      pw.Text(
                        'Instructions: ${med.instructions}',
                        style: pw.TextStyle(font: ttf, fontSize: 9, color: PdfColors.grey700),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Format date
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Generate prescription number
  static String _generatePrescriptionNumber(DateTime date) {
    return 'RX${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}${date.hour.toString().padLeft(2, '0')}${date.minute.toString().padLeft(2, '0')}';
  }

  /// Share prescription PDF
  static Future<void> sharePrescription(File pdfFile) async {
    await Share.shareXFiles(
      [XFile(pdfFile.path)],
      text: 'Prescription from Dr. Saathi',
      subject: 'Medical Prescription',
    );
  }

  /// Print prescription
  static Future<void> printPrescription(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    await Printing.layoutPdf(onLayout: (format) => bytes);
  }
}

/// Medication model for prescription
class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String instructions;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions = '',
  });
}
