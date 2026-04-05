import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/consultation.dart';
import '../models/billing_item.dart';

class BillTemplateGenerator {
  /// Generate PDF bill with Dr. Saathi branding
  Future<File> generateBillPDF({
    required String invoiceNumber,
    required String patientName,
    required String patientId,
    required String patientPhone,
    required String patientEmail,
    required String doctorName,
    required String doctorSpecialization,
    required DateTime consultationDate,
    required String consultationType,
    required double consultationFee,
    required List<BillingItem> additionalCharges,
    required String? diagnosis,
    required String? prescription,
    required DateTime issueDate,
    required DateTime dueDate,
    required String paymentStatus,
    required DateTime? paymentDate,
    required String? paymentMethod,
  }) async {
    final pdf = pw.Document();
    
    // Load logo
    final logoData = await rootBundle.load('assets/images/dr_saathi_icon.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    // Calculate totals
    final subtotal = consultationFee + 
        additionalCharges.fold(0.0, (sum, item) => sum + item.total);
    final vatAmount = subtotal * 0.13;
    final totalAmount = subtotal + vatAmount;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with Logo
              _buildHeader(logoImage),
              pw.SizedBox(height: 30),
              
              // Invoice Title and Number
              _buildInvoiceTitle(invoiceNumber, issueDate),
              pw.SizedBox(height: 25),
              
              // Patient and Doctor Information
              _buildPartyInfo(
                patientName: patientName,
                patientId: patientId,
                patientPhone: patientPhone,
                patientEmail: patientEmail,
                doctorName: doctorName,
                doctorSpecialization: doctorSpecialization,
              ),
              pw.SizedBox(height: 25),
              
              // Consultation Details
              _buildConsultationDetails(
                consultationDate: consultationDate,
                consultationType: consultationType,
                diagnosis: diagnosis,
              ),
              pw.SizedBox(height: 25),
              
              // Billing Items Table
              _buildBillingTable(
                consultationFee: consultationFee,
                additionalCharges: additionalCharges,
              ),
              pw.SizedBox(height: 20),
              
              // Totals
              _buildTotalsSection(
                subtotal: subtotal,
                vatAmount: vatAmount,
                totalAmount: totalAmount,
              ),
              pw.SizedBox(height: 25),
              
              // Payment Information
              _buildPaymentInfo(
                paymentStatus: paymentStatus,
                paymentDate: paymentDate,
                paymentMethod: paymentMethod,
                dueDate: dueDate,
              ),
              pw.SizedBox(height: 20),
              
              // Prescription Summary
              if (prescription != null && prescription.isNotEmpty)
                _buildPrescriptionSummary(prescription),
              
              pw.Spacer(),
              
              // Footer
              _buildFooter(),
            ],
          );
        },
      ),
    );

    // Save PDF to file
    final output = await getApplicationDocumentsDirectory();
    final file = File('${output.path}/bill_$invoiceNumber.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  pw.Widget _buildHeader(pw.ImageProvider logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Logo and Company Info
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 60,
              height: 60,
              child: pw.Image(logo),
            ),
            pw.SizedBox(width: 15),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Dr. Saathi',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue700,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Your Health Partner',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Kathmandu, Nepal',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Phone: +977-1-4123456',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  'Email: info@drsaathi.com.np',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        
        // Medical Bill Badge
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.blue300, width: 2),
          ),
          child: pw.Text(
            'MEDICAL BILL',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildInvoiceTitle(String invoiceNumber, DateTime issueDate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue700,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Invoice Number: $invoiceNumber',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.Text(
                'Date: ${_formatDate(issueDate)}',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPartyInfo({
    required String patientName,
    required String patientId,
    required String patientPhone,
    required String patientEmail,
    required String doctorName,
    required String doctorSpecialization,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Patient Information
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'BILL TO:',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  patientName,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text('Patient ID: $patientId', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('Phone: $patientPhone', style: const pw.TextStyle(fontSize: 10)),
                if (patientEmail.isNotEmpty)
                  pw.Text('Email: $patientEmail', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
        
        pw.SizedBox(width: 20),
        
        // Doctor Information
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'CONSULTING DOCTOR:',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Dr. $doctorName',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(doctorSpecialization, style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildConsultationDetails({
    required DateTime consultationDate,
    required String consultationType,
    String? diagnosis,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CONSULTATION DETAILS',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Consultation Date:', style: const pw.TextStyle(fontSize: 10)),
              pw.Text(
                _formatDate(consultationDate),
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Consultation Type:', style: const pw.TextStyle(fontSize: 10)),
              pw.Text(
                consultationType.toUpperCase(),
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          if (diagnosis != null && diagnosis.isNotEmpty) ...[
            pw.SizedBox(height: 5),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Diagnosis: ', style: const pw.TextStyle(fontSize: 10)),
                pw.Expanded(
                  child: pw.Text(
                    diagnosis,
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildBillingTable({
    required double consultationFee,
    required List<BillingItem> additionalCharges,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue700),
          children: [
            _tableCell('Description', isHeader: true),
            _tableCell('Quantity', isHeader: true, alignment: pw.Alignment.center),
            _tableCell('Unit Price', isHeader: true, alignment: pw.Alignment.centerRight),
            _tableCell('Amount (NPR)', isHeader: true, alignment: pw.Alignment.centerRight),
          ],
        ),
        
        // Consultation Fee Row
        pw.TableRow(
          children: [
            _tableCell('Doctor Consultation Fee'),
            _tableCell('1', alignment: pw.Alignment.center),
            _tableCell(_formatCurrency(consultationFee), alignment: pw.Alignment.centerRight),
            _tableCell(_formatCurrency(consultationFee), alignment: pw.Alignment.centerRight),
          ],
        ),
        
        // Additional Charges Rows
        ...additionalCharges.map((item) => pw.TableRow(
          children: [
            _tableCell(item.description),
            _tableCell(item.quantity.toString(), alignment: pw.Alignment.center),
            _tableCell(_formatCurrency(item.unitPrice), alignment: pw.Alignment.centerRight),
            _tableCell(_formatCurrency(item.total), alignment: pw.Alignment.centerRight),
          ],
        )),
      ],
    );
  }

  pw.Widget _tableCell(
    String text, {
    bool isHeader = false,
    pw.Alignment alignment = pw.Alignment.centerLeft,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      alignment: alignment,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }

  pw.Widget _buildTotalsSection({
    required double subtotal,
    required double vatAmount,
    required double totalAmount,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 250,
          child: pw.Column(
            children: [
              _totalRow('Subtotal:', subtotal),
              pw.SizedBox(height: 5),
              _totalRow('VAT (13%):', vatAmount),
              pw.Divider(thickness: 2),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.green300, width: 1.5),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL AMOUNT:',
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'NPR ${_formatCurrency(totalAmount)}',
                      style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _totalRow(String label, double amount) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
        pw.Text(
          'NPR ${_formatCurrency(amount)}',
          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  pw.Widget _buildPaymentInfo({
    required String paymentStatus,
    required DateTime? paymentDate,
    required String? paymentMethod,
    required DateTime dueDate,
  }) {
    final isPaid = paymentStatus.toLowerCase() == 'paid';
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: isPaid ? PdfColors.green50 : PdfColors.orange50,
        border: pw.Border.all(
          color: isPaid ? PdfColors.green300 : PdfColors.orange300,
          width: 2,
        ),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PAYMENT STATUS',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(
                  color: isPaid ? PdfColors.green700 : PdfColors.orange700,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  paymentStatus.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
          
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              if (isPaid && paymentDate != null) ...[
                pw.Text(
                  'Payment Date: ${_formatDate(paymentDate)}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                if (paymentMethod != null)
                  pw.Text(
                    'Payment Method: $paymentMethod',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
              ] else ...[
                pw.Text(
                  'Due Date: ${_formatDate(dueDate)}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.red700),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPrescriptionSummary(String prescription) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PRESCRIPTION SUMMARY',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            prescription,
            style: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Thank you for choosing Dr. Saathi',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue700,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'For queries: support@drsaathi.com.np | +977-1-4123456',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Generated on: ${_formatDate(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text(
                  'This is a computer-generated bill',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(2);
  }
}
