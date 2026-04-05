import 'models/patient.dart';
import 'models/invoice.dart';
import 'models/billing_item.dart';
import 'services/database_service.dart';
import 'services/invoice_service.dart';

class SampleDataCreator {
  static final DatabaseService _dbService = DatabaseService();
  static final InvoiceService _invoiceService = InvoiceService();

  static Future<void> createSampleData() async {
    print('Creating sample data...');
    
    // Create sample patients
    final patients = [
      Patient(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        dateOfBirth: DateTime(1988, 5, 15), // 35 years old
        phoneNumber: '9876543210',
        email: 'john.doe@email.com',
        address: '123 Main Street, Mumbai, Maharashtra',
        emergencyContact: 'Jane Doe - 9876543211',
        medicalHistory: 'Hypertension, Diabetes Type 2',
        allergies: 'Peanuts, Shellfish',
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        updatedAt: DateTime.now().subtract(Duration(days: 30)),
        synced: true,
      ),
      Patient(
        id: '2',
        firstName: 'Priya',
        lastName: 'Sharma',
        dateOfBirth: DateTime(1995, 8, 22), // 28 years old
        phoneNumber: '9876543212',
        email: 'priya.sharma@email.com',
        address: '456 Park Avenue, Delhi',
        emergencyContact: 'Raj Sharma - 9876543213',
        medicalHistory: 'Asthma',
        allergies: 'Dust, Pollen',
        createdAt: DateTime.now().subtract(Duration(days: 25)),
        updatedAt: DateTime.now().subtract(Duration(days: 25)),
        synced: true,
      ),
      Patient(
        id: '3',
        firstName: 'Rajesh',
        lastName: 'Kumar',
        dateOfBirth: DateTime(1978, 12, 10), // 45 years old
        phoneNumber: '9876543214',
        email: 'rajesh.kumar@email.com',
        address: '789 Gandhi Road, Bangalore',
        emergencyContact: 'Sunita Kumar - 9876543215',
        medicalHistory: 'High cholesterol, Back pain',
        allergies: 'None',
        createdAt: DateTime.now().subtract(Duration(days: 20)),
        updatedAt: DateTime.now().subtract(Duration(days: 20)),
        synced: true,
      ),
    ];

    // Insert patients
    for (final patient in patients) {
      try {
        await _dbService.insertPatient(patient);
        print('Created patient: ${patient.firstName} ${patient.lastName}');
      } catch (e) {
        print('Error creating patient ${patient.firstName}: $e');
      }
    }

    // Create sample billing items
    final consultationFee = BillingItem.create(
      description: 'General Consultation',
      type: BillingItemType.consultation,
      quantity: 1.0,
      unitPrice: 800.0,
      category: 'Medical Consultation',
    );

    final bloodTest = BillingItem.create(
      description: 'Complete Blood Count (CBC)',
      type: BillingItemType.laboratory,
      quantity: 1.0,
      unitPrice: 450.0,
      category: 'Laboratory Test',
    );

    final medicine = BillingItem.create(
      description: 'Paracetamol 500mg',
      type: BillingItemType.medication,
      quantity: 2.0,
      unitPrice: 125.0,
      category: 'Medication',
    );

    final xrayTest = BillingItem.create(
      description: 'Chest X-Ray',
      type: BillingItemType.imaging,
      quantity: 1.0,
      unitPrice: 600.0,
      category: 'Radiology',
    );

    final followUpConsultation = BillingItem.create(
      description: 'Follow-up Consultation',
      type: BillingItemType.consultation,
      quantity: 1.0,
      unitPrice: 500.0,
      category: 'Medical Consultation',
    );

    // Create sample invoices
    final invoices = [
      // Invoice 1: Overdue invoice for John Doe
      Invoice.create(
        patientId: '1',
        patientName: 'John Doe',
        doctorId: 'dr001',
        doctorName: 'Dr. Rajesh Kumar',
        items: [consultationFee, bloodTest, medicine],
        vatRate: 5.0,
        taxRate: 5.0,
        notes: 'Regular health checkup and follow-up consultation. Please bring previous reports for next visit.',
        paymentTermDays: -7, // Make it overdue
      ),
      
      // Invoice 2: Paid invoice for Priya Sharma
      Invoice.create(
        patientId: '2',
        patientName: 'Priya Sharma',
        doctorId: 'dr002',
        doctorName: 'Dr. Priya Sharma',
        items: [followUpConsultation, xrayTest],
        vatRate: 5.0,
        taxRate: 5.0,
        notes: 'Asthma follow-up and chest X-ray examination.',
        paymentTermDays: 30,
      ).copyWith(
        status: InvoiceStatus.paid,
        paidAt: DateTime.now().subtract(Duration(days: 2)),
        paymentMethod: 'Online Payment',
        paymentReference: 'TXN123456789',
      ),
      
      // Invoice 3: Pending invoice for Rajesh Kumar
      Invoice.create(
        patientId: '3',
        patientName: 'Rajesh Kumar',
        doctorId: 'dr001',
        doctorName: 'Dr. Rajesh Kumar',
        items: [consultationFee, bloodTest],
        vatRate: 5.0,
        taxRate: 5.0,
        notes: 'Cholesterol check and general health assessment.',
        paymentTermDays: 15,
      ),
      
      // Invoice 4: Another pending invoice for John Doe
      Invoice.create(
        patientId: '1',
        patientName: 'John Doe',
        doctorId: 'dr003',
        doctorName: 'Dr. Anjali Mehta',
        items: [followUpConsultation],
        vatRate: 5.0,
        taxRate: 5.0,
        notes: 'Diabetes follow-up consultation.',
        paymentTermDays: 20,
      ),
    ];

    // Insert invoices
    for (int i = 0; i < invoices.length; i++) {
      final invoice = invoices[i];
      try {
        final generatedInvoice = await _invoiceService.generateInvoice(
          patientId: invoice.patientId,
          patientName: invoice.patientName,
          doctorId: invoice.doctorId,
          doctorName: invoice.doctorName,
          items: invoice.items,
          vatRate: invoice.vatRate,
          taxRate: invoice.taxRate,
          notes: invoice.notes,
          paymentTermDays: invoice.daysUntilDue,
        );
        
        // If invoice should be paid or overdue, update its status
        if (i == 1) { // Second invoice - mark as paid
          await _invoiceService.markInvoiceAsPaid(
            invoiceId: generatedInvoice.id,
            paymentMethod: 'Online Payment',
            paymentReference: 'TXN123456789',
          );
        }
        
        print('Created invoice: ${generatedInvoice.invoiceNumber} for ${invoice.patientName} - Rs ${generatedInvoice.totalAmount}');
      } catch (e) {
        print('Error creating invoice for ${invoice.patientName}: $e');
      }
    }

    print('Sample data creation completed!');
    
    // Print summary
    print('\n--- Sample Data Summary ---');
    print('Patients created: ${patients.length}');
    print('Invoices created: ${invoices.length}');
    print('Total invoice amount: Rs ${invoices.fold(0.0, (sum, inv) => sum + inv.totalAmount).toStringAsFixed(2)}');
  }
}