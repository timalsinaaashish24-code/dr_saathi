import 'package:dr_saathi/models/payment.dart';
import 'package:dio/dio.dart';

class PaymentService {
  final Dio _dio;

  PaymentService({Dio? dio}) : _dio = dio ?? Dio();

  Future<Payment?> initiatePayment(Payment payment) async {
    try {
      // Mock API endpoint
      final response = await _dio.post('https://mock-payment-gateway/api/payments',
          data: payment.toMap());

      if (response.statusCode == 200) {
        return Payment.fromMap(response.data);
      }
    } catch (e) {
      // Handle exception
    }
    return null;
  }

  Future<Payment?> completePayment(String paymentId, String transactionId) async {
    try {
      final response = await _dio.patch(
        'https://mock-payment-gateway/api/payments/$paymentId/complete',
        data: {'transaction_id': transactionId},
      );

      if (response.statusCode == 200) {
        return Payment.fromMap(response.data);
      }
    } catch (e) {
      // Handle exception
    }
    return null;
  }

  Future<Payment?> checkPaymentStatus(String paymentId) async {
    try {
      final response = await _dio.get('https://mock-payment-gateway/api/payments/$paymentId');

      if (response.statusCode == 200) {
        return Payment.fromMap(response.data);
      }
    } catch (e) {
      // Handle exception
    }
    return null;
  }

  // Add methods for refund, cancel, etc. if needed.

}
