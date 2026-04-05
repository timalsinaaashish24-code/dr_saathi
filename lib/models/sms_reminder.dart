class SmsReminder {
  final String id;
  final String patientId;
  final String patientName;
  final String phoneNumber;
  final String message;
  final DateTime scheduledTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SmsReminderType type;
  final SmsReminderStatus status;
  final String? errorMessage;
  final int retryCount;
  final bool synced;

  SmsReminder({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.phoneNumber,
    required this.message,
    required this.scheduledTime,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
    this.status = SmsReminderStatus.pending,
    this.errorMessage,
    this.retryCount = 0,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'phoneNumber': phoneNumber,
      'message': message,
      'scheduledTime': scheduledTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'type': type.toString(),
      'status': status.toString(),
      'errorMessage': errorMessage,
      'retryCount': retryCount,
      'synced': synced ? 1 : 0,
    };
  }

  factory SmsReminder.fromMap(Map<String, dynamic> map) {
    return SmsReminder(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      message: map['message'] ?? '',
      scheduledTime: DateTime.parse(map['scheduledTime']),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      type: SmsReminderType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => SmsReminderType.appointment,
      ),
      status: SmsReminderStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => SmsReminderStatus.pending,
      ),
      errorMessage: map['errorMessage'],
      retryCount: map['retryCount'] ?? 0,
      synced: map['synced'] == 1,
    );
  }

  SmsReminder copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? phoneNumber,
    String? message,
    DateTime? scheduledTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    SmsReminderType? type,
    SmsReminderStatus? status,
    String? errorMessage,
    int? retryCount,
    bool? synced,
  }) {
    return SmsReminder(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      message: message ?? this.message,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
      synced: synced ?? this.synced,
    );
  }

  bool get isPending => status == SmsReminderStatus.pending;
  bool get isSent => status == SmsReminderStatus.sent;
  bool get isFailed => status == SmsReminderStatus.failed;
  bool get isCancelled => status == SmsReminderStatus.cancelled;
  bool get isOverdue => scheduledTime.isBefore(DateTime.now()) && isPending;

  String get statusDisplayName {
    switch (status) {
      case SmsReminderStatus.pending:
        return 'Pending';
      case SmsReminderStatus.sent:
        return 'Sent';
      case SmsReminderStatus.failed:
        return 'Failed';
      case SmsReminderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case SmsReminderType.appointment:
        return 'Appointment';
      case SmsReminderType.medication:
        return 'Medication';
      case SmsReminderType.followUp:
        return 'Follow-up';
      case SmsReminderType.general:
        return 'General';
    }
  }

  @override
  String toString() {
    return 'SmsReminder{id: $id, patientName: $patientName, phoneNumber: $phoneNumber, scheduledTime: $scheduledTime, type: $type, status: $status}';
  }
}

enum SmsReminderType {
  appointment,
  medication,
  followUp,
  general,
}

enum SmsReminderStatus {
  pending,
  sent,
  failed,
  cancelled,
}

class SmsTemplate {
  final String id;
  final String name;
  final String template;
  final SmsReminderType type;
  final DateTime createdAt;
  final DateTime updatedAt;

  SmsTemplate({
    required this.id,
    required this.name,
    required this.template,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'template': template,
      'type': type.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SmsTemplate.fromMap(Map<String, dynamic> map) {
    return SmsTemplate(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      template: map['template'] ?? '',
      type: SmsReminderType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => SmsReminderType.general,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  String generateMessage({
    required String patientName,
    required String clinicName,
    required DateTime appointmentTime,
    String? doctorName,
    String? additionalInfo,
  }) {
    String message = template;
    
    // Replace placeholders with actual values
    message = message.replaceAll('{patientName}', patientName);
    message = message.replaceAll('{clinicName}', clinicName);
    message = message.replaceAll('{appointmentTime}', 
        '${appointmentTime.day}/${appointmentTime.month}/${appointmentTime.year} at ${appointmentTime.hour}:${appointmentTime.minute.toString().padLeft(2, '0')}');
    message = message.replaceAll('{doctorName}', doctorName ?? 'Doctor');
    message = message.replaceAll('{additionalInfo}', additionalInfo ?? '');
    
    return message;
  }

  @override
  String toString() {
    return 'SmsTemplate{id: $id, name: $name, type: $type}';
  }
}
