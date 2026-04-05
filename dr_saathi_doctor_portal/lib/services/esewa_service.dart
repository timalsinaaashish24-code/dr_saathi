/*
 * Dr. Saathi - eSewa Payment Gateway Integration
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * Licensed under the MIT License.
 */

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:dr_saathi_doctor_portal/models/payment.dart';

class ESewaConfig {
  static const String sandboxUrl = 'https://uat.esewa.com.np/epay/main';
  static const String productionUrl = 'https://esewa.com.np/epay/main';
  static const String successUrl = 'https://drsaathi.com/payment/success';
  static const String failureUrl = 'https://drsaathi.com/payment/failure';
  
  // Replace with your actual eSewa merchant credentials
  static const String merchantId = 'EPAYTEST'; // Use actual merchant ID in production
  static const String secretKey = '8gBm/:&EnhH.1/q'; // Use actual secret key in production
}

class ESewaService {
  static bool isProduction = false; // Set to true for production
  
  /// Generate eSewa payment URL with required parameters
  static String generatePaymentUrl({
    required String amount,
    required String productId,
    required String productName,
    String? taxAmount,
    String? serviceCharge,
    String? deliveryCharge,
  }) {
    final baseUrl = isProduction ? ESewaConfig.productionUrl : ESewaConfig.sandboxUrl;
    
    final params = {
      'tAmt': amount,
      'amt': amount,
      'txAmt': taxAmount ?? '0',
      'psc': serviceCharge ?? '0',
      'pdc': deliveryCharge ?? '0',
      'scd': ESewaConfig.merchantId,
      'pid': productId,
      'pname': productName,
      'su': ESewaConfig.successUrl,
      'fu': ESewaConfig.failureUrl,
    };
    
    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return '$baseUrl?$queryString';
  }
  
  /// Verify payment with eSewa
  static Future<bool> verifyPayment({
    required String refId,
    required String amount,
    required String productId,
  }) async {
    try {
      final verificationUrl = isProduction 
          ? 'https://esewa.com.np/epay/transrec'
          : 'https://uat.esewa.com.np/epay/transrec';
      
      // In a real implementation, you would make an HTTP request to verify
      // For now, we'll return true for demo purposes
      return true;
    } catch (e) {
      print('Payment verification failed: $e');
      return false;
    }
  }
  
  /// Launch eSewa payment in WebView
  static void launchPayment({
    required BuildContext context,
    required Payment payment,
    required Function(bool success, String? refId) onPaymentComplete,
  }) {
    final url = generatePaymentUrl(
      amount: payment.amount.toString(),
      productId: payment.id,
      productName: 'Dr. Saathi Consultation',
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ESewaWebView(
          url: url,
          onPaymentComplete: onPaymentComplete,
        ),
      ),
    );
  }
}

class ESewaWebView extends StatefulWidget {
  final String url;
  final Function(bool success, String? refId) onPaymentComplete;
  
  const ESewaWebView({
    Key? key,
    required this.url,
    required this.onPaymentComplete,
  }) : super(key: key);
  
  @override
  _ESewaWebViewState createState() => _ESewaWebViewState();
}

class _ESewaWebViewState extends State<ESewaWebView> {
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
            if (url.contains(ESewaConfig.successUrl)) {
              // Extract reference ID from URL
              final uri = Uri.parse(url);
              final refId = uri.queryParameters['refId'];
              widget.onPaymentComplete(true, refId);
              Navigator.pop(context);
            } else if (url.contains(ESewaConfig.failureUrl)) {
              widget.onPaymentComplete(false, null);
              Navigator.pop(context);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eSewa Payment'),
        backgroundColor: Colors.green[600],
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
