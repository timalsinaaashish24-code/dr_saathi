import 'package:flutter/widgets.dart';

/// Analytics service for tracking user behavior and app usage.
/// Works with or without Firebase — all calls are no-ops when Firebase is unavailable.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  dynamic _analytics;
  bool _initialized = false;

  NavigatorObserver? get observer => null;

  /// Initialize Firebase Analytics if available
  void initialize() {
    try {
      _initialized = true;
    } catch (e) {
      _initialized = false;
      print('Analytics running in no-op mode: $e');
    }
  }

  Future<void> _logEvent(String name, [Map<String, Object>? parameters]) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (_) {}
  }

  Future<void> _setUserProperty(String name, String value) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (_) {}
  }

  Future<void> logScreenView(String screenName, String screenClass) async =>
      _logEvent('screen_view', {'screen_name': screenName, 'screen_class': screenClass});
  Future<void> setUserType(String userType) async => _setUserProperty('user_type', userType);
  Future<void> setLanguage(String language) async => _setUserProperty('language', language);
  Future<void> setUserId(String userId) async {
    if (!_initialized || _analytics == null) return;
    try { await _analytics.setUserId(id: userId); } catch (_) {}
  }
  Future<void> logSymptomCheckerOpened() async =>
      _logEvent('symptom_checker_opened', {'timestamp': DateTime.now().toIso8601String()});
  Future<void> logDoctorSearch({String? specialty}) async =>
      _logEvent('find_doctors', {'specialty': specialty ?? 'all', 'timestamp': DateTime.now().toIso8601String()});
  Future<void> logEmergencyServicesAccessed() async =>
      _logEvent('emergency_services_accessed', {'timestamp': DateTime.now().toIso8601String()});
  Future<void> logHealthResourceViewed(String category) async =>
      _logEvent('health_resource_viewed', {'category': category, 'timestamp': DateTime.now().toIso8601String()});
  Future<void> logArticleOpened(String category, String articleTitle) async =>
      _logEvent('article_opened', {'category': category, 'article_title': articleTitle, 'timestamp': DateTime.now().toIso8601String()});
  Future<void> logAppointmentBooked({String? doctorId, String? specialty}) async =>
      _logEvent('appointment_booked', {'doctor_id': doctorId ?? 'unknown', 'specialty': specialty ?? 'unknown', 'timestamp': DateTime.now().toIso8601String()});
  Future<void> logPatientRegistered() async =>
      _logEvent('patient_registered', {'timestamp': DateTime.now().toIso8601String()});
  Future<void> logDoctorLogin() async =>
      _logEvent('doctor_login', {'timestamp': DateTime.now().toIso8601String()});
  Future<void> logPatientLogin() async =>
      _logEvent('patient_login', {'timestamp': DateTime.now().toIso8601String()});
  Future<void> logLanguageChanged(String language) async =>
      _logEvent('language_changed', {'language': language, 'timestamp': DateTime.now().toIso8601String()});
  Future<void> logPaymentInitiated({required String method, required double amount}) async =>
      _logEvent('payment_initiated', {'payment_method': method, 'amount': amount, 'timestamp': DateTime.now().toIso8601String()});
  Future<void> logPaymentCompleted({required String method, required double amount}) async =>
      _logEvent('payment_completed', {'payment_method': method, 'amount': amount, 'timestamp': DateTime.now().toIso8601String()});
  Future<void> logInsuranceInfoViewed() async =>
      _logEvent('insurance_info_viewed', {'timestamp': DateTime.now().toIso8601String()});
  Future<void> logHelpAndSupportOpened(String tab) async =>
      _logEvent('help_and_support_opened', {'tab': tab, 'timestamp': DateTime.now().toIso8601String()});
  Future<void> logAirQualityViewed() async =>
      _logEvent('air_quality_viewed', {'timestamp': DateTime.now().toIso8601String()});
  Future<void> logHealthUpdateClicked(String updateTitle) async =>
      _logEvent('health_update_clicked', {'update_title': updateTitle, 'timestamp': DateTime.now().toIso8601String()});
  Future<void> logCustomEvent(String eventName, Map<String, dynamic> parameters) async =>
      _logEvent(eventName, parameters.map((k, v) => MapEntry(k, v as Object)));
}
