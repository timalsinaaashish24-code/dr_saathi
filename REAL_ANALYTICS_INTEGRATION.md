# Dr. Saathi - Real Analytics Data Integration Guide

This guide explains how to integrate real data sources for the analytics dashboard in the Dr. Saathi Admin app.

## Overview

The analytics system consists of three main data sources:
1. **Firebase Analytics** - Track active users, sessions, and user behavior
2. **Local Database** - Store user registrations, activities, and app installs
3. **App Store APIs** - Fetch download statistics from App Store Connect and Google Play Console

## Current Status

✅ **Completed:**
- Database tables for analytics (`user_activities`, `user_registrations`)
- Analytics tracking service (`analytics_tracking_service.dart`)
- Registration tracking service (`registration_tracking_service.dart`)
- Firebase Analytics dependencies added to pubspec.yaml
- Firebase initialization code added to main.dart

⏳ **Pending Configuration:**
- Firebase project setup (requires running `flutterfire configure`)
- App Store Connect API credentials
- Google Play Console API credentials

## Part 1: Firebase Analytics Setup

### Step 1: Install FlutterFire CLI

```bash
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# Add to PATH (add to ~/.zshrc or ~/.bash_profile)
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Reload shell
source ~/.zshrc  # or source ~/.bash_profile
```

### Step 2: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Name: **dr-saathi-nepal** (or your choice)
4. Enable Google Analytics: **Yes**
5. Create new Analytics account or use existing
6. Click "Create project"

### Step 3: Configure Firebase for Flutter

```bash
cd /Users/test/dr_saathi/dr_saathi

# Run configuration wizard
flutterfire configure

# Select the Firebase project you just created
# Select platforms: iOS, Android
```

This command will:
- Create `lib/firebase_options.dart`
- Download `GoogleService-Info.plist` for iOS
- Download `google-services.json` for Android
- Update platform-specific configuration files

### Step 4: Update Main App to Track Events

Add analytics tracking to key user actions:

#### In Doctor Login (lib/screens/doctor_login.dart):

```dart
import '../services/analytics_tracking_service.dart';
import '../services/registration_tracking_service.dart';

// After successful login
final analytics = AnalyticsTrackingService();
await analytics.trackUserLogin(userId, 'doctor');
await RegistrationTrackingService().updateLastActive(userId);
```

#### In Patient Login (lib/screens/patient_login.dart):

```dart
import '../services/analytics_tracking_service.dart';
import '../services/registration_tracking_service.dart';

// After successful login
final analytics = AnalyticsTrackingService();
await analytics.trackUserLogin(userId, 'patient');
await RegistrationTrackingService().updateLastActive(userId);
```

#### In Registration Screens:

```dart
import '../services/registration_tracking_service.dart';

// After successful registration
await RegistrationTrackingService().recordUserRegistration(
  userId: userId,
  userType: 'doctor', // or 'patient'
);
```

### Step 5: Test Firebase Analytics

```bash
# Run the app
flutter run

# Watch logs for confirmation
# Should see: "Firebase initialized successfully"
# Should see: "User registration recorded: ..."
```

### Step 6: View Data in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to: **Analytics → Dashboard**
4. Wait 24-48 hours for data aggregation
5. Use **DebugView** for real-time testing

## Part 2: Database Analytics Integration

The database is already set up with two key tables:

### user_registrations Table
Tracks user registrations and account status:
- userId, userType (doctor/patient)
- registrationDate, platform (iOS/Android)
- isActive, lastActiveAt
- appVersion, deviceInfo

### user_activities Table
Tracks all user actions:
- userId, activityType, activityData
- timestamp (for trend analysis)

### Available Queries

```dart
// Get total users
final total = await RegistrationTrackingService().getTotalUsers();

// Get active users
final active = await RegistrationTrackingService().getActiveUsers();

// Get users by type
final byType = await RegistrationTrackingService().getUsersByType();
// Returns: {'doctor': 150, 'patient': 2500}

// Get users by platform
final byPlatform = await RegistrationTrackingService().getUsersByPlatform();
// Returns: {'iOS': 1200, 'Android': 1450}

// Get today's active users
final today = await AnalyticsTrackingService().getTodayActiveUsers();

// Get analytics data for date range
final data = await AnalyticsTrackingService().getAnalyticsData(
  DateTime(2025, 1, 1),
  DateTime(2025, 2, 6),
);
```

