import 'api_client.dart';

class AuthApi {
  final _client = ApiClient();

  Future<ApiResponse> register({required String email, required String password, required String role, required String name, String? phone, String? licenseNumber, String? specialization}) async {
    final result = await _client.post('/auth/register', body: {
      'email': email, 'password': password, 'role': role, 'name': name,
      if (phone != null) 'phone': phone, if (licenseNumber != null) 'license_number': licenseNumber, if (specialization != null) 'specialization': specialization,
    });
    if (result.success) await _client.saveTokens(result.data['token'], result.data['refreshToken']);
    return result;
  }

  Future<ApiResponse> login({required String email, required String password}) async {
    final result = await _client.post('/auth/login', body: {'email': email, 'password': password});
    if (result.success) await _client.saveTokens(result.data['token'], result.data['refreshToken']);
    return result;
  }

  Future<void> logout() async => await _client.clearTokens();
}
