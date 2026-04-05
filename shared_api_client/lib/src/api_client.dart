import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

/// API response wrapper
class ApiResponse {
  final int statusCode;
  final Map<String, dynamic> data;
  final bool success;
  final String? error;

  ApiResponse({required this.statusCode, required this.data, required this.success, this.error});

  factory ApiResponse.fromResponse(http.Response response) {
    final data = response.body.isNotEmpty ? jsonDecode(response.body) as Map<String, dynamic> : <String, dynamic>{};
    return ApiResponse(
      statusCode: response.statusCode,
      data: data,
      success: response.statusCode >= 200 && response.statusCode < 300,
      error: response.statusCode >= 400 ? (data['error']?.toString() ?? 'Unknown error') : null,
    );
  }
}

/// Base HTTP client with JWT auth, token refresh, and retry logic
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _token;
  String? _refreshToken;

  /// Get stored auth token
  Future<String?> get token async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('api_token');
    return _token;
  }

  /// Save auth tokens after login
  Future<void> saveTokens(String token, String refreshToken) async {
    _token = token;
    _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_token', token);
    await prefs.setString('api_refresh_token', refreshToken);
  }

  /// Clear tokens on logout
  Future<void> clearTokens() async {
    _token = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_token');
    await prefs.remove('api_refresh_token');
  }

  /// Build headers with auth token
  Future<Map<String, String>> _headers() async {
    final t = await token;
    return {
      'Content-Type': 'application/json',
      if (t != null) 'Authorization': 'Bearer $t',
    };
  }

  /// GET request
  Future<ApiResponse> get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('${ApiConfig.apiUrl}$path').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _headers());
    final result = ApiResponse.fromResponse(response);

    // Auto-refresh token on 401
    if (result.statusCode == 401 && _refreshToken != null) {
      final refreshed = await _refreshTokens();
      if (refreshed) return get(path, queryParams: queryParams);
    }
    return result;
  }

  /// POST request
  Future<ApiResponse> post(String path, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.apiUrl}$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    final result = ApiResponse.fromResponse(response);

    if (result.statusCode == 401 && _refreshToken != null) {
      final refreshed = await _refreshTokens();
      if (refreshed) return post(path, body: body);
    }
    return result;
  }

  /// PUT request
  Future<ApiResponse> put(String path, {Map<String, dynamic>? body}) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.apiUrl}$path'),
      headers: await _headers(),
      body: body != null ? jsonEncode(body) : null,
    );
    final result = ApiResponse.fromResponse(response);

    if (result.statusCode == 401 && _refreshToken != null) {
      final refreshed = await _refreshTokens();
      if (refreshed) return put(path, body: body);
    }
    return result;
  }

  /// DELETE request
  Future<ApiResponse> delete(String path) async {
    final response = await http.delete(Uri.parse('${ApiConfig.apiUrl}$path'), headers: await _headers());
    return ApiResponse.fromResponse(response);
  }

  /// Refresh expired token
  Future<bool> _refreshTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rt = _refreshToken ?? prefs.getString('api_refresh_token');
      if (rt == null) return false;

      final response = await http.post(
        Uri.parse('${ApiConfig.apiUrl}/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': rt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        await prefs.setString('api_token', _token!);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
