# Dr. Saathi - Offline-First Patient Registration System

A Flutter application for patient registration with offline-first capabilities, designed for healthcare professionals who need to register patients even when internet connectivity is limited or unavailable.

## Features

### Core Features
- **Offline-First Patient Registration**: Register patients without internet connection
- **Automatic Synchronization**: Sync patient data when internet connection is restored
- **Comprehensive Patient Records**: Store detailed patient information including medical history and allergies
- **Multi-language Support**: English, Hindi, and Nepali localization
- **Search and Filter**: Find patients quickly using various search criteria
- **Real-time Sync Status**: Visual indicators for sync status and pending operations

### Technical Features
- **SQLite Local Database**: Robust local data storage using SQLite
- **Sync Queue Management**: Reliable queuing system for offline operations
- **Connectivity Detection**: Automatic network status monitoring
- **Data Validation**: Comprehensive form validation for patient data
- **Conflict Resolution**: Smart handling of data conflicts during sync

## Architecture

The application follows a clean architecture pattern with clear separation of concerns:

```
lib/
├── models/           # Data models
├── services/         # Business logic and data services
├── screens/          # UI screens
├── generated/        # Auto-generated localization files
└── l10n/            # Localization resources
```

### Key Components

1. **Patient Model** (`lib/models/patient.dart`)
   - Comprehensive patient data structure
   - Serialization/deserialization methods
   - Sync status tracking

2. **Database Service** (`lib/services/database_service.dart`)
   - SQLite database management
   - CRUD operations for patients
   - Sync queue management
   - Search functionality

3. **Sync Service** (`lib/services/sync_service.dart`)
   - Background synchronization
   - Connectivity monitoring
   - Conflict resolution
   - Automatic retry mechanisms

4. **UI Screens**
   - Patient Registration (`lib/screens/patient_registration.dart`)
   - Patient List (`lib/screens/patients_list.dart`)
   - Patient Details (`lib/screens/patient_details.dart`)

## Installation

