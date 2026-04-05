# Firebase Analytics Setup for Dr. Saathi

## Prerequisites
- Firebase account (create at https://console.firebase.google.com)
- Flutter CLI installed
- FlutterFire CLI installed

## Step 1: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

Add to PATH if needed:
```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

## Step 2: Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Enter project name: **dr-saathi** (or your preferred name)
4. Enable/Disable Google Analytics (recommended: Enable)
5. Click "Create project"

## Step 3: Configure Firebase for Flutter

Run the FlutterFire configuration command:

```bash
cd /Users/test/dr_saathi/dr_saathi
flutterfire configure
```

This will:
- Prompt you to select your Firebase project
- Automatically configure iOS and Android apps
- Generate `firebase_options.dart` file
- Update platform-specific configuration files

**Select platforms when prompted:**
- ✅ iOS
- ✅ Android
- ⬜ Web (optional, if you plan web deployment)
- ⬜ macOS (optional)

## Step 4: Enable Firebase Analytics in Console

1. Go to Firebase Console → Your Project
2. Click on "Analytics" in left sidebar
3. Analytics is automatically enabled for new projects
4. Wait a few minutes for initialization

## Step 5: Initialize Firebase in Your App

The code has already been prepared. You just need to update `main.dart`:

Add these imports at the top of `lib/main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/analytics_service.dart';
```

Update your `main()` function:
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Analytics Service
  AnalyticsService().initialize();
  
  // Rest of your initialization code...
  runApp(const MyApp());
}
```

## Step 6: Verify Installation

Run your app:
```bash
flutter run
```

Check Firebase Console:
1. Go to Firebase Console → Analytics → Dashboard
2. Wait 24-48 hours for initial data to appear
3. You should see active users, events, and demographics

## Step 7: View Analytics Data

### Firebase Console Dashboard
- **URL**: https://console.firebase.google.com
- **Path**: Your Project → Analytics → Dashboard

### Key Metrics You'll See:
1. **Users**: Active users (daily, weekly, monthly)
2. **Events**: All tracked events from the app
3. **Demographics**: Age, gender, location
4. **Technology**: Devices, OS versions, app versions
5. **Retention**: User retention cohorts
6. **Engagement**: Session duration, screens per session

### Real-time Data
- Go to: Analytics → DebugView
- See live events as users interact with app
- Useful for testing analytics implementation

## Tracked Events in Dr. Saathi

The following events are automatically tracked:

### User Actions:
- `symptom_checker_opened` - When user opens symptom checker
- `find_doctors` - When user searches for doctors
- `emergency_services_accessed` - Emergency services accessed
- `health_resource_viewed` - Health articles viewed
- `article_opened` - Specific article opened
- `appointment_booked` - Appointment scheduled
- `patient_registered` - New patient registration
- `doctor_login` - Doctor portal login
- `patient_login` - Patient portal login
- `language_changed` - Language preference changed
- `payment_initiated` - Payment started
- `payment_completed` - Payment successful
- `insurance_info_viewed` - Insurance information viewed
- `help_and_support_opened` - Help section accessed
- `air_quality_viewed` - Air quality data viewed
- `health_update_clicked` - Health update card clicked

### User Properties:
- `user_type` - patient or doctor
- `language` - nepali or english
- `user_id` - Unique user identifier

## Troubleshooting

### "Firebase not initialized" Error
- Ensure `Firebase.initializeApp()` is called before `runApp()`
- Check that `firebase_options.dart` exists

### No Data in Dashboard
- Wait 24-48 hours for initial data
- Use DebugView for real-time testing
- Verify app is connected to internet

### iOS Build Issues
- Ensure Xcode is up to date
- Run `pod install` in ios/ directory
- Check iOS minimum deployment target (11.0+)

### Android Build Issues
- Ensure `minSdkVersion` is at least 21
- Check `google-services.json` is in `android/app/`
- Sync Gradle files

## Advanced Configuration

### Custom Event Logging
Use the analytics service to log custom events:

```dart
final analytics = AnalyticsService();

// Log custom event
await analytics.logCustomEvent('feature_used', {
  'feature_name': 'prescription_scan',
  'success': true,
});
```

### Set User Properties
```dart
await analytics.setUserType('patient');
await analytics.setLanguage('nepali');
await analytics.setUserId('user_12345');
```

### Screen Tracking
```dart
await analytics.logScreenView(
  'HomeScreen',
  'MyHomePage',
);
```

## Privacy Considerations

### Data Collection
Firebase Analytics collects:
- Device information
- Usage patterns
- Crash reports (if enabled)
- Performance data (if enabled)

### Compliance
- Add privacy policy to your app
- Update Terms of Service
- Comply with GDPR/local privacy laws
- Allow users to opt-out if required

### Disable Analytics (if needed)
```dart
await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
```

## Export Data

### BigQuery Integration
1. Go to Project Settings → Integrations
2. Enable BigQuery
3. Analytics data automatically exported
4. Query with SQL for advanced analysis

### Data Export
- Raw data available in BigQuery
- Can export to Google Sheets
- API access available for custom integrations

## Support

- Firebase Documentation: https://firebase.google.com/docs
- Flutter Fire Documentation: https://firebase.flutter.dev
- Firebase Console: https://console.firebase.google.com

## Next Steps

After setup:
1. Monitor user engagement daily
2. Track feature adoption rates
3. Identify popular features
4. Optimize based on user behavior
5. Set up conversion tracking
6. Create custom audiences
7. Monitor retention rates

---

**Note**: Remember to keep your `google-services.json` and `GoogleService-Info.plist` files secure and never commit them to public repositories!