## Part 3: App Store Connect API (iOS Downloads)

### Prerequisites
- Apple Developer Account (paid membership required)
- App published on App Store

### Step 1: Generate API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to: **Users and Access → Keys → App Store Connect API**
3. Click **Generate API Key** or create **Team Key**
4. Download the `.p8` key file (e.g., `AuthKey_ABC123XYZ.p8`)
5. Note down:
   - **Key ID** (e.g., ABC123XYZ)
   - **Issuer ID** (e.g., 12345678-1234-1234-1234-123456789abc)
   - **Vendor Number** (from App Store Connect → Settings → General)

### Step 2: Store Credentials Securely

Create a new file: `lib/config/app_store_credentials.dart`

```dart
class AppStoreCredentials {
  static const String keyId = 'YOUR_KEY_ID';  // e.g., ABC123XYZ
  static const String issuerId = 'YOUR_ISSUER_ID';  // UUID format
  static const String vendorNumber = 'YOUR_VENDOR_NUMBER';  // e.g., 12345678
  static const String privateKey = '''
-----BEGIN PRIVATE KEY-----
YOUR_PRIVATE_KEY_CONTENT_HERE
-----END PRIVATE KEY-----
''';
  
  static const String bundleId = 'com.drsaathi.app';  // Your iOS bundle ID
}
```

**⚠️ Security Warning:** 
- Add `app_store_credentials.dart` to `.gitignore`
- Never commit credentials to version control
- Use environment variables in production

### Step 3: Create App Store API Service

Create file: `lib/services/app_store_api_service.dart`

```dart
import 'package:dio/dio.dart';
import 'package:jose/jose.dart';
import '../config/app_store_credentials.dart';

class AppStoreApiService {
  static final AppStoreApiService _instance = AppStoreApiService._internal();
  factory AppStoreApiService() => _instance;
  AppStoreApiService._internal();

  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.appstoreconnect.apple.com/v1',
  ));

  // Generate JWT token for authentication
  Future<String> _generateJWT() async {
    final claims = JsonWebTokenClaims.fromJson({
      'iss': AppStoreCredentials.issuerId,
      'exp': DateTime.now().add(Duration(minutes: 15)).millisecondsSinceEpoch ~/ 1000,
      'aud': 'appstoreconnect-v1',
    });

    final builder = JsonWebSignatureBuilder()
      ..jsonContent = claims.toJson()
      ..addRecipient(
        JsonWebKey.fromPem(AppStoreCredentials.privateKey),
        algorithm: 'ES256',
      )
      ..setProtectedHeader('kid', AppStoreCredentials.keyId)
      ..setProtectedHeader('typ', 'JWT');

    final jws = builder.build();
    return jws.toCompactSerialization();
  }

  // Get app analytics data
  Future<Map<String, dynamic>> getAppDownloads() async {
    try {
      final token = await _generateJWT();
      
      final response = await dio.get(
        '/apps/${AppStoreCredentials.bundleId}/appStoreVersions',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      // Parse download data
      return {
        'downloads': response.data['data']['attributes']['downloads'] ?? 0,
        'totalDownloads': response.data['data']['attributes']['totalDownloads'] ?? 0,
      };
    } catch (e) {
      print('Error fetching App Store data: $e');
      return {'downloads': 0, 'totalDownloads': 0};
    }
  }

  // Get sales reports (more detailed download data)
  Future<int> getTotalDownloads() async {
    try {
      final token = await _generateJWT();
      
      // Use Sales and Trends API
      final response = await dio.get(
        '/salesReports',
        queryParameters: {
          'filter[frequency]': 'DAILY',
          'filter[reportSubType]': 'SUMMARY',
          'filter[reportType]': 'SALES',
          'filter[vendorNumber]': AppStoreCredentials.vendorNumber,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      // Parse and aggregate downloads
      int totalDownloads = 0;
      // Process response data...
      
      return totalDownloads;
    } catch (e) {
      print('Error fetching download reports: $e');
      return 0;
    }
  }
}
```

### Step 4: Add Required Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.4.0  # Already added
  jose: ^0.3.4  # For JWT generation
