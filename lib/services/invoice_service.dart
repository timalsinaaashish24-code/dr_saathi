import '../models/invoice.dart';
import '../models/billing_item.dart';
import 'database_service.dart';
import 'notification_service.dart';

class InvoiceService {
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  
  // Nepal VAT and tax rates (can be configured)
  static const double defaultVatRate = 13.0; // 13% VAT in Nepal
  static const double defaultTaxRate = 1.5;  // Additional tax rate
  
  // Generate and save invoice
  Future<Invoice> generateInvoice({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required List<BillingItem> items,
    double? vatRate,
    double? taxRate,
    String? notes,
    int paymentTermDays = 30,
  }) async {
    try {
      // Create invoice with calculations
      final invoice = Invoice.create(
        patientId: patientId,
        patientName: patientName,
        doctorId: doctorId,
        doctorName: doctorName,
        items: items,
        vatRate: vatRate ?? defaultVatRate,
        taxRate: taxRate ?? defaultTaxRate,
        notes: notes,
        paymentTermDays: paymentTermDays,
      );
      
      // Save invoice to database
      await _saveInvoice(invoice);
      
      // Initialize billing tables if not exists
      await _initializeBillingTables();
      
      print('Invoice ${invoice.invoiceNumber} generated successfully');
      return invoice;
    } catch (e) {
      print('Error generating invoice: $e');
      rethrow;
    }
  }
  
  // Send invoice to patient
  Future<bool> sendInvoiceToPatient({
    required Invoice invoice,
    bool sendSms = true,
    bool sendEmail = false,
  }) async {
    try {
      // Update invoice status to pending
      final updatedInvoice = invoice.copyWith(status: InvoiceStatus.pending);
      await _updateInvoice(updatedInvoice);
      
      // Get patient contact info
      final patient = await _getPatientContactInfo(invoice.patientId);
      if (patient == null) {
        throw Exception('Patient not found');
      }
      
      // Send SMS notification
      if (sendSms && patient['phone_number'] != null) {
        await _sendInvoiceSms(invoice, patient['phone_number']);
      }
      
      // Send email notification (if implemented)
      if (sendEmail && patient['email'] != null) {
        await _sendInvoiceEmail(invoice, patient['email']);
      }
      
      print('Invoice ${invoice.invoiceNumber} sent to patient ${invoice.patientName}');
      return true;
    } catch (e) {
      print('Error sending invoice to patient: $e');
      return false;
    }
  }
  
  // Mark invoice as paid
  Future<bool> markInvoiceAsPaid({
    required String invoiceId,
    required String paymentMethod,
    String? paymentReference,
  }) async {
    try {
      final invoice = await getInvoiceById(invoiceId);
      if (invoice == null) {
        throw Exception('Invoice not found');
      }
      
      final updatedInvoice = invoice.copyWith(
        status: InvoiceStatus.paid,
        paidAt: DateTime.now(),
        paymentMethod: paymentMethod,
        paymentReference: paymentReference,
      );
      
      await _updateInvoice(updatedInvoice);
      
      // Send payment confirmation
      await _sendPaymentConfirmation(updatedInvoice);
      
      print('Invoice ${invoice.invoiceNumber} marked as paid');
      return true;
    } catch (e) {
      print('Error marking invoice as paid: $e');
      return false;
    }
  }
  
  // Get all invoices for a doctor
  Future<List<Invoice>> getInvoicesForDoctor(String doctorId) async {
    try {
      final result = await (await _dbService.database).query(
        'invoices',
        where: 'doctor_id = ?',
        whereArgs: [doctorId],
        orderBy: 'created_at DESC',
      );
      
      return result.map((json) => Invoice.fromJson(json)).toList();
    } catch (e) {
      print('Error getting invoices for doctor: $e');
      return [];
    }
  }
  
  // Get all invoices for a patient
  Future<List<Invoice>> getInvoicesForPatient(String patientId) async {
    try {
      final result = await (await _dbService.database).query(
        'invoices',
        where: 'patient_id = ?',
        whereArgs: [patientId],
        orderBy: 'created_at DESC',
      );
      
      return result.map((json) => Invoice.fromJson(json)).toList();
    } catch (e) {
      print('Error getting invoices for patient: $e');
      return [];
    }
  }
  
  // Get invoice by ID
  Future<Invoice?> getInvoiceById(String invoiceId) async {
    try {
      final result = await (await _dbService.database).query(
        'invoices',
        where: 'id = ?',
        whereArgs: [invoiceId],
        limit: 1,
      );
      
      if (result.isNotEmpty) {
        return Invoice.fromJson(result.first);
      }
      return null;
    } catch (e) {
      print('Error getting invoice by ID: $e');
      return null;
    }
  }
  
  // Get overdue invoices
  Future<List<Invoice>> getOverdueInvoices() async {
    try {
      final now = DateTime.now().toIso8601String();
      final result = await (await _dbService.database).query(
        'invoices',
        where: 'status = ? AND due_date < ?',
        whereArgs: ['pending', now],
        orderBy: 'due_date ASC',
      );
      
      return result.map((json) => Invoice.fromJson(json)).toList();
    } catch (e) {
      print('Error getting overdue invoices: $e');
      return [];
    }
  }
  
