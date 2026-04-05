/// API configuration for Dr. Saathi backend
class ApiConfig {
  /// Base URL for the API server
  /// Development: http://localhost:3001
  /// Production: https://api.drsaathi.com
  static String baseUrl = 'http://localhost:3001';

  /// API version prefix
  static const String apiVersion = '/api/v1';

  /// Full API URL
  static String get apiUrl => '$baseUrl$apiVersion';

  /// Set to production
  static void useProduction() {
    baseUrl = 'https://api.drsaathi.com';
  }

  /// Set to development (localhost)
  static void useDevelopment({String? host, int port = 3001}) {
    baseUrl = 'http://${host ?? 'localhost'}:$port';
  }

  /// Set custom URL
  static void setBaseUrl(String url) {
    baseUrl = url;
  }
}
