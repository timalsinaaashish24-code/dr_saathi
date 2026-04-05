import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Dr. Saathi'**
  String get appTitle;

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// Welcome message for users
  ///
  /// In en, this message translates to:
  /// **'Welcome to Dr. Saathi'**
  String get welcome;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Settings tab label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Patient registration page title
  ///
  /// In en, this message translates to:
  /// **'Patient Registration'**
  String get patientRegistration;

  /// First name field label
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// Last name field label
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// Age field label
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Address field label
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Emergency contact field label
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// Medical history field label
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get medicalHistory;

  /// Allergies field label
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// Register button text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Offline mode indicator
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// Sync pending status
  ///
  /// In en, this message translates to:
  /// **'Sync Pending'**
  String get syncPending;

  /// Patient registration success message
  ///
  /// In en, this message translates to:
  /// **'Patient registered successfully!'**
  String get patientRegistered;

  /// Required field validation message
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// Invalid phone number validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get invalidPhoneNumber;

  /// Invalid age validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid age'**
  String get invalidAge;

  /// Patients count text
  ///
  /// In en, this message translates to:
  /// **'patients'**
  String get patients;

  /// Edit patient page title
  ///
  /// In en, this message translates to:
  /// **'Edit Patient'**
  String get editPatient;

  /// Patient update success message
  ///
  /// In en, this message translates to:
  /// **'Patient updated successfully!'**
  String get patientUpdated;

  /// Update button text
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// View menu item
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// Edit menu item
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete menu item
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Confirm delete dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// Search patients placeholder
  ///
  /// In en, this message translates to:
  /// **'Search Patients'**
  String get searchPatients;

  /// No search results message
  ///
  /// In en, this message translates to:
  /// **'No patients found'**
  String get noResults;

  /// No patients message
  ///
  /// In en, this message translates to:
  /// **'No patients registered yet'**
  String get noPatients;

  /// Personal information section title
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// Medical information section title
  ///
  /// In en, this message translates to:
  /// **'Medical Information'**
  String get medicalInformation;

  /// SMS reminder page title
  ///
  /// In en, this message translates to:
  /// **'SMS Reminder'**
  String get smsReminder;

  /// SMS reminders list page title
  ///
  /// In en, this message translates to:
  /// **'SMS Reminders'**
  String get smsReminders;

  /// Send SMS button text
  ///
  /// In en, this message translates to:
  /// **'Send SMS'**
  String get sendSms;

  /// Schedule SMS button text
  ///
  /// In en, this message translates to:
  /// **'Schedule SMS'**
  String get scheduleSms;

  /// Send immediately option
  ///
  /// In en, this message translates to:
  /// **'Send Immediately'**
  String get sendImmediately;

  /// Message template label
  ///
  /// In en, this message translates to:
  /// **'Message Template'**
  String get messageTemplate;

  /// Reminder type label
  ///
  /// In en, this message translates to:
  /// **'Reminder Type'**
  String get reminderType;

  /// Appointment reminder type
  ///
  /// In en, this message translates to:
  /// **'Appointment Reminder'**
  String get appointmentReminder;

  /// Medication reminder type
  ///
  /// In en, this message translates to:
  /// **'Medication Reminder'**
  String get medicationReminder;

  /// Follow-up reminder type
  ///
  /// In en, this message translates to:
  /// **'Follow-up Reminder'**
  String get followUpReminder;

  /// General reminder type
  ///
  /// In en, this message translates to:
  /// **'General Reminder'**
  String get generalReminder;

  /// Symptom checker button text
  ///
  /// In en, this message translates to:
  /// **'Symptom Checker'**
  String get symptomChecker;

  /// Find doctors button text
  ///
  /// In en, this message translates to:
  /// **'Find Doctors'**
  String get findDoctors;

  /// Emergency services button text
  ///
  /// In en, this message translates to:
  /// **'Emergency Services'**
  String get emergencyServices;

  /// Doctor portal button text
  ///
  /// In en, this message translates to:
  /// **'Doctor Portal'**
  String get doctorPortal;

  /// Register patient menu item
  ///
  /// In en, this message translates to:
  /// **'Register Patient'**
  String get registerPatient;

  /// Add new patient information subtitle
  ///
  /// In en, this message translates to:
  /// **'Add new patient information'**
  String get addNewPatientInformation;

  /// Language menu item
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Change app language subtitle
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get changeAppLanguage;

  /// Audio menu item
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// Sound and notification settings subtitle
  ///
  /// In en, this message translates to:
  /// **'Sound and notification settings'**
  String get soundAndNotificationSettings;

  /// Patient list menu item
  ///
  /// In en, this message translates to:
  /// **'Patient List'**
  String get patientList;

  /// View and manage patients subtitle
  ///
  /// In en, this message translates to:
  /// **'View and manage patients'**
  String get viewAndManagePatients;

  /// SMS reminders menu item
  ///
  /// In en, this message translates to:
  /// **'SMS Reminders'**
  String get smsRemindersMenu;

  /// Manage SMS reminders subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage SMS reminders'**
  String get manageSmsReminders;

  /// Prescriptions menu item
  ///
  /// In en, this message translates to:
  /// **'Prescriptions'**
  String get prescriptions;

  /// View prescriptions subtitle
  ///
  /// In en, this message translates to:
  /// **'View prescriptions'**
  String get viewPrescriptions;

  /// Data sync menu item
  ///
  /// In en, this message translates to:
  /// **'Data Sync'**
  String get dataSync;

  /// Sync with cloud subtitle
  ///
  /// In en, this message translates to:
  /// **'Sync with cloud'**
  String get syncWithCloud;

  /// About menu item
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// App information and version subtitle
  ///
  /// In en, this message translates to:
  /// **'App information and version'**
  String get appInformationAndVersion;

  /// Help menu item
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Get help and support subtitle
  ///
  /// In en, this message translates to:
  /// **'Get help and support'**
  String get getHelpAndSupport;

  /// Contact us menu item
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Reach out for support subtitle
  ///
  /// In en, this message translates to:
  /// **'Reach out for support'**
  String get reachOutForSupport;

  /// Choose from gallery option
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Take a photo option
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takeAPhoto;

  /// Remove photo option
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// Edit name dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get editName;

  /// Your name field label
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Select language dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Nepali language option
  ///
  /// In en, this message translates to:
  /// **'Nepali'**
  String get nepali;

  /// Manage your health profile text
  ///
  /// In en, this message translates to:
  /// **'Manage your health profile'**
  String get manageHealthProfile;

  /// View and manage prescriptions subtitle
  ///
  /// In en, this message translates to:
  /// **'View and manage prescriptions'**
  String get viewAndManagePrescriptions;

  /// Health records menu item
  ///
  /// In en, this message translates to:
  /// **'Health Records'**
  String get healthRecords;

  /// Access patient health records subtitle
  ///
  /// In en, this message translates to:
  /// **'Access patient health records'**
  String get accessPatientHealthRecords;

  /// Language choice menu item
  ///
  /// In en, this message translates to:
  /// **'Language Choice'**
  String get languageChoice;

  /// Notifications menu item
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Notification preferences subtitle
  ///
  /// In en, this message translates to:
  /// **'Notification preferences'**
  String get notificationPreferences;

  /// Resources menu item
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resources;

  /// Health resources and information subtitle
  ///
  /// In en, this message translates to:
  /// **'Health resources and information'**
  String get healthResourcesAndInformation;

  /// Privacy settings menu item
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get privacySettings;

  /// Control your privacy subtitle
  ///
  /// In en, this message translates to:
  /// **'Control your privacy'**
  String get controlYourPrivacy;

  /// Help and support menu item
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// Choose language dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// Emergency services screen title
  ///
  /// In en, this message translates to:
  /// **'Emergency Services'**
  String get emergencyServicesTitle;

  /// Emergency alert message
  ///
  /// In en, this message translates to:
  /// **'In case of life-threatening emergency, call 102 immediately'**
  String get emergencyAlert;

  /// Call 102 button text
  ///
  /// In en, this message translates to:
  /// **'Call 102'**
  String get call102;

  /// Call 100 button text
  ///
  /// In en, this message translates to:
  /// **'Call 100'**
  String get call100;

  /// All filter option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Ambulance filter option
  ///
  /// In en, this message translates to:
  /// **'Ambulance'**
  String get filterAmbulance;

  /// Police filter option
  ///
  /// In en, this message translates to:
  /// **'Police'**
  String get filterPolice;

  /// Fire service filter option
  ///
  /// In en, this message translates to:
  /// **'Fire Service'**
  String get filterFireService;

  /// Medical emergency filter option
  ///
  /// In en, this message translates to:
  /// **'Medical Emergency'**
  String get filterMedicalEmergency;

  /// Location loading message
  ///
  /// In en, this message translates to:
  /// **'Getting your location...'**
  String get gettingLocation;

  /// 24/7 availability indicator
  ///
  /// In en, this message translates to:
  /// **'24/7'**
  String get available247;

  /// Call button text
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callButton;

  /// WhatsApp button text
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsappButton;

  /// Alternate number button text
  ///
  /// In en, this message translates to:
  /// **'Alt'**
  String get alternateButton;

  /// Meters away distance format
  ///
  /// In en, this message translates to:
  /// **'m away'**
  String get metersAway;

  /// Kilometers away distance format
  ///
  /// In en, this message translates to:
  /// **'km away'**
  String get kilometersAway;

  /// Phone launch error message
  ///
  /// In en, this message translates to:
  /// **'Could not launch phone dialer'**
  String get couldNotLaunchPhone;

  /// WhatsApp launch error message
  ///
  /// In en, this message translates to:
  /// **'Could not launch WhatsApp'**
  String get couldNotLaunchWhatsApp;

  /// Default WhatsApp emergency message
  ///
  /// In en, this message translates to:
  /// **'Hello, I need emergency assistance.'**
  String get whatsappMessage;

  /// Pricing screen title
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get chooseYourPlan;

  /// Promotional offer header
  ///
  /// In en, this message translates to:
  /// **'Doctor Promotional Offer'**
  String get doctorPromotionalOffer;

  /// Special pricing subtitle
  ///
  /// In en, this message translates to:
  /// **'Special launch pricing for early adopters'**
  String get specialLaunchPricing;

  /// Limited time offer badge
  ///
  /// In en, this message translates to:
  /// **'Limited Time Offer'**
  String get limitedTimeOffer;

  /// Subscribe button text
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// Select plan button text
  ///
  /// In en, this message translates to:
  /// **'Select a Plan'**
  String get selectAPlan;

  /// Popular tier badge
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get popular;

  /// Per month pricing text
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get perMonth;

  /// Subscription confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Subscription'**
  String get confirmSubscription;

  /// Plan selection confirmation text
  ///
  /// In en, this message translates to:
  /// **'You have selected the {planName} plan:'**
  String youHaveSelected(String planName);

  /// Patient count display
  ///
  /// In en, this message translates to:
  /// **'• Up to {count} patients'**
  String upToPatients(int count);

  /// Pricing display format
  ///
  /// In en, this message translates to:
  /// **'• {currency} {price}/month'**
  String pricingFormat(String currency, String price);

  /// Promotional offer confirmation
  ///
  /// In en, this message translates to:
  /// **'This is a promotional offer. Do you want to proceed?'**
  String get promotionalOfferProceed;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Subscription activation success title
  ///
  /// In en, this message translates to:
  /// **'Subscription Activated!'**
  String get subscriptionActivated;

  /// Plan activation success message
  ///
  /// In en, this message translates to:
  /// **'Your {planName} plan has been activated successfully!'**
  String planActivatedSuccess(String planName);

  /// Patient management confirmation
  ///
  /// In en, this message translates to:
  /// **'You can now manage up to {count} patients.'**
  String canNowManagePatients(int count);

  /// Great button text
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get great;

  /// Subscription menu item
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// Special launch offer text
  ///
  /// In en, this message translates to:
  /// **'Special Launch Offer!'**
  String get specialLaunchOffer;

  /// Premium features promotion text
  ///
  /// In en, this message translates to:
  /// **'Get premium features at promotional rates'**
  String get getPremiumFeatures;

  /// View plans button text
  ///
  /// In en, this message translates to:
  /// **'View Plans'**
  String get viewPlans;

  /// Billing menu item
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get billing;

  /// Create invoice screen title
  ///
  /// In en, this message translates to:
  /// **'Create Invoice'**
  String get createInvoice;

  /// Patient invoices screen title
  ///
  /// In en, this message translates to:
  /// **'My Invoices'**
  String get myInvoices;

  /// Select patient label
  ///
  /// In en, this message translates to:
  /// **'Select Patient'**
  String get selectPatient;

  /// Billing items section title
  ///
  /// In en, this message translates to:
  /// **'Billing Items'**
  String get billingItems;

  /// Add item button text
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No billing items message
  ///
  /// In en, this message translates to:
  /// **'No billing items added yet'**
  String get noBillingItems;

  /// Tax settings section title
  ///
  /// In en, this message translates to:
  /// **'Tax Settings'**
  String get taxSettings;

  /// VAT rate field label
  ///
  /// In en, this message translates to:
  /// **'VAT Rate (%)'**
  String get vatRate;

  /// Additional tax field label
  ///
  /// In en, this message translates to:
  /// **'Additional Tax (%)'**
  String get additionalTax;

  /// Payment terms field label
  ///
  /// In en, this message translates to:
  /// **'Payment Terms (Days)'**
  String get paymentTerms;

  /// Notes section title
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Invoice summary section title
  ///
  /// In en, this message translates to:
  /// **'Invoice Summary'**
  String get invoiceSummary;

  /// Subtotal label
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// VAT label
  ///
  /// In en, this message translates to:
  /// **'VAT'**
  String get vat;

  /// Total amount label
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// Preview button text
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// Send invoice button text
  ///
  /// In en, this message translates to:
  /// **'Send Invoice'**
  String get sendInvoice;

  /// Add billing item dialog title
  ///
  /// In en, this message translates to:
  /// **'Add Billing Item'**
  String get addBillingItem;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Type field label
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// Quantity field label
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// Unit price field label
  ///
  /// In en, this message translates to:
  /// **'Unit Price (Rs)'**
  String get unitPrice;

  /// Category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Paid status
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// Overdue status
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// All filter option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Total label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Due date label
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// View details button text
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// Mark paid button text
  ///
  /// In en, this message translates to:
  /// **'Mark Paid'**
  String get markPaid;

  /// Mark as paid dialog title
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get markAsPaid;

  /// Payment method label
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// Payment reference field label
  ///
  /// In en, this message translates to:
  /// **'Payment Reference (Optional)'**
  String get paymentReference;

  /// No invoices message
  ///
  /// In en, this message translates to:
  /// **'No invoices found'**
  String get noInvoicesFound;

  /// Invoice number label
  ///
  /// In en, this message translates to:
  /// **'Invoice Number'**
  String get invoiceNumber;

  /// Doctor label
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// Date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Items label
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
