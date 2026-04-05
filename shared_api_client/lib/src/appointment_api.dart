import 'api_client.dart';

class AppointmentApi {
  final _client = ApiClient();

  Future<ApiResponse> listAppointments({int page = 1, int limit = 20, String? status, String? date, String? doctorId, String? patientId}) async {
    return _client.get('/appointments', queryParams: {'page': '$page', 'limit': '$limit', if (status != null) 'status': status, if (date != null) 'date': date, if (doctorId != null) 'doctor_id': doctorId, if (patientId != null) 'patient_id': patientId});
  }

  Future<ApiResponse> createAppointment(Map<String, dynamic> data) async => _client.post('/appointments', body: data);
  Future<ApiResponse> updateStatus(String id, String status, {String? notes}) async => _client.put('/appointments/$id/status', body: {'status': status, if (notes != null) 'notes': notes});
  Future<ApiResponse> cancelWithRefund(String id, String reason) async => _client.post('/appointments/$id/cancel', body: {'reason': reason});
  Future<ApiResponse> getStats() async => _client.get('/appointments/stats/summary');
}
