import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/prescription.dart';
import '../models/patient.dart';

class PdfService {
  static const String _doctorName = 'Dr. Saathi';
  static const String _clinicName = 'Dr. Saathi Clinic';
  static const String _clinicAddress = 'Medical Center, Healthcare District';
  static const String _doctorRegistration = 'REG123456';
  static const String _clinicPhone = '+1234567890';
  static const String _clinicEmail = 'contact@drsaathi.com';

  static Future<Uint8List> generatePrescriptionPdf(
    Prescription prescription,
    Patient patient,
  ) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoRegular();
    final boldFont = await PdfGoogleFonts.nunitoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(boldFont, font),
              pw.SizedBox(height: 20),
              
              // Patient Information
              _buildPatientInfo(patient, boldFont, font),
              pw.SizedBox(height: 20),
              
              // Prescription Details
              _buildPrescriptionDetails(prescription, boldFont, font),
              pw.SizedBox(height: 20),
              
              // Medications
              _buildMedicationTable(prescription.medications, boldFont, font),
              pw.SizedBox(height: 20),
              
              // Notes and Instructions
              if (prescription.notes.isNotEmpty)
                _buildNotesSection(prescription.notes, boldFont, font),
              
              pw.Spacer(),
              
              // Footer
              _buildFooter(prescription, boldFont, font),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(pw.Font boldFont, pw.Font font) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue200),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _clinicName,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 24,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            _doctorName,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 18,
              color: PdfColors.blue700,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Registration No: $_doctorRegistration',
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            _clinicAddress,
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
          pw.Text(
            'Phone: $_clinicPhone | Email: $_clinicEmail',
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPatientInfo(
    Patient patient,
    pw.Font boldFont,
    pw.Font font,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Patient Information',
            style: pw.TextStyle(font: boldFont, fontSize: 16),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Name: ${patient.firstName} ${patient.lastName}',
                        style: pw.TextStyle(font: font, fontSize: 12)),
                    pw.SizedBox(height: 4),
                    pw.Text('Age: ${patient.age} years',
                        style: pw.TextStyle(font: font, fontSize: 12)),
                    pw.SizedBox(height: 4),
                    pw.Text('Phone: ${patient.phoneNumber}',
                        style: pw.TextStyle(font: font, fontSize: 12)),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Address: ${patient.address}',
                        style: pw.TextStyle(font: font, fontSize: 12)),
                    pw.Text('Emergency Contact: ${patient.emergencyContact}',
                        style: pw.TextStyle(font: font, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPrescriptionDetails(
    Prescription prescription,
    pw.Font boldFont,
    pw.Font font,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Prescription Details',
            style: pw.TextStyle(font: boldFont, fontSize: 16),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Prescription ID: ${prescription.id}',
                        style: pw.TextStyle(font: font, fontSize: 12)),
                    pw.SizedBox(height: 4),
                    pw.Text(
                        'Date: ${prescription.prescriptionDate.toString().split(' ')[0]}',
                        style: pw.TextStyle(font: font, fontSize: 12)),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Diagnosis: ${prescription.diagnosis}',
                        style: pw.TextStyle(font: font, fontSize: 12)),
                    pw.SizedBox(height: 4),
                    if (prescription.followUpDate != null)
                      pw.Text(
                          'Follow-up Date: ${prescription.followUpDate.toString().split(' ')[0]}',
                          style: pw.TextStyle(font: font, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMedicationTable(
    List<Medication> medications,
    pw.Font boldFont,
    pw.Font font,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Medications',
          style: pw.TextStyle(font: boldFont, fontSize: 16),
        ),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
            4: const pw.FlexColumnWidth(1),
            5: const pw.FlexColumnWidth(3),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                color: PdfColors.grey100,
              ),
              children: [
                _buildTableCell('Medication', boldFont, isHeader: true),
                _buildTableCell('Dosage', boldFont, isHeader: true),
                _buildTableCell('Frequency', boldFont, isHeader: true),
                _buildTableCell('Duration', boldFont, isHeader: true),
                _buildTableCell('Qty', boldFont, isHeader: true),
                _buildTableCell('Instructions', boldFont, isHeader: true),
              ],
            ),
            // Data rows
            ...medications.map((medication) => pw.TableRow(
                  children: [
                    _buildTableCell(medication.name, font),
                    _buildTableCell(medication.dosage, font),
                    _buildTableCell(medication.frequency, font),
                    _buildTableCell(medication.duration, font),
                    _buildTableCell(medication.quantity.toString(), font),
                    _buildTableCell(medication.instructions, font),
                  ],
                )),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, pw.Font font,
      {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _buildNotesSection(
    String notes,
    pw.Font boldFont,
    pw.Font font,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Additional Notes',
          style: pw.TextStyle(font: boldFont, fontSize: 16),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Text(
            notes,
            style: pw.TextStyle(font: font, fontSize: 12),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(
    Prescription prescription,
    pw.Font boldFont,
    pw.Font font,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Doctor\'s Signature',
                  style: pw.TextStyle(font: boldFont, fontSize: 12),
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  _doctorName,
                  style: pw.TextStyle(font: font, fontSize: 12),
                ),
                pw.Text(
                  'Registration No: $_doctorRegistration',
                  style: pw.TextStyle(font: font, fontSize: 10),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Generated on: ${DateTime.now().toString().split(' ')[0]}',
                  style: pw.TextStyle(font: font, fontSize: 10),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Prescription Valid Until: ${prescription.followUpDate?.toString().split(' ')[0] ?? 'Not Specified'}',
                  style: pw.TextStyle(font: font, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static Future<void> printPrescription(
    Prescription prescription,
    Patient patient,
  ) async {
    final pdfData = await generatePrescriptionPdf(prescription, patient);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfData,
      name: 'Prescription_${prescription.id}_${patient.firstName}_${patient.lastName}',
    );
  }

  static Future<void> sharePrescription(
    Prescription prescription,
    Patient patient,
  ) async {
    final pdfData = await generatePrescriptionPdf(prescription, patient);
    final tempDir = await getTemporaryDirectory();
    final fileName = 'Prescription_${prescription.id}_${patient.firstName}_${patient.lastName}.pdf';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(pdfData);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Prescription for ${patient.firstName} ${patient.lastName}',
      text: 'Please find attached the prescription for ${patient.firstName} ${patient.lastName}.',
    );
  }

  static Future<File> savePrescriptionToFile(
    Prescription prescription,
    Patient patient,
  ) async {
    final pdfData = await generatePrescriptionPdf(prescription, patient);
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'Prescription_${prescription.id}_${patient.firstName}_${patient.lastName}.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(pdfData);
    return file;
  }
}
