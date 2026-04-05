/*
 * Dr. Saathi - Khalti Payment Gateway Integration
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:dr_saathi_doctor_portal/models/payment.dart';

class KhaltiConfig {
  static const String sandboxUrl = 'https://a.khalti.com/api/v2/epayment/initiate/';
  static const String productionUrl = 'https://khalti.com/api/v2/epayment/initiate/';
  static const String successUrl = 'https://drsaathi.com/payment/khalti/success';
  static const String failureUrl = 'https://drsaathi.com/payment/khalti/failure';
  static const String websiteUrl = 'https://drsaathi.com';
  
  // Replace with your actual Khalti credentials
  static const String publicKey = 'test_public_key_dc74e0fd57cb46cd93832aee0a507256'; // Test key
  static const String secretKey = 'test_secret_key_f59e8b7d18b4499ca40f68195a846e9b'; // Test key
}

class KhaltiService {
  static bool isProduction = false; // Set to true for production
  static final Dio _dio = Dio();
  
  /// Initialize Khalti payment
  static Future<String?> initiatePayment({
    required Payment payment,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) async {
    try {
      final url = isProduction ? KhaltiConfig.productionUrl : KhaltiConfig.sandboxUrl;
      
      final headers = {
        'Authorization': 'Key ${KhaltiConfig.secretKey}',
        'Content-Type': 'application/json',
      };
      
      final data = {
        'return_url': KhaltiConfig.successUrl,
        'website_url': KhaltiConfig.websiteUrl,
        'amount': (payment.amount * 100).toInt(), // Amount in paisa
        'purchase_order_id': payment.id,
        'purchase_order_name': 'Dr. Saathi Consultation',
        'customer_info': {
          'name': customerName,
          'email': customerEmail,
          'phone': customerPhone,
        },
        'amount_breakdown': [
          {
            'label': 'Consultation Fee',
            'amount': (payment.amount * 100).toInt(),
          }
        ],
        'product_details': [
          {
            'identity': payment.appointmentId,
            'name': 'Medical Consultation',
            'total_price': (payment.amount * 100).toInt(),
            'quantity': 1,
            'unit_price': (payment.amount * 100).toInt(),
          }
        ],
      };
      
      final response = await _dio.post(
        url,
        data: jsonEncode(data),
        options: Options(headers: headers),
      );
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['payment_url'];
      }
    } catch (e) {
      print('Khalti payment initiation failed: $e');
    }
    return null;
  }
  
  /// Verify Khalti payment
  static Future<bool> verifyPayment({
    required String pidx,
  }) async {
    try {
      final url = isProduction 
          ? 'https://khalti.com/api/v2/epayment/lookup/'
          : 'https://a.khalti.com/api/v2/epayment/lookup/';
      
      final headers = {
        'Authorization': 'Key ${KhaltiConfig.secretKey}',
        'Content-Type': 'application/json',
      };
      
      final data = {'pidx': pidx};
      
      final response = await _dio.post(
        url,
        data: jsonEncode(data),
        options: Options(headers: headers),
      );
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        return responseData['status'] == 'Completed';
      }
    } catch (e) {
      print('Khalti payment verification failed: $e');
    }
    return false;
  }
  
  /// Launch Khalti payment in WebView
  static void launchPayment({
    required BuildContext context,
    required Payment payment,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required Function(bool success, String? pidx) onPaymentComplete,
  }) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    final paymentUrl = await initiatePayment(
      payment: payment,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
    );
    
    Navigator.pop(context); // Close loading dialog
    
    if (paymentUrl != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KhaltiWebView(
            url: paymentUrl,
            onPaymentComplete: onPaymentComplete,
          ),
        ),
      );
    } else {
      onPaymentComplete(false, null);
    }
  }
}

class KhaltiWebView extends StatefulWidget {
  final String url;
  final Function(bool success, String? pidx) onPaymentComplete;
  
  const KhaltiWebView({
    Key? key,
    required this.url,
    required this.onPaymentComplete,
  }) : super(key: key);
  
  @override
  _KhaltiWebViewState createState() => _KhaltiWebViewState();
}

class _KhaltiWebViewState extends State<KhaltiWebView> {
  late WebViewController controller;
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            
            // Check if payment is completed
            if (url.contains(KhaltiConfig.successUrl)) {
              // Extract pidx from URL
              final uri = Uri.parse(url);
              final pidx = uri.queryParameters['pidx'];
              widget.onPaymentComplete(true, pidx);
              Navigator.pop(context);
            } else if (url.contains(KhaltiConfig.failureUrl)) {
              widget.onPaymentComplete(false, null);
              Navigator.pop(context);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Handle navigation requests
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khalti Payment'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

/// Khalti payment button widget for easy integration
class KhaltiPayButton extends StatelessWidget {
  final Payment payment;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final Function(bool success, String? pidx) onPaymentComplete;
  
  const KhaltiPayButton({
    Key? key,
    required this.payment,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.onPaymentComplete,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        KhaltiService.launchPayment(
          context: context,
          payment: payment,
          customerName: customerName,
          customerEmail: customerEmail,
          customerPhone: customerPhone,
          onPaymentComplete: onPaymentComplete,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Text(
                'K',
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text('Pay with Khalti'),
        ],
      ),
    );
  }
}
