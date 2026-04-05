class Payment {
  final String id;
  final String patientId;
  final String doctorId;
  final String appointmentId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String paymentGateway;
  final String status;
  final String transactionId;
  final String gatewayTransactionId;
  final Map<String, dynamic> gatewayResponse;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;

  const Payment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.paymentGateway,
    required this.status,
    required this.transactionId,
    required this.gatewayTransactionId,
    required this.gatewayResponse,
    required this.createdAt,
    this.completedAt,
    this.failureReason,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      patientId: map['patient_id'],
      doctorId: map['doctor_id'],
      appointmentId: map['appointment_id'],
      amount: map['amount']?.toDouble() ?? 0.0,
      currency: map['currency'] ?? 'NPR',
      paymentMethod: map['payment_method'],
      paymentGateway: map['payment_gateway'],
      status: map['status'],
      transactionId: map['transaction_id'],
      gatewayTransactionId: map['gateway_transaction_id'] ?? '',
      gatewayResponse: map['gateway_response'] != null 
          ? Map<String, dynamic>.from(map['gateway_response'])
          : {},
      createdAt: DateTime.parse(map['created_at']),
      completedAt: map['completed_at'] != null 
          ? DateTime.parse(map['completed_at'])
          : null,
      failureReason: map['failure_reason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'appointment_id': appointmentId,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
      'payment_gateway': paymentGateway,
      'status': status,
      'transaction_id': transactionId,
      'gateway_transaction_id': gatewayTransactionId,
      'gateway_response': gatewayResponse,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'failure_reason': failureReason,
    };
  }

  Payment copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? appointmentId,
    double? amount,
    String? currency,
    String? paymentMethod,
    String? paymentGateway,
    String? status,
    String? transactionId,
    String? gatewayTransactionId,
    Map<String, dynamic>? gatewayResponse,
    DateTime? createdAt,
    DateTime? completedAt,
    String? failureReason,
  }) {
    return Payment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      appointmentId: appointmentId ?? this.appointmentId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentGateway: paymentGateway ?? this.paymentGateway,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      gatewayTransactionId: gatewayTransactionId ?? this.gatewayTransactionId,
      gatewayResponse: gatewayResponse ?? this.gatewayResponse,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
    );
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final String displayName;
  final String icon;
  final bool isActive;
  final String gateway;
  final Map<String, dynamic> configuration;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.displayName,
    required this.icon,
    required this.isActive,
    required this.gateway,
    required this.configuration,
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'],
      name: map['name'],
      displayName: map['display_name'],
      icon: map['icon'],
      isActive: map['is_active'] == 1,
      gateway: map['gateway'],
      configuration: Map<String, dynamic>.from(map['configuration']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'icon': icon,
      'is_active': isActive ? 1 : 0,
      'gateway': gateway,
      'configuration': configuration,
    };
  }
}

class BankInfo {
  final String code;
  final String name;
  final String shortName;
  final String logoUrl;
  final String color;
  final bool isActive;
  final List<String> supportedServices;

  const BankInfo({
    required this.code,
    required this.name,
    required this.shortName,
    required this.logoUrl,
    required this.color,
    required this.isActive,
    required this.supportedServices,
  });
}

// Payment status constants
class PaymentStatus {
  static const String pending = 'pending';
  static const String processing = 'processing';
  static const String completed = 'completed';
  static const String failed = 'failed';
  static const String cancelled = 'cancelled';
  static const String refunded = 'refunded';
}

// Payment gateways available in Nepal
class PaymentGateways {
  static const String esewa = 'esewa';
  static const String khalti = 'khalti';
  static const String ime = 'ime';
  static const String connectips = 'connectips';
  static const String fonepay = 'fonepay';
  static const String nicAsia = 'nic_asia';
  static const String prabhupay = 'prabhupay';
  static const String cellpay = 'cellpay';
  static const String sctnpay = 'sctnpay';
}
