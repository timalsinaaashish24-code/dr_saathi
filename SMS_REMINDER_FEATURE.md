# SMS Reminder Feature Documentation

## Overview

The SMS Reminder feature has been successfully integrated into the Dr. Saathi offline-first patient registration system. This feature allows healthcare professionals to send immediate SMS messages or schedule SMS reminders for patients.

## Key Features

### 1. **Immediate SMS Sending**
- Send SMS instantly to patients
- Uses device's SMS app or Twilio API
- Supports multiple reminder types (appointment, medication, follow-up, general)

### 2. **Scheduled SMS Reminders**
- Schedule SMS reminders for future dates and times
- Local notifications trigger SMS sending
- Automatic retry mechanism for failed messages

### 3. **Message Templates**
- Pre-defined message templates for common scenarios
- Dynamic placeholders for patient name, clinic name, appointment time, etc.
- Customizable templates for different reminder types

### 4. **Offline-First Architecture**
- All reminders stored locally in SQLite database
- Works without internet connection
- Sync reminders with server when online

### 5. **Comprehensive Management**
- View all scheduled reminders
- Filter by status (pending, sent, failed, overdue)
- Search reminders by patient name, phone, or message
- Cancel or retry failed reminders

## Technical Implementation

### Database Schema

#### SMS Reminders Table
```sql
CREATE TABLE sms_reminders(
  id TEXT PRIMARY KEY,
  patientId TEXT NOT NULL,
  patientName TEXT NOT NULL,
  phoneNumber TEXT NOT NULL,
  message TEXT NOT NULL,
  scheduledTime TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL,
  type TEXT NOT NULL,
  status TEXT NOT NULL,
  errorMessage TEXT,
  retryCount INTEGER DEFAULT 0,
  synced INTEGER DEFAULT 0,
  FOREIGN KEY (patientId) REFERENCES patients (id)
);
```

#### SMS Templates Table
```sql
CREATE TABLE sms_templates(
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  template TEXT NOT NULL,
  type TEXT NOT NULL,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL
);
```

### Core Components

#### 1. **SmsReminder Model** (`lib/models/sms_reminder.dart`)
- Represents SMS reminder data
- Includes reminder types and status enums
- Template class for message generation

#### 2. **SmsService** (`lib/services/sms_service.dart`)
- Handles SMS sending via device app or Twilio API
- Manages local notifications for scheduling
- Processes overdue reminders
- Creates default templates

#### 3. **Database Service Extensions** (`lib/services/database_service.dart`)
- CRUD operations for SMS reminders and templates
- Search and filter functionality
- Statistics and reporting

#### 4. **SMS Reminder Screen** (`lib/screens/sms_reminder_screen.dart`)
- Create new SMS reminders
- Select patients and message templates
- Schedule or send immediately
- Form validation and error handling

#### 5. **SMS Reminders List** (`lib/screens/sms_reminders_list.dart`)
- View all reminders with filtering
- Statistics dashboard
- Cancel/retry functionality
- Search and filter interface

## Usage Instructions

### Sending Immediate SMS

1. Navigate to a patient's details page
2. Click the SMS icon in the app bar
3. Enter or customize the message
4. Check "Send Immediately"
5. Tap "Send SMS"

### Scheduling SMS Reminder

1. From the home screen, tap "SMS Reminders"
2. Tap the "+" button to create a new reminder
3. Select patient and reminder type
4. Choose a message template (optional)
5. Set the scheduled date and time
6. Tap "Schedule SMS"

### Managing Reminders

1. View all reminders in the SMS Reminders list
2. Filter by status: All, Pending, Sent, Failed, Overdue
3. Search by patient name, phone, or message content
4. Tap on a reminder to view details
5. Use the menu to cancel or retry reminders

## Configuration

### Twilio Integration (Optional)

For automated SMS sending via API, configure Twilio credentials in `lib/services/sms_service.dart`:

```dart
static const String _twilioAccountSid = 'YOUR_TWILIO_ACCOUNT_SID';
static const String _twilioAuthToken = 'YOUR_TWILIO_AUTH_TOKEN';
static const String _twilioPhoneNumber = 'YOUR_TWILIO_PHONE_NUMBER';
```

### Permission Requirements

The app requires the following permissions:
- **SMS Permission**: For sending SMS via device
- **Notification Permission**: For scheduling reminders
- **Phone Permission**: For accessing SMS functionality

## Default Templates

The system includes three default templates:

