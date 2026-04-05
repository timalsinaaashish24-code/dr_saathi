import 'package:dr_saathi_api/dr_saathi_api.dart';

/// Service that connects the Doctor Portal to the cloud backend API.
/// All data changes are synced to the central server so Admin app sees them.
class DoctorPortalApiService {
  final AuthApi _authApi = AuthApi();
  final DoctorApi _doctorApi = DoctorApi();
  final AppointmentApi _appointmentApi = AppointmentApi();
  final PatientApi _patientApi = PatientApi();
  final SyncApi _syncApi = SyncApi();

  // Auth
  Future<ApiResponse> login(String email, String password) async => _authApi.login(email: email, password: password);
  Future<ApiResponse> register({required String email, required String password, required String name, required String licenseNumber, String? specialization, String? phone}) async {
    return _authApi.register(email: email, password: password, role: 'doctor', name: name, licenseNumber: licenseNumber, specialization: specialization, phone: phone);
  }
  Future<void> logout() async => _authApi.logout();

  // Doctor profile
  Future<ApiResponse> getProfile(String id) async => _doctorApi.getDoctor(id);
  Future<ApiResponse> updateProfile(String id, Map<String, dynamic> data) async => _doctorApi.updateDoctor(id, data);
  Future<ApiResponse> verifyNMC(String nmcNumber) async => _doctorApi.verifyNMC(nmcNumber);

  // Appointments
  Future<ApiResponse> getAppointments({String? status, String? date}) async => _appointmentApi.listAppointments(status: status, date: date);
  Future<ApiResponse> updateAppointmentStatus(String id, String status, {String? notes}) async => _appointmentApi.updateStatus(id, status, notes: notes);
  Future<ApiResponse> cancelAppointment(String id, String reason) async => _appointmentApi.cancelWithRefund(id, reason);
  Future<ApiResponse> getStats() async => _appointmentApi.getStats();

  // Patients (doctor's patients only — API filters by role)
  Future<ApiResponse> getPatients({String? search}) async => _patientApi.listPatients(search: search);
  Future<ApiResponse> getPatientHistory(String id) async => _patientApi.getMedicalHistory(id);

  // Sync — push local changes & pull latest data
  Future<ApiResponse> syncPull({String? lastSyncAt}) async => _syncApi.pull(lastSyncAt: lastSyncAt, tables: ['appointments', 'prescriptions', 'patients']);
  Future<ApiResponse> syncPush(List<Map<String, dynamic>> changes) async => _syncApi.push(changes);
}
