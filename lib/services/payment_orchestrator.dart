/*
 * Dr. Saathi - Payment Orchestration Service
 * Automates doctor payments when patient payments are verified
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

import '../models/bank_transfer.dart';
import '../models/doctor_payment.dart';
import '../services/bank_transfer_service.dart';
import '../services/doctor_payment_service.dart';

class PaymentOrchestrator {
  final BankTransferService _bankTransferService = BankTransferService();
  final DoctorPaymentService _doctorPaymentService;

  PaymentOrchestrator({CommissionConfig? commissionConfig})
      : _doctorPaymentService = DoctorPaymentService(config: commissionConfig);

  /// Called when a patient's bank transfer is verified
  /// Automatically creates a pending payment for the doctor
  Future<DoctorPayment?> onPatientPaymentVerified({
    required String patientTransferId,
    required String doctorId,
    String? appointmentId,
    String? invoiceId,
    required String doctorBankName,
    required String doctorAccountNumber,
    required String doctorAccountName,
  }) async {
    try {
      // Get patient transfer details
      final transfer = await _bankTransferService.getTransferById(patientTransferId);
      
      if (transfer == null) {
        print('Transfer not found: $patientTransferId');
        return null;
      }

      if (transfer.status != BankTransferStatus.verified) {
        print('Transfer not verified yet: $patientTransferId');
        return null;
      }

      // Create doctor payment
      final doctorPayment = await _doctorPaymentService.createDoctorPayment(
        doctorId: doctorId,
        patientPaymentId: patientTransferId,
        totalAmount: transfer.amount,
        appointmentId: appointmentId,
        invoiceId: invoiceId,
        doctorBankName: doctorBankName,
        doctorAccountNumber: doctorAccountNumber,
        doctorAccountName: doctorAccountName,
      );

      print('Doctor payment created: ${doctorPayment.id}');
      print('  Doctor will receive: NPR ${doctorPayment.netPayable.toStringAsFixed(2)}');
      print('  Platform commission: NPR ${doctorPayment.platformCommission.toStringAsFixed(2)}');
      
      return doctorPayment;
    } catch (e) {
      print('Error creating doctor payment: $e');
      return null;
    }
  }

  /// Process pending doctor payments (manual or scheduled)
  /// This initiates the actual bank transfer to doctor's account
  Future<void> processPendingPayments({
    required String adminId,
    int? limit,
  }) async {
    try {
      // Get pending payments
      final pendingPayments = await _doctorPaymentService.getPendingPayments();
      
      if (pendingPayments.isEmpty) {
        print('No pending payments to process');
        return;
      }

      final paymentsToProcess = limit != null 
          ? pendingPayments.take(limit).toList()
          : pendingPayments;

      print('Processing ${paymentsToProcess.length} doctor payments...');

      for (final payment in paymentsToProcess) {
        try {
          // Mark as processing
          await _doctorPaymentService.markAsProcessing(payment.id, adminId);
          
          // Here you would integrate with your bank's API to initiate transfer
          // For now, we'll simulate this
          
          // TODO: Integrate with bank API
          // final transactionId = await initiateBank Transfer(payment);
          
          // For demonstration, we'll generate a mock transaction ID
          final mockTransactionId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
          
          // Simulate processing delay
          await Future.delayed(const Duration(seconds: 1));
          
          // Mark as completed (in reality, this would be after bank confirms)
          await _doctorPaymentService.markAsCompleted(
            payment.id,
            mockTransactionId,
          );
          
          print('Payment completed: ${payment.id}');
          print('  Doctor: ${payment.doctorId}');
          print('  Amount: NPR ${payment.netPayable.toStringAsFixed(2)}');
          print('  Transaction ID: $mockTransactionId');
          
        } catch (e) {
          // Mark as failed
          await _doctorPaymentService.markAsFailed(
            payment.id,
            'Error processing payment: $e',
          );
          print('Payment failed: ${payment.id} - $e');
        }
      }
      
      print('Payment processing complete');
    } catch (e) {
      print('Error in payment processing: $e');
    }
  }

  /// Get payment breakdown for a transaction
  Future<Map<String, dynamic>?> getPaymentBreakdown(String patientTransferId) async {
    try {
      final transfer = await _bankTransferService.getTransferById(patientTransferId);
      if (transfer == null) return null;

      final config = _doctorPaymentService.commissionConfig;
      final commission = config.calculateCommission(transfer.amount);
      final doctorAmount = transfer.amount - commission;
      final tax = config.calculateTax(doctorAmount);
      final netPayable = doctorAmount - tax;

      return {
        'total_amount': transfer.amount,
        'platform_commission': commission,
        'platform_commission_rate': config.defaultRate,
        'doctor_gross': doctorAmount,
        'tax_deducted': tax,
        'tax_rate': config.taxRate,
        'doctor_net': netPayable,
      };
    } catch (e) {
      print('Error calculating breakdown: $e');
      return null;
    }
  }

  /// Bulk process all pending payments
  Future<Map<String, int>> bulkProcessAllPending(String adminId) async {
    final stats = {
      'total': 0,
      'success': 0,
      'failed': 0,
    };

    try {
      final pending = await _doctorPaymentService.getPendingPayments();
      stats['total'] = pending.length;

      for (final payment in pending) {
        try {
          await _doctorPaymentService.markAsProcessing(payment.id, adminId);
          
          // Simulate bank transfer
          final mockTxnId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
          await Future.delayed(const Duration(milliseconds: 500));
          
          await _doctorPaymentService.markAsCompleted(payment.id, mockTxnId);
          stats['success'] = (stats['success'] ?? 0) + 1;
        } catch (e) {
          await _doctorPaymentService.markAsFailed(payment.id, e.toString());
          stats['failed'] = (stats['failed'] ?? 0) + 1;
        }
      }
    } catch (e) {
      print('Bulk process error: $e');
    }

    return stats;
  }

  /// Schedule automatic payment processing (call this daily or weekly)
  Future<void> scheduledPaymentRun(String systemId) async {
    print('Starting scheduled payment run...');
    
    final stats = await bulkProcessAllPending(systemId);
    
    print('Scheduled payment run complete:');
    print('  Total: ${stats['total']}');
    print('  Success: ${stats['success']}');
    print('  Failed: ${stats['failed']}');
  }
}