### Prerequisites
- Flutter SDK (3.8.1 or later)
- Android Studio or VS Code with Flutter extension
- Android SDK for Android development
- Xcode for iOS development (macOS only)

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd dr_saathi
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate localization files**
   ```bash
   flutter gen-l10n
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## Usage

### Patient Registration

1. **Open the app** and navigate to the home screen
2. **Tap "Patient Registration"** to add a new patient
3. **Fill in patient details**:
   - Personal information (name, age, phone, address)
   - Emergency contact
   - Medical history
   - Known allergies
4. **Tap "Register"** to save the patient
5. **Offline indicator** will show if no internet connection is available

### Viewing Patients

1. **Navigate to "Patients"** from the home screen or bottom navigation
2. **Browse all registered patients** in the list
3. **Use the search bar** to find specific patients
4. **Tap on a patient** to view detailed information
5. **Use the menu** to edit or delete patient records

### Sync Management

1. **Sync status indicator** shows current connectivity and sync state
2. **Automatic sync** occurs every 5 minutes when online
3. **Manual sync** can be triggered by tapping the sync button
4. **Pending items** are displayed in the sync status indicator

## Configuration

### API Configuration

Update the base URL in `lib/services/sync_service.dart`:

```dart
static const String _baseUrl = 'https://your-api-endpoint.com';
```

### Authentication

Implement your authentication logic in the `_getAuthToken()` method:

```dart
Future<String> _getAuthToken() async {
  // Implement your authentication logic here
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token') ?? '';
}
```

### Database Schema

The application uses SQLite with the following main tables:

#### Patients Table
```sql
CREATE TABLE patients(
  id TEXT PRIMARY KEY,
  firstName TEXT NOT NULL,
  lastName TEXT NOT NULL,
  age INTEGER NOT NULL,
  phoneNumber TEXT NOT NULL,
  address TEXT,
  emergencyContact TEXT,
  medicalHistory TEXT,
  allergies TEXT,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL,
  synced INTEGER DEFAULT 0
);
```

#### Sync Queue Table
```sql
CREATE TABLE sync_queue(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  patientId TEXT NOT NULL,
  operation TEXT NOT NULL,
  data TEXT,
  createdAt TEXT NOT NULL,
  FOREIGN KEY (patientId) REFERENCES patients (id)
);
```

## Offline-First Strategy

### Data Flow

1. **User Action** → **Local Database** → **Sync Queue** (if offline)
2. **Connectivity Restored** → **Sync Service** → **Remote Server**
3. **Sync Success** → **Update Local Sync Status**

### Sync Operations

- **CREATE**: New patients are queued for upload
- **UPDATE**: Modified patients are queued for sync
- **DELETE**: Deletion requests are queued for server sync
- **CONFLICT RESOLUTION**: Server timestamp comparison for conflicts

### Offline Capabilities

- ✅ Register new patients
- ✅ Edit existing patients
- ✅ Delete patients
- ✅ Search and view patients
- ✅ Queue operations for later sync
- ✅ Visual offline indicators

## Localization

The app supports multiple languages:

- **English** (default)
- **Hindi**
- **Nepali**

### Adding New Languages

1. Create a new ARB file in `lib/l10n/`
2. Add translations for all keys
3. Update `supportedLocales` in `lib/main.dart`
4. Run `flutter gen-l10n`

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

### Manual Testing Scenarios

1. **Offline Registration**
   - Turn off internet connection
   - Register a new patient
   - Verify offline indicator appears
   - Restore connection and verify sync

2. **Sync Verification**
   - Create, update, and delete patients while offline
   - Verify sync queue populates correctly
   - Go online and verify all operations sync

3. **Conflict Resolution**
   - Modify same patient on multiple devices
   - Verify conflict resolution logic

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

### Copyright

Copyright (c) 2025 Dr. Saathi Development Team

### Healthcare Disclaimer

This software is designed for healthcare management purposes. Users are responsible for ensuring compliance with all applicable healthcare regulations, including but not limited to HIPAA, GDPR, and local privacy laws. The software should not be used as a substitute for professional medical advice, diagnosis, or treatment.

### Third-Party Licenses

This project uses several open-source packages. See the [NOTICES](build/ios/Debug-iphonesimulator/App.framework/flutter_assets/NOTICES.Z) file for complete license information of all dependencies.

## Support

For support and questions:
- **Email**: support@drsaathi.com
- **Issues**: Create an issue in the repository
- **Documentation**: See project wiki
- **Community**: Join our community forums

## Roadmap

- [ ] Image attachment support
- [ ] Barcode scanning for patient IDs
- [ ] Appointment scheduling
- [ ] Medical record templates
- [ ] Export functionality
- [ ] Advanced search filters
- [ ] Patient medical history timeline
- [ ] Integration with medical devices
- [ ] Multi-provider support
- [ ] Audit trail and logging

## Technical Specifications

- **Flutter Version**: 3.8.1+
- **Dart Version**: 3.0.0+
- **Minimum Android Version**: API 21 (Android 5.0)
- **Minimum iOS Version**: 12.0
- **Database**: SQLite
- **Architecture**: Clean Architecture with Repository Pattern
- **State Management**: Built-in Flutter state management
- **Networking**: HTTP package for API calls
- **Local Storage**: SQLite via sqflite package
- **Connectivity**: connectivity_plus package
- **Validation**: form_validator package
- **Localization**: Flutter internationalization

## Performance Considerations

- **Database Indexing**: Proper indexing on frequently queried fields
- **Lazy Loading**: Efficient data loading for large patient lists
- **Memory Management**: Proper disposal of controllers and resources
- **Background Sync**: Non-blocking sync operations
- **Error Handling**: Comprehensive error handling and recovery

## Security Considerations

- **Data Encryption**: Consider encrypting sensitive patient data
- **Authentication**: Implement proper authentication mechanisms
- **Authorization**: Role-based access control
- **HIPAA Compliance**: Ensure compliance with healthcare regulations
- **Secure Communication**: Use HTTPS for all API communications
- **Data Anonymization**: Consider anonymizing patient data for analytics

---

*Dr. Saathi - Enabling healthcare professionals to provide better patient care, even in challenging connectivity environments.*
