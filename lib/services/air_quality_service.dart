import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service to fetch real-time air quality data for major cities in Nepal
class AirQualityService {
  // OpenWeatherMap API key (Free tier: 1,000 calls/day)
  // Sign up at: https://openweathermap.org/api/air-pollution
  static const String _apiKey = 'YOUR_API_KEY_HERE'; // Replace with actual key
  static const String _baseUrl = 'http://api.openweathermap.org/data/2.5/air_pollution';
  
  // Major cities of Nepal with their coordinates
  static final Map<String, Map<String, double>> _cityCoordinates = {
    'Kathmandu': {'lat': 27.7172, 'lon': 85.3240},
    'Pokhara': {'lat': 28.2096, 'lon': 83.9856},
    'Biratnagar': {'lat': 26.4525, 'lon': 87.2718},
    'Lalitpur': {'lat': 27.6766, 'lon': 85.3240},
    'Bharatpur': {'lat': 27.6782, 'lon': 84.4350},
    'Birgunj': {'lat': 27.0104, 'lon': 84.8804},
    'Dharan': {'lat': 26.8146, 'lon': 87.2839},
    'Hetauda': {'lat': 27.4287, 'lon': 85.0325},
  };
  
  // Cache for AQI data
  static Map<String, Map<String, dynamic>>? _cachedData;
  static DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 30);
  
  /// Fetch air quality data for all major cities
  Future<Map<String, Map<String, dynamic>>> fetchAirQuality() async {
    // Return cached data if still valid
    if (_cachedData != null && 
        _lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedData!;
    }
    
    // Check if API key is configured
    if (_apiKey == 'YOUR_API_KEY_HERE') {
      // Return mock data if API key not configured
      return _getMockData();
    }
    
    try {
      final Map<String, Map<String, dynamic>> aqiData = {};
      
      // Fetch data for each city
      for (var entry in _cityCoordinates.entries) {
        final city = entry.key;
        final coords = entry.value;
        
        try {
          final url = Uri.parse(
            '$_baseUrl?lat=${coords['lat']}&lon=${coords['lon']}&appid=$_apiKey'
          );
          
          final response = await http.get(url).timeout(const Duration(seconds: 10));
          
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final aqi = _calculateAQI(data);
            
            aqiData[city] = {
              'aqi': aqi,
              'status': _getAQIStatus(aqi),
              'timestamp': DateTime.now().toIso8601String(),
            };
          } else {
            // Use fallback data for this city
            aqiData[city] = _getFallbackCityData(city);
          }
        } catch (e) {
          print('Error fetching data for $city: $e');
          aqiData[city] = _getFallbackCityData(city);
        }
        
        // Small delay between requests to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
      // Cache the data
      _cachedData = aqiData;
      _lastFetchTime = DateTime.now();
      
      return aqiData;
    } catch (e) {
      print('Error fetching air quality data: $e');
      return _getMockData();
    }
  }
  
  /// Calculate AQI from OpenWeatherMap air pollution data
  int _calculateAQI(Map<String, dynamic> data) {
    try {
      // OpenWeatherMap provides AQI as index (1-5)
      // We need to convert it to US EPA standard (0-500)
      final components = data['list'][0]['components'];
      final pm25 = components['pm2_5'] ?? 0.0;
      final pm10 = components['pm10'] ?? 0.0;
      
      // Calculate AQI based on PM2.5 (primary pollutant in Nepal)
      return _calculatePM25AQI(pm25.toDouble());
    } catch (e) {
      print('Error calculating AQI: $e');
      return 100; // Default moderate value
    }
  }
  
  /// Calculate AQI from PM2.5 concentration (μg/m³)
  int _calculatePM25AQI(double pm25) {
    // US EPA AQI breakpoints for PM2.5
    if (pm25 <= 12.0) {
      return _interpolate(pm25, 0.0, 12.0, 0, 50);
    } else if (pm25 <= 35.4) {
      return _interpolate(pm25, 12.1, 35.4, 51, 100);
    } else if (pm25 <= 55.4) {
      return _interpolate(pm25, 35.5, 55.4, 101, 150);
    } else if (pm25 <= 150.4) {
      return _interpolate(pm25, 55.5, 150.4, 151, 200);
    } else if (pm25 <= 250.4) {
      return _interpolate(pm25, 150.5, 250.4, 201, 300);
    } else {
      return _interpolate(pm25, 250.5, 500.4, 301, 500);
    }
  }
  
  /// Linear interpolation for AQI calculation
  int _interpolate(double value, double cLow, double cHigh, int iLow, int iHigh) {
    return ((iHigh - iLow) / (cHigh - cLow) * (value - cLow) + iLow).round();
  }
  
  /// Get AQI status description
  String _getAQIStatus(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }
  
  /// Get AQI status in Nepali
  String _getAQIStatusNepali(int aqi) {
    if (aqi <= 50) return 'राम्रो';
    if (aqi <= 100) return 'मध्यम';
    if (aqi <= 150) return 'संवेदनशीलका लागि अस्वस्थ';
    if (aqi <= 200) return 'अस्वस्थ';
    if (aqi <= 300) return 'धेरै अस्वस्थ';
    return 'खतरनाक';
  }
  
  /// Get fallback data for a city (used when API fails)
  Map<String, dynamic> _getFallbackCityData(String city) {
    // Realistic fallback values based on Nepal's typical air quality
    final fallbackAQI = {
      'Kathmandu': 156,
      'Pokhara': 98,
      'Biratnagar': 142,
      'Lalitpur': 148,
      'Bharatpur': 76,
      'Birgunj': 178,
      'Dharan': 112,
      'Hetauda': 89,
    };
    
    final aqi = fallbackAQI[city] ?? 100;
    return {
      'aqi': aqi,
      'status': _getAQIStatus(aqi),
      'timestamp': DateTime.now().toIso8601String(),
      'cached': true,
    };
  }
  
  /// Get mock data (used when API key is not configured)
  Map<String, Map<String, dynamic>> _getMockData() {
    return {
      'Kathmandu': {'aqi': 156, 'status': 'Unhealthy'},
      'Pokhara': {'aqi': 98, 'status': 'Moderate'},
      'Biratnagar': {'aqi': 142, 'status': 'Unhealthy'},
      'Lalitpur': {'aqi': 148, 'status': 'Unhealthy'},
      'Bharatpur': {'aqi': 76, 'status': 'Moderate'},
      'Birgunj': {'aqi': 178, 'status': 'Unhealthy'},
      'Dharan': {'aqi': 112, 'status': 'Unhealthy for Sensitive'},
      'Hetauda': {'aqi': 89, 'status': 'Moderate'},
    };
  }
  
  /// Translate status to Nepali
  String translateStatusToNepali(String status) {
    switch (status) {
      case 'Good':
        return 'राम्रो';
      case 'Moderate':
        return 'मध्यम';
      case 'Unhealthy for Sensitive':
        return 'संवेदनशीलका लागि अस्वस्थ';
      case 'Unhealthy':
        return 'अस्वस्थ';
      case 'Very Unhealthy':
        return 'धेरै अस्वस्थ';
      case 'Hazardous':
        return 'खतरनाक';
      default:
        return status;
    }
  }
  
  /// Clear cache (useful for manual refresh)
  void clearCache() {
    _cachedData = null;
    _lastFetchTime = null;
  }
  
  /// Check if cached data is still valid
  bool isCacheValid() {
    return _cachedData != null && 
           _lastFetchTime != null && 
           DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }
  
  /// Get time until next refresh
  Duration? getTimeUntilRefresh() {
    if (_lastFetchTime == null) return null;
    
    final nextRefresh = _lastFetchTime!.add(_cacheDuration);
    final now = DateTime.now();
    
    if (now.isAfter(nextRefresh)) return Duration.zero;
    
    return nextRefresh.difference(now);
  }
}
