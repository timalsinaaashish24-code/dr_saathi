# Air Quality Index (AQI) Feature

## Overview

The Dr. Saathi app now includes a real-time Air Quality Index (AQI) scrolling bar on the main menu that displays air quality data for major cities in Nepal. This feature automatically updates every 30 minutes to provide users with current air quality information.

## Features

### 1. **Real-Time AQI Data**
- Displays AQI for 8 major cities in Nepal:
  - Kathmandu
  - Pokhara
  - Biratnagar
  - Lalitpur
  - Bharatpur
  - Birgunj
  - Dharan
  - Hetauda

### 2. **Color-Coded Status**
The AQI values are color-coded according to US EPA standards:
- **Green (0-50)**: Good
- **Yellow (51-100)**: Moderate
- **Orange (101-150)**: Unhealthy for Sensitive Groups
- **Red (151-200)**: Unhealthy
- **Purple (201-300)**: Very Unhealthy
- **Maroon (301-500)**: Hazardous

### 3. **Automatic Updates**
- Data refreshes automatically every **30 minutes**
- Cached data is stored for 30 minutes to reduce API calls
- Loading indicator shows when data is being fetched

### 4. **Manual Refresh**
- Tap the AQI bar to manually refresh the data
- A snackbar notification confirms the refresh action

### 5. **Bilingual Support**
- Displays in **English** or **Nepali** based on app language settings
- Status translations:
  - Good → राम्रो
  - Moderate → मध्यम
  - Unhealthy for Sensitive → संवेदनशीलका लागि अस्वस्थ
  - Unhealthy → अस्वस्थ
  - Very Unhealthy → धेरै अस्वस्थ
  - Hazardous → खतरनाक

### 6. **Horizontal Scrolling**
- Infinite scroll through all cities
- Smooth, interactive UI with shadow effects

## Technical Implementation

### API Configuration

The feature uses **OpenWeatherMap Air Pollution API** (free tier):

1. **Sign up for an API key**: https://openweathermap.org/api/air-pollution
2. **Update the API key** in `lib/services/air_quality_service.dart`:
   ```dart
   static const String _apiKey = 'YOUR_API_KEY_HERE';
   ```

### Data Sources

- **Primary**: OpenWeatherMap Air Pollution API
- **Fallback**: Realistic mock data based on typical air quality in Nepal
- **Cache Duration**: 30 minutes

### Service Architecture

#### `AirQualityService` Class
Location: `lib/services/air_quality_service.dart`

**Key Methods:**
- `fetchAirQuality()`: Fetches AQI data for all cities
- `translateStatusToNepali(String status)`: Translates status to Nepali
- `clearCache()`: Manually clears cached data
- `isCacheValid()`: Checks if cache is still valid
- `getTimeUntilRefresh()`: Returns time until next refresh

**Features:**
- Automatic caching (30 minutes)
- Graceful fallback on API failures
- Rate limiting protection (200ms delay between requests)
- 10-second timeout per city request
- Converts PM2.5 concentrations to US EPA AQI standard

### Integration in Main App

The AQI feature is integrated into `lib/main.dart`:

1. **Service Initialization**: Created in `_MyHomePageState`
2. **Automatic Updates**: Timer-based refresh every 30 minutes
3. **UI Component**: `_buildAirQualityBar()` widget
4. **Data Management**: `_loadAirQualityData()` method

## Data Flow

```
App Startup
    ↓
Initialize AirQualityService
    ↓
Fetch Initial AQI Data
    ↓
Display in Scrolling Bar
    ↓
Start Auto-Update Timer (30 min)
    ↓
Periodic Refresh
```

## API Details

### OpenWeatherMap Air Pollution API

**Endpoint**: `http://api.openweathermap.org/data/2.5/air_pollution`

**Parameters**:
- `lat`: Latitude of city
- `lon`: Longitude of city
- `appid`: Your API key

**Response**:
```json
{
  "list": [
    {
      "main": {
        "aqi": 2
      },
      "components": {
        "pm2_5": 8.32,
        "pm10": 14.5,
        "no2": 9.3,
        "o3": 52.8,
        "so2": 1.2
      }
    }
  ]
}
```

### AQI Calculation

The service converts PM2.5 concentrations (μg/m³) to AQI using US EPA breakpoints:

| PM2.5 (μg/m³) | AQI Range | Category |
|---------------|-----------|----------|
| 0.0 - 12.0 | 0 - 50 | Good |
| 12.1 - 35.4 | 51 - 100 | Moderate |
| 35.5 - 55.4 | 101 - 150 | Unhealthy for Sensitive |
| 55.5 - 150.4 | 151 - 200 | Unhealthy |
| 150.5 - 250.4 | 201 - 300 | Very Unhealthy |
| 250.5 - 500.4 | 301 - 500 | Hazardous |

## Usage Without API Key

If no API key is configured, the service will automatically use **realistic mock data** based on typical air quality patterns in Nepal. This allows the feature to work immediately without external dependencies.

To use mock data, simply leave the API key as:
```dart
static const String _apiKey = 'YOUR_API_KEY_HERE';
```

## Performance Considerations

### Optimization Features:
- **Caching**: Reduces API calls to once every 30 minutes
- **Rate Limiting**: 200ms delay between city requests
- **Timeout Protection**: 10-second timeout per request
- **Graceful Degradation**: Falls back to cached/mock data on failures
- **Efficient State Management**: Only updates UI when data changes

### API Limits (OpenWeatherMap Free Tier):
- **Calls per day**: 1,000
- **Calls per minute**: 60
- **With 8 cities**: ~200 calls per day with 30-minute refresh

## Troubleshooting

### Issue: No AQI data displayed
**Solution**: Check if API key is configured correctly in `air_quality_service.dart`

### Issue: Data not updating
**Solution**: 
1. Check internet connection
2. Verify API key validity
3. Check console logs for error messages

### Issue: "API rate limit exceeded" error
**Solution**: 
1. Increase cache duration in `air_quality_service.dart`
2. Reduce update frequency

## Future Enhancements

Potential improvements for the AQI feature:

1. **Weather Integration**: Add temperature, humidity, wind data
2. **Health Recommendations**: Provide health advice based on AQI levels
3. **Notifications**: Alert users when AQI reaches unhealthy levels
4. **Historical Data**: Show AQI trends over time
5. **Map View**: Display AQI on an interactive map
6. **More Cities**: Expand to additional cities
7. **Alternative APIs**: Support multiple AQI data providers

## Security & Privacy

- **No Personal Data**: AQI service does not collect or store user information
- **API Key Security**: Store API key securely (consider using environment variables in production)
- **HTTPS**: Use secure connections for API calls (production should use HTTPS endpoints)

## License

This feature is part of Dr. Saathi and follows the same MIT License as the main application.

## Support

For issues or questions about the AQI feature:
1. Check the console logs for error messages
2. Verify API key configuration
3. Ensure internet connectivity
4. Review the service implementation in `lib/services/air_quality_service.dart`

---

**Last Updated**: January 2025  
**Version**: 1.0.0
