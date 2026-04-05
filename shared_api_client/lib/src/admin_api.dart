import 'api_client.dart';

class AdminApi {
  final _client = ApiClient();

  // Dashboard
  Future<ApiResponse> getDashboard() async => _client.get('/admin/dashboard');

  // Analytics
  Future<ApiResponse> getUserAnalytics({int period = 30}) async => _client.get('/admin/analytics/users', queryParams: {'period': '$period'});
  Future<ApiResponse> getAppointmentAnalytics({int period = 30}) async => _client.get('/admin/analytics/appointments', queryParams: {'period': '$period'});
  Future<ApiResponse> getRevenueAnalytics({int period = 30}) async => _client.get('/admin/analytics/revenue', queryParams: {'period': '$period'});

  // Doctor management
  Future<ApiResponse> getPendingDoctors() async => _client.get('/admin/doctors/pending');

  // Payments
  Future<ApiResponse> getPaymentHolds() async => _client.get('/admin/payments/holds');
  Future<ApiResponse> getRefunds() async => _client.get('/admin/payments/refunds');
  Future<ApiResponse> releaseExpiredHolds() async => _client.post('/admin/release-holds');

  // Fee config
  Future<ApiResponse> getFeeConfig() async => _client.get('/admin/fee-config');
  Future<ApiResponse> updateFeeConfig(String key, dynamic value) async => _client.put('/admin/fee-config', body: {'key': key, 'value': value});

  // Audit & compliance
  Future<ApiResponse> getAuditLog({int page = 1, int limit = 50, String? action}) async {
    return _client.get('/admin/audit-log', queryParams: {'page': '$page', 'limit': '$limit', if (action != null) 'action': action});
  }

  // Regional coverage
  Future<ApiResponse> getRegionalCoverage() async => _client.get('/admin/regional-coverage');

  // Announcements
  Future<ApiResponse> createAnnouncement(Map<String, dynamic> data) async => _client.post('/admin/announcements', body: data);
}
