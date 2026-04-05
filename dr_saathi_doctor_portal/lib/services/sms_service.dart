import 'dart:async';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../models/sms_reminder.dart';
import 'database_service.dart';

class SmsService {
  static final SmsService _instance = SmsService._internal();
  static const String _twilioBaseUrl = 'https://api.twilio.com/2010-04-01/Accounts';
  static const String _twilioAccountSid = 'YOUR_TWILIO_ACCOUNT_SID'; // Replace with your Twilio SID
  static const String _twilioAuthToken = 'YOUR_TWILIO_AUTH_TOKEN'; // Replace with your Twilio token
  static const String _twilioPhoneNumber = 'YOUR_TWILIO_PHONE_NUMBER'; // Replace with your Twilio phone number
  
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final DatabaseService _databaseService = DatabaseService();
  
  SmsService._internal();
  
  factory SmsService() {
    return _instance;
  }

  /// Initialize the SMS service
  Future<void> initialize() async {
    await _initializeNotifications();
  }

  /// Initialize local notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  /// Handle notification response
  void _onNotificationResponse(NotificationResponse response) async {
    if (response.payload != null) {
      final reminder = SmsReminder.fromMap(jsonDecode(response.payload!));
      await _handleScheduledSms(reminder);
    }
  }

  /// Request necessary permissions for sending SMS
  Future<bool> requestSmsPermission() async {
    final smsStatus = await Permission.sms.request();
    final notificationStatus = await Permission.notification.request();
    return smsStatus.isGranted && notificationStatus.isGranted;
  }

  /// Send an SMS immediately using device's SMS app
  Future<void> sendSmsViaDevice(String phoneNumber, String message) async {
    final uri = Uri.parse('sms:$phoneNumber?body=${Uri.encodeComponent(message)}');
    if (!await launchUrl(uri)) {
      throw 'Could not send SMS';
    }
  }

  /// Send an SMS via Twilio API (requires internet connection)
  Future<bool> sendSmsViaTwilio(String phoneNumber, String message) async {
    try {
      final credentials = base64Encode(utf8.encode('$_twilioAccountSid:$_twilioAuthToken'));
      
      final response = await http.post(
        Uri.parse('$_twilioBaseUrl/$_twilioAccountSid/Messages.json'),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': _twilioPhoneNumber,
          'To': phoneNumber,
          'Body': message,
        },
      );
      
      return response.statusCode == 201;
    } catch (e) {
      print('Error sending SMS via Twilio: $e');
      return false;
    }
  }

  /// Schedule an SMS reminder
  Future<void> scheduleReminder(SmsReminder reminder) async {
    // Save reminder to database
    await _databaseService.insertSmsReminder(reminder);
    
    // Schedule local notification
    await _scheduleNotification(reminder);
  }

  /// Schedule a local notification for the reminder
  Future<void> _scheduleNotification(SmsReminder reminder) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'sms_reminders',
      'SMS Reminders',
      channelDescription: 'Notifications for scheduled SMS reminders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    // For now, we'll show an immediate notification
    // In a full implementation, you would use a background task scheduler
    await _flutterLocalNotificationsPlugin.show(
      reminder.id.hashCode,
      'SMS Reminder Scheduled',
      'Reminder set for ${reminder.patientName} at ${reminder.scheduledTime}',
      platformChannelSpecifics,
      payload: jsonEncode(reminder.toMap()),
    );
  }

  /// Cancel a scheduled SMS reminder
  Future<void> cancelReminder(String reminderId) async {
    // Cancel notification
    await _flutterLocalNotificationsPlugin.cancel(reminderId.hashCode);
    
    // Update reminder status in database
    await _databaseService.updateSmsReminderStatus(
      reminderId,
      SmsReminderStatus.cancelled,
    );
  }

  /// Handle sending the SMS when the scheduled time arrives
  Future<void> _handleScheduledSms(SmsReminder reminder) async {
    try {
      bool success = false;
      
      // Try to send via Twilio first (if online)
      success = await sendSmsViaTwilio(reminder.phoneNumber, reminder.message);
      
      if (!success) {
        // Fallback to device SMS app
        await sendSmsViaDevice(reminder.phoneNumber, reminder.message);
        success = true; // Assume success since we opened the SMS app
      }
      
      // Update reminder status
      await _databaseService.updateSmsReminderStatus(
        reminder.id,
        success ? SmsReminderStatus.sent : SmsReminderStatus.failed,
      );
      
    } catch (e) {
      print('Failed to send SMS: $e');
      await _databaseService.updateSmsReminderStatus(
        reminder.id,
        SmsReminderStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  /// Get all pending reminders
  Future<List<SmsReminder>> getPendingReminders() async {
    return await _databaseService.getPendingReminders();
  }

  /// Get all reminders for a specific patient
  Future<List<SmsReminder>> getPatientReminders(String patientId) async {
    return await _databaseService.getPatientReminders(patientId);
  }

  /// Get reminder statistics
  Future<Map<String, int>> getReminderStats() async {
    return await _databaseService.getReminderStats();
  }

  /// Send immediate SMS to patient
  Future<void> sendImmediateSms({
    required String patientId,
    required String patientName,
    required String phoneNumber,
    required String message,
    required SmsReminderType type,
  }) async {
    final reminder = SmsReminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patientId,
      patientName: patientName,
      phoneNumber: phoneNumber,
      message: message,
      scheduledTime: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      type: type,
    );
    
    await _handleScheduledSms(reminder);
  }

  /// Check and process overdue reminders
  Future<void> processOverdueReminders() async {
    final overdueReminders = await _databaseService.getOverdueReminders();
    
    for (final reminder in overdueReminders) {
      await _handleScheduledSms(reminder);
    }
  }

  /// Create default SMS templates
  Future<void> createDefaultTemplates() async {
    final templates = [
      SmsTemplate(
        id: 'appointment_reminder',
        name: 'Appointment Reminder',
        template: 'Dear {patientName}, this is a reminder for your appointment with {doctorName} at {clinicName} on {appointmentTime}. Please arrive 15 minutes early. Thank you.',
        type: SmsReminderType.appointment,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      SmsTemplate(
        id: 'medication_reminder',
        name: 'Medication Reminder',
        template: 'Dear {patientName}, this is a reminder to take your prescribed medication. Please follow the dosage instructions provided by your doctor. {additionalInfo}',
        type: SmsReminderType.medication,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      SmsTemplate(
        id: 'followup_reminder',
        name: 'Follow-up Reminder',
        template: 'Dear {patientName}, it\'s time for your follow-up appointment with {doctorName} at {clinicName}. Please schedule your appointment at your earliest convenience.',
        type: SmsReminderType.followUp,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    
    for (final template in templates) {
      await _databaseService.insertSmsTemplate(template);
    }
  }
}

