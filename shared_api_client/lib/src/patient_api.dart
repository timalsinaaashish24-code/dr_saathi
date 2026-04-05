import 'api_client.dart';

class PatientApi {
  final _client = ApiClient();

  Future<ApiResponse> listPatients({int page = 1, int limit = 20, String? search}) async {
    return _client.get('/patients', queryParams: {'page': '$page', 'limit': '$limit', if (search != null) 'search': search});
  }

  Future<ApiResponse> getPatient(String id) async => _client.get('/patients/$id');
  Future<ApiResponse> createPatient(Map<String, dynamic> data) async => _client.post('/patients', body: data);
  Future<ApiResponse> updatePatient(String id, Map<String, dynamic> data) async => _client.put('/patients/$id', body: data);
  Future<ApiResponse> deletePatient(String id) async => _client.delete('/patients/$id');
  Future<ApiResponse> getMedicalHistory(String id) async => _client.get('/patients/$id/medical-history');
}