### 1. Appointment Reminder
```
Dear {patientName}, this is a reminder for your appointment with {doctorName} at {clinicName} on {appointmentTime}. Please arrive 15 minutes early. Thank you.
```

### 2. Medication Reminder
```
Dear {patientName}, this is a reminder to take your prescribed medication. Please follow the dosage instructions provided by your doctor. {additionalInfo}
```

### 3. Follow-up Reminder
```
Dear {patientName}, it's time for your follow-up appointment with {doctorName} at {clinicName}. Please schedule your appointment at your earliest convenience.
```

## Template Placeholders

Available placeholders for message templates:
- `{patientName}` - Patient's full name
- `{clinicName}` - Clinic name
- `{appointmentTime}` - Formatted appointment date/time
- `{doctorName}` - Doctor's name
- `{additionalInfo}` - Additional information

## Integration Points

### Patient Details Screen
- Added SMS icon in app bar
- Quick access to send SMS reminders
- Integrated with existing patient management

### Main Navigation
- SMS Reminders accessible from home screen
- Quick access buttons in settings tab
- Integrated with existing navigation flow

### Offline-First Sync
- All reminders stored locally
- Sync queue for offline operations
- Automatic sync when online

## Error Handling

### SMS Sending Failures
- Automatic retry mechanism
- Error logging and display
- Fallback to device SMS app

### Permission Handling
- Graceful permission requests
- User-friendly error messages
- Fallback options when permissions denied

### Database Errors
- Comprehensive error handling
- Transaction rollback on failures
- User notification of errors

## Performance Considerations

### Database Optimization
- Indexed fields for fast queries
- Efficient pagination for large datasets
- Cleanup of old reminders

### Memory Management
- Proper disposal of controllers
- Efficient list rendering
- Background processing for notifications

### Network Efficiency
- Batch operations where possible
- Offline-first design
- Minimal API calls

## Security Considerations

### Data Protection
- Local database encryption (recommended)
- Secure API credentials storage
- Patient data privacy compliance

### SMS Security
- Message content validation
- Phone number verification
- Rate limiting for SMS sending

## Future Enhancements

### Planned Features
- [ ] Bulk SMS sending to multiple patients
- [ ] SMS templates management UI
- [ ] Advanced scheduling (recurring reminders)
- [ ] SMS delivery status tracking
- [ ] Integration with external SMS providers
- [ ] SMS analytics and reporting
- [ ] Multi-language SMS templates
- [ ] SMS conversation history
- [ ] WhatsApp integration
- [ ] Push notifications as fallback

### Technical Improvements
- [ ] Background SMS processing
- [ ] Advanced retry logic
- [ ] SMS template editor
- [ ] Reminder rule engine
- [ ] SMS queue optimization
- [ ] Real-time status updates
- [ ] SMS template sharing
- [ ] Advanced filtering options
- [ ] SMS scheduling automation
- [ ] Integration with calendar apps

## Testing Scenarios

### Manual Testing
1. **Send immediate SMS**
   - Verify SMS app opens with pre-filled message
   - Test with valid and invalid phone numbers
   - Check error handling

2. **Schedule SMS reminder**
   - Create reminder for future time
   - Verify notification appears at scheduled time
   - Check reminder status updates

3. **Template functionality**
   - Test placeholder replacement
   - Verify different template types
   - Check custom message editing

4. **Offline functionality**
   - Create reminders while offline
   - Verify local storage
   - Test sync when online

### Automated Testing
- Unit tests for SMS service
- Integration tests for database operations
- UI tests for reminder screens
- Performance tests for large datasets

## Support and Troubleshooting

### Common Issues
1. **SMS not sending**: Check permissions and network connectivity
2. **Notifications not appearing**: Verify notification permissions
3. **Templates not loading**: Check database initialization
4. **Sync failures**: Verify internet connection and API credentials

### Debug Information
- Enable debug logging in SMS service
- Check database tables for data integrity
- Verify notification channel setup
- Test API connectivity

### Performance Monitoring
- Track SMS sending success rates
- Monitor database performance
- Check memory usage patterns
- Analyze user interaction flows

---

## Conclusion

The SMS Reminder feature provides a comprehensive solution for patient communication within the Dr. Saathi application. It maintains the offline-first architecture while adding powerful communication capabilities that enhance patient care and appointment management.

The implementation follows Flutter best practices and integrates seamlessly with the existing patient management system, providing healthcare professionals with an efficient tool for patient communication and care coordination.