```

Run:
```bash
flutter pub get
```

## Part 4: Google Play Console API (Android Downloads)

### Prerequisites
- Google Play Developer Account
- App published on Google Play

### Step 1: Enable Google Play Developer API

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create new project or select existing
3. Navigate to: **APIs & Services → Library**
4. Search for **Google Play Android Developer API**
5. Click **Enable**

### Step 2: Create Service Account

1. Go to: **APIs & Services → Credentials**
2. Click **Create Credentials → Service Account**
3. Name: `dr-saathi-analytics`
4. Grant role: **Service Account User**
5. Click **Done**
6. Click on the created service account
7. Go to **Keys** tab
8. Click **Add Key → Create New Key**
9. Choose **JSON** format
10. Download the JSON file (e.g., `dr-saathi-analytics-xxxxx.json`)

### Step 3: Grant Access in Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Navigate to: **Users and Permissions**
3. Click **Invite New Users**
4. Enter the service account email (from JSON file)
5. Grant permissions:
   - **View app information and download bulk reports**
   - **View financial data, orders, and cancellation survey responses**
6. Click **Invite User**

### Step 4: Store Credentials

Create file: `lib/config/play_console_credentials.dart`

```dart
class PlayConsoleCredentials {
  static const String packageName = 'com.drsaathi.app';  // Your Android package name
  
  static const Map<String, dynamic> serviceAccountJson = {
    "type": "service_account",
    "project_id": "YOUR_PROJECT_ID",
    "private_key_id": "YOUR_PRIVATE_KEY_ID",
    "private_key": "-----BEGIN PRIVATE KEY-----\nYOUR_KEY\n-----END PRIVATE KEY-----\n",
    "client_email": "dr-saathi-analytics@PROJECT_ID.iam.gserviceaccount.com",
    "client_id": "YOUR_CLIENT_ID",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "YOUR_CERT_URL"
  };
}
```

**⚠️ Add to `.gitignore`!**

### Step 5: Create Play Console API Service

Create file: `lib/services/play_console_api_service.dart`

```dart
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/androidpublisher/v3.dart';
import '../config/play_console_credentials.dart';

class PlayConsoleApiService {
  static final PlayConsoleApiService _instance = PlayConsoleApiService._internal();
  factory PlayConsoleApiService() => _instance;
  PlayConsoleApiService._internal();

  late AndroidPublisherApi _api;
  bool _initialized = false;

  // Initialize the API
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final credentials = ServiceAccountCredentials.fromJson(
        PlayConsoleCredentials.serviceAccountJson,
      );

      final client = await clientViaServiceAccount(
        credentials,
        [AndroidPublisherApi.androidpublisherScope],
      );

      _api = AndroidPublisherApi(client);
      _initialized = true;
      print('Play Console API initialized');
    } catch (e) {
      print('Error initializing Play Console API: $e');
    }
  }

  // Get total installs
  Future<int> getTotalInstalls() async {
    if (!_initialized) await initialize();

    try {
      // Get statistics
      final stats = await _api.stats;
      // Note: Actual endpoint depends on your setup
      // This is a simplified example
      
      return 0; // Parse from actual API response
    } catch (e) {
      print('Error fetching installs: $e');
      return 0;
    }
  }

  // Get install statistics over time
  Future<List<Map<String, dynamic>>> getInstallTrend() async {
    if (!_initialized) await initialize();

    try {
      // Fetch statistics for last 30 days
      // Parse and return trend data
      
      return [];
    } catch (e) {
      print('Error fetching install trend: $e');
      return [];
    }
  }
}
```

### Step 6: Add Required Dependencies

```yaml
dependencies:
  googleapis: ^13.2.0
  googleapis_auth: ^1.6.0
```

Run:
```bash
flutter pub get
```

## Part 5: Update Admin Analytics Service

Update `dr_saathi_admin/lib/services/analytics_service.dart` to fetch real data:

```dart
import '../../dr_saathi/lib/services/registration_tracking_service.dart';
import '../../dr_saathi/lib/services/analytics_tracking_service.dart';
import '../../dr_saathi/lib/services/app_store_api_service.dart';
import '../../dr_saathi/lib/services/play_console_api_service.dart';

