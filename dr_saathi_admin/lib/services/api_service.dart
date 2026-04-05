import 'package:dr_saathi_api/dr_saathi_api.dart';

/// Service that connects the Admin app to the cloud backend API.
/// Falls back to mock data when server is unreachable.
class AdminApiService {
  final AdminApi _adminApi = AdminApi();
  final DoctorApi _doctorApi = DoctorApi();
  final PatientApi _patientApi = PatientApi();
  final AppointmentApi _appointmentApi = AppointmentApi();
  final AuthApi _authApi = AuthApi();
  final SyncApi _syncApi = SyncApi();

  // ============================================================
  // Auth
  // ============================================================

  Future<ApiResponse> login(String email, String password) async {
    return _authApi.login(email: email, password: password);
  }

  Future<void> logout() async => _authApi.logout();

  // ============================================================
  // Dashboard — aggregated data for admin home
  // ============================================================

  Future<ApiResponse> getDashboard() async => _adminApi.getDashboard();

  // ============================================================
  // Analytics
  // ============================================================

  Future<ApiResponse> getUserAnalytics({int period = 30}) async => _adminApi.getUserAnalytics(period: period);
  Future<ApiResponse> getAppointmentAnalytics({int period = 30}) async => _adminApi.getAppointmentAnalytics(period: period);
  Future<ApiResponse> getRevenueAnalytics({int period = 30}) async => _adminApi.getRevenueAnalytics(period: period);

  // ============================================================
  // Doctor Management
  // ============================================================

  Future<ApiResponse> listDoctors({String? search, String? status}) async => _doctorApi.listDoctors(search: search, status: status);
  Future<ApiResponse> getPendingDoctors() async => _adminApi.getPendingDoctors();
  Future<ApiResponse> verifyDoctor(String id) async => _doctorApi.verifyDoctor(id);
  Future<ApiResponse> suspendDoctor(String id, {String? reason}) async => _doctorApi.suspendDoctor(id, reason: reason);
  Future<ApiResponse> rejectDoctor(String id, {String? reason}) async => _doctorApi.rejectDoctor(id, reason: reason);

  // ============================================================
  // Patient Management
  // ============================================================

  Future<ApiResponse> listPatients({String? search}) async => _patientApi.listPatients(search: search);
  Future<ApiResponse> getPatient(String id) async => _patientApi.getPatient(id);
  Future<ApiResponse> deletePatient(String id) async => _patientApi.deletePatient(id);

  // ============================================================
  // Appointments
  // ============================================================

  Future<ApiResponse> listAppointments({String? status, String? date}) async => _appointmentApi.listAppointments(status: status, date: date);
  Future<ApiResponse> cancelAppointment(String id, String reason) async => _appointmentApi.cancelWithRefund(id, reason);
  Future<ApiResponse> getAppointmentStats() async => _appointmentApi.getStats();

  // ============================================================
  // Payments & Refunds
  // ============================================================

  Future<ApiResponse> getPaymentHolds() async => _adminApi.getPaymentHolds();
  Future<ApiResponse> getRefunds() async => _adminApi.getRefunds();
  Future<ApiResponse> releaseExpiredHolds() async => _adminApi.releaseExpiredHolds();

  // ============================================================
  // Fee Configuration
  // ============================================================

  Future<ApiResponse> getFeeConfig() async => _adminApi.getFeeConfig();
  Future<ApiResponse> updateFeeConfig(String key, dynamic value) async => _adminApi.updateFeeConfig(key, value);

  // ============================================================
  // Compliance & Audit
  // ============================================================

  Future<ApiResponse> getAuditLog({int page = 1, String? action}) async => _adminApi.getAuditLog(page: page, action: action);
  Future<ApiResponse> getRegionalCoverage() async => _adminApi.getRegionalCoverage();

  // ============================================================
  // Announcements
  // ============================================================

  Future<ApiResponse> createAnnouncement(Map<String, dynamic> data) async => _adminApi.createAnnouncement(data);

  // ============================================================
  // Data Sync
  // ============================================================

  Future<ApiResponse> syncPull({String? lastSyncAt}) async => _syncApi.pull(lastSyncAt: lastSyncAt);
  Future<ApiResponse> syncPush(List<Map<String, dynamic>> changes) async => _syncApi.push(changes);
}
