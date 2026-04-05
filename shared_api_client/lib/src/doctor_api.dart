import 'api_client.dart';

class DoctorApi {
  final _client = ApiClient();

  Future<ApiResponse> listDoctors({int page = 1, int limit = 20, String? search, String? specialization, String? status}) async {
    return _client.get('/doctors', queryParams: {'page': '$page', 'limit': '$limit', if (search != null) 'search': search, if (specialization != null) 'specialization': specialization, if (status != null) 'status': status});
  }

  Future<ApiResponse> getDoctor(String id) async => _client.get('/doctors/$id');
  Future<ApiResponse> updateDoctor(String id, Map<String, dynamic> data) async => _client.put('/doctors/$id', body: data);
  Future<ApiResponse> verifyDoctor(String id) async => _client.post('/doctors/$id/verify');
  Future<ApiResponse> suspendDoctor(String id, {String? reason}) async => _client.post('/doctors/$id/suspend', body: {'reason': reason ?? ''});
  Future<ApiResponse> rejectDoctor(String id, {String? reason}) async => _client.post('/doctors/$id/reject', body: {'reason': reason ?? ''});
  Future<ApiResponse> verifyNMC(String nmcNumber) async => _client.get('/doctors/nmc/verify/$nmcNumber');
}