class AnalyticsService {
  // Fetch real analytics data
  Future<UserAnalytics> fetchRealAnalytics() async {
    // Get data from database
    final registrationService = RegistrationTrackingService();
    final analyticsService = AnalyticsTrackingService();
    
    final totalUsers = await registrationService.getTotalUsers();
    final activeUsers = await registrationService.getActiveUsers();
    final todayActive = await analyticsService.getTodayActiveUsers();
    
    // Get app store downloads
    final iosDownloads = await AppStoreApiService().getTotalDownloads();
    final androidDownloads = await PlayConsoleApiService().getTotalInstalls();
    final totalDownloads = iosDownloads + androidDownloads;
    
    // Get platform distribution
    final byPlatform = await registrationService.getUsersByPlatform();
    
    // Get user types
    final byType = await registrationService.getUsersByType();
    
    return UserAnalytics(
      totalUsers: totalUsers,
      activeUsers: activeUsers,
      downloads: totalDownloads,
      todayActive: todayActive,
      iosUsers: byPlatform['iOS'] ?? 0,
      androidUsers: byPlatform['Android'] ?? 0,
      doctors: byType['doctor'] ?? 0,
      patients: byType['patient'] ?? 0,
      growthRate: 5.2,  // Calculate from trend data
      activeRate: (activeUsers / totalUsers * 100).toDouble(),
    );
  }
}
```

## Part 6: Testing

### Test Firebase Analytics
```bash
# Run app
flutter run

# Check logs
# Should see Firebase events being logged

# View in Firebase Console
# Go to Analytics → DebugView (real-time)
# Go to Analytics → Events (24hr+ delay)
```

### Test Database Tracking
```dart
// In your app code
final tracking = RegistrationTrackingService();
await tracking.recordUserRegistration(
  userId: 'test_user_123',
  userType: 'patient',
);

// Check database
final total = await tracking.getTotalUsers();
print('Total users: $total');
```

### Test App Store API
```dart
final appStore = AppStoreApiService();
final downloads = await appStore.getTotalDownloads();
print('iOS downloads: $downloads');
```

### Test Play Console API
```dart
await PlayConsoleApiService().initialize();
final installs = await PlayConsoleApiService().getTotalInstalls();
print('Android installs: $installs');
```

## Part 7: Deployment Checklist

### Before Production:
- [ ] Run `flutterfire configure` for production Firebase project
- [ ] Set up App Store Connect API keys
- [ ] Set up Google Play Console service account
- [ ] Add all credentials files to `.gitignore`
- [ ] Use environment variables for secrets
- [ ] Test all API integrations
- [ ] Set up error monitoring (Sentry/Crashlytics)
- [ ] Configure analytics data retention policies
- [ ] Add privacy policy for data collection
- [ ] Implement user consent for analytics
- [ ] Test analytics dashboard in admin app

### Security Best Practices:
1. **Never commit credentials** to version control
2. **Use secure storage** for API keys (Flutter Secure Storage)
3. **Implement proper authentication** for admin app
4. **Use HTTPS** for all API calls
5. **Rotate API keys** regularly
6. **Limit API permissions** to minimum required
7. **Monitor API usage** to detect anomalies
8. **Implement rate limiting** on sensitive endpoints

## Troubleshooting

### Firebase Issues
- **Error: Firebase not initialized**
  - Solution: Run `flutterfire configure`
  - Check `firebase_options.dart` exists

- **No data in Firebase Console**
  - Wait 24-48 hours for aggregation
  - Use DebugView for real-time data
  - Check internet connection

### App Store API Issues
- **401 Unauthorized**
  - Check JWT generation
  - Verify Key ID and Issuer ID
  - Ensure .p8 key file is correct

- **403 Forbidden**
  - Check API key permissions
  - Verify bundle ID matches

### Play Console API Issues
- **Service account not authorized**
  - Verify email is invited in Play Console
  - Check permissions granted
  - Wait 10-15 minutes after granting access

- **Invalid credentials**
  - Re-download JSON key
  - Check all fields are correct
  - Verify project ID matches

## Support Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [Google Play Developer API](https://developers.google.com/android-publisher)
- [Flutter Analytics Guide](https://docs.flutter.dev/cookbook/plugins/firebase-analytics)

## Next Steps

After integration:
1. Monitor real-time data in Firebase DebugView
2. Set up custom dashboards in Firebase Console
3. Configure BigQuery export for advanced analytics
4. Set up automated reports
5. Implement A/B testing with Firebase Remote Config
6. Add crash reporting with Firebase Crashlytics
7. Set up performance monitoring
8. Create custom user segments for targeted analytics

---

**Note:** This guide assumes you have the necessary paid developer accounts for Apple App Store and Google Play Store. Free accounts have limited API access.