  // Generate tax report
  Future<Map<String, dynamic>> generateTaxReport({
    required String doctorId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await (await _dbService.database).rawQuery('''
        SELECT 
          COUNT(*) as total_invoices,
          SUM(subtotal) as total_subtotal,
          SUM(vat_amount) as total_vat,
          SUM(tax_amount) as total_tax,
          SUM(total_amount) as total_amount,
          SUM(CASE WHEN status = 'paid' THEN total_amount ELSE 0 END) as total_paid,
          SUM(CASE WHEN status = 'pending' THEN total_amount ELSE 0 END) as total_pending
        FROM invoices 
        WHERE doctor_id = ? AND created_at BETWEEN ? AND ?
      ''', [doctorId, startDate.toIso8601String(), endDate.toIso8601String()]);
      
      return result.first;
    } catch (e) {
      print('Error generating tax report: $e');
      return {};
    }
  }
  
  // Private helper methods
  Future<void> _saveInvoice(Invoice invoice) async {
    await (await _dbService.database).insert('invoices', invoice.toJson());
    
    // Save individual billing items
    for (final item in invoice.items) {
      await (await _dbService.database).insert('billing_items', {
        ...item.toJson(),
        'invoice_id': invoice.id,
      });
    }
  }
  
  Future<void> _updateInvoice(Invoice invoice) async {
    await (await _dbService.database).update(
      'invoices',
      invoice.toJson(),
      where: 'id = ?',
      whereArgs: [invoice.id],
    );
  }
  
  Future<Map<String, dynamic>?> _getPatientContactInfo(String patientId) async {
    try {
      final result = await (await _dbService.database).query(
        'patients',
        columns: ['phone_number', 'email', 'first_name', 'last_name'],
        where: 'id = ?',
        whereArgs: [patientId],
        limit: 1,
      );
      
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting patient contact info: $e');
      return null;
    }
  }
  
  Future<void> _sendInvoiceSms(Invoice invoice, String phoneNumber) async {
    final message = '''
Dr. Saathi Invoice

Invoice: ${invoice.invoiceNumber}
Doctor: ${invoice.doctorName}
Amount: Rs ${invoice.totalAmount.toStringAsFixed(2)}
Due Date: ${_formatDate(invoice.dueDate)}

Please check your account for details.
''';
    
    // await _notificationService.sendSms(phoneNumber, message); //Temporarily commented out, will implement later once notification service is properly setup
  }
  
  Future<void> _sendInvoiceEmail(Invoice invoice, String email) async {
    // TODO: Implement email sending
    print('Email invoice sent to: $email');
  }
  
  Future<void> _sendPaymentConfirmation(Invoice invoice) async {
    final patient = await _getPatientContactInfo(invoice.patientId);
    if (patient != null && patient['phone_number'] != null) {
      final message = '''
Payment Confirmed - Dr. Saathi

Invoice: ${invoice.invoiceNumber}
Amount Paid: Rs ${invoice.totalAmount.toStringAsFixed(2)}
Payment Date: ${_formatDate(DateTime.now())}

Thank you for your payment!
''';
      
      await _notificationService.sendSMSNotification(patient['phone_number'], message);
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  // Initialize billing database tables
  Future<void> _initializeBillingTables() async {
    try {
      // Create invoices table
      await (await _dbService.database).execute('''
        CREATE TABLE IF NOT EXISTS invoices (
          id TEXT PRIMARY KEY,
          invoice_number TEXT UNIQUE NOT NULL,
          patient_id TEXT NOT NULL,
          patient_name TEXT NOT NULL,
          doctor_id TEXT NOT NULL,
          doctor_name TEXT NOT NULL,
          invoice_date TEXT NOT NULL,
          due_date TEXT NOT NULL,
          subtotal REAL NOT NULL,
          vat_rate REAL NOT NULL,
          vat_amount REAL NOT NULL,
          tax_rate REAL NOT NULL,
          tax_amount REAL NOT NULL,
          total_amount REAL NOT NULL,
          status TEXT NOT NULL,
          notes TEXT,
          created_at TEXT NOT NULL,
          paid_at TEXT,
          payment_method TEXT,
          payment_reference TEXT
        )
      ''');
      
      // Create billing items table
      await (await _dbService.database).execute('''
        CREATE TABLE IF NOT EXISTS billing_items (
          id TEXT PRIMARY KEY,
          invoice_id TEXT NOT NULL,
          description TEXT NOT NULL,
          type TEXT NOT NULL,
          quantity REAL NOT NULL,
          unit_price REAL NOT NULL,
          total_amount REAL NOT NULL,
          category TEXT,
          created_at TEXT NOT NULL,
          FOREIGN KEY (invoice_id) REFERENCES invoices (id)
        )
      ''');
      
      print('Billing tables initialized successfully');
    } catch (e) {
      print('Error initializing billing tables: $e');
    }
  }
  
  // Get invoice statistics
  Future<Map<String, dynamic>> getInvoiceStats(String doctorId) async {
    try {
      final result = await (await _dbService.database).rawQuery('''
        SELECT 
          COUNT(*) as total_invoices,
          SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_invoices,
          SUM(CASE WHEN status = 'paid' THEN 1 ELSE 0 END) as paid_invoices,
          SUM(CASE WHEN status = 'pending' AND due_date < ? THEN 1 ELSE 0 END) as overdue_invoices,
          SUM(total_amount) as total_revenue,
          SUM(CASE WHEN status = 'paid' THEN total_amount ELSE 0 END) as total_collected
        FROM invoices 
        WHERE doctor_id = ?
      ''', [DateTime.now().toIso8601String(), doctorId]);
      
      return result.first;
    } catch (e) {
      print('Error getting invoice stats: $e');
      return {};
    }
  }
}