import 'package:dr_saathi_api/dr_saathi_api.dart';

/// Service that connects the Dr Saathi patient app to the cloud backend API.
/// All data changes are synced to the central server so Admin and Doctor apps see them.
class PatientApiService {
  final AuthApi _authApi = AuthApi();
  final PatientApi _patientApi = PatientApi();
  final DoctorApi _doctorApi = DoctorApi();
  final AppointmentApi _appointmentApi = AppointmentApi();
  final SyncApi _syncApi = SyncApi();

  // Auth
  Future<ApiResponse> login(String email, String password) async => _authApi.login(email: email, password: password);
  Future<ApiResponse> register({required String email, required String password, required String name, String? phone}) async {
    return _authApi.register(email: email, password: password, role: 'patient', name: name, phone: phone);
  }
  Future<void> logout() async => _authApi.logout();

  // Patient profile
  Future<ApiResponse> getProfile(String id) async => _patientApi.getPatient(id);
  Future<ApiResponse> updateProfile(String id, Map<String, dynamic> data) async => _patientApi.updatePatient(id, data);
  Future<ApiResponse> getMedicalHistory(String id) async => _patientApi.getMedicalHistory(id);

  // Doctors — browse available doctors
  Future<ApiResponse> listDoctors({String? search, String? specialization}) async => _doctorApi.listDoctors(search: search, specialization: specialization);
  Future<ApiResponse> getDoctor(String id) async => _doctorApi.getDoctor(id);

  // Appointments
  Future<ApiResponse> bookAppointment(Map<String, dynamic> data) async => _appointmentApi.createAppointment(data);
  Future<ApiResponse> getMyAppointments({String? status}) async => _appointmentApi.listAppointments(status: status);
  Future<ApiResponse> cancelAppointment(String id, String reason) async => _appointmentApi.cancelWithRefund(id, reason);

  // Sync
  Future<ApiResponse> syncPull({String? lastSyncAt}) async => _syncApi.pull(lastSyncAt: lastSyncAt, tables: ['appointments', 'prescriptions', 'doctors']);
  Future<ApiResponse> syncPush(List<Map<String, dynamic>> changes) async => _syncApi.push(changes);
}
