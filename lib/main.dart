/*
 * Dr. Saathi - Offline-First Patient Registration System
 * 
 * Copyright (c) 2025 Dr. Saathi Development Team
 * 
 * This software is licensed under the MIT License.
 * See the LICENSE file in the root directory for full license text.
 * 
 * HEALTHCARE DISCLAIMER:
 * This software is designed for healthcare management purposes.
 * Users are responsible for ensuring compliance with all applicable
 * healthcare regulations. This software should not be used as a
 * substitute for professional medical advice, diagnosis, or treatment.
 */

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dr_saathi/generated/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/patient_registration.dart';
import 'screens/patients_list.dart';
import 'screens/sms_reminders_list.dart';
import 'screens/prescriptions_list.dart';
import 'screens/symptom_checker.dart';
import 'services/sms_service.dart';
import 'services/symptom_checker_service.dart';
import 'services/pharmacy_service.dart';
import 'services/language_service.dart';
import 'services/database_service.dart';
import 'services/air_quality_service.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:async';
import 'screens/doctor_login.dart';
import 'screens/doctor_dashboard.dart';
import 'screens/doctor_prescription_screen.dart';
import 'screens/payment_demo_screen.dart';
import 'screens/find_doctors_screen.dart';
import 'screens/emergency_services_screen.dart';
import 'screens/pricing_screen.dart';
import 'screens/patient_billing_screen.dart';
import 'screens/patient_invoice_view.dart';
import 'screens/patient_login.dart';
import 'screens/patient_dashboard.dart';
import 'screens/health_insurance_info.dart';
import 'screens/nipah_virus_alert_screen.dart';
import 'screens/payment_demo_home.dart';
import 'screens/nutritional_advice_screen.dart';
import 'sample_data_creator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (requires running 'flutterfire configure' first)
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    print('Run "flutterfire configure" to set up Firebase');
  }
  
  // Initialize web database factory if running on web
  if (kIsWeb) {
    // Web-specific initialization
    try {
      // Initialize the web database factory
      databaseFactory = databaseFactoryFfiWeb;
    } catch (e) {
      print('Warning: Web database initialization failed: $e');
    }
  }
  
  // Try to initialize services, but don't fail on web
  try {
    if (!kIsWeb) {
      // Initialize SMS service (only on non-web platforms)
      final smsService = SmsService();
      await smsService.initialize();
      await smsService.createDefaultTemplates();
    }
    
    // Initialize Symptom Checker service
    final symptomService = SymptomCheckerService();
    await symptomService.initialize();
    
    // Initialize Pharmacy service
    final pharmacyService = PharmacyService();
    await pharmacyService.initialize();
    
    // Initialize Database service and add sample patients for testing
    final databaseService = DatabaseService();
    await databaseService.addSamplePatients();
    print('Sample patients added to database for testing');
  } catch (e) {
    print('Warning: Service initialization failed: $e');
    // Continue with app startup even if services fail to initialize
  }
  
  runApp(const MyApp());
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _scaleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Scale animation - starts large and zooms out to normal size
    _scaleAnimation = Tween<double>(
      begin: 3.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));
    
    // Fade animation - fades out at the end
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInCubic,
    ));
    
    // Start the zoom-out animation immediately
    _scaleController.forward();
    
    // After 2.5 seconds, start fade out and navigate
    Future.delayed(const Duration(milliseconds: 2500), () {
      _fadeController.forward().then((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MyHomePage(title: 'Dr. Saathi'),
          ),
        );
      });
    });
  }
  
  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Dr. Saathi Logo
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[100],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.lightBlue.withOpacity(0.3),
                            spreadRadius: 10,
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/dr_saathi_icon.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Dr. Saathi',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue[800],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your Healthcare Companion',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.lightBlue[600],
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 50),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue[600]!),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en'); // Default to English

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final savedLocale = await LanguageService.getSavedLanguage();
    setState(() {
      _locale = savedLocale;
    });
  }

  void changeLanguage(String languageCode) async {
    final newLocale = Locale(languageCode);
    await LanguageService.saveLanguage(languageCode);
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dr. Saathi',
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ne'), // Nepali
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        primarySwatch: Colors.lightBlue,
      ),
      home: const SplashScreen(),
      routes: {
        '/doctor_login': (context) => const DoctorLoginScreen(),
        '/doctor_dashboard': (context) => const DoctorDashboardScreen(),
        '/doctor_prescription': (context) => const DoctorPrescriptionScreen(),
        '/patient_login': (context) => const PatientLoginScreen(),
        '/patient_dashboard': (context) => const PatientDashboardScreen(),
        '/pricing': (context) => const PricingScreen(),
        '/patient_billing': (context) => const PatientBillingScreen(),
        '/patient_invoices': (context) => const PatientInvoiceView(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _selectedIndex = 0;
  String? _profileImagePath;
  String _userName = 'Dr. Saathi User';
  final ImagePicker _picker = ImagePicker();
  final AirQualityService _airQualityService = AirQualityService();
  Map<String, Map<String, dynamic>>? _aqiData;
  bool _isLoadingAQI = false;
  Timer? _aqiUpdateTimer;
  Timer? _scrollTimer;
  final ScrollController _aqiScrollController = ScrollController();
  
  bool _isNepali(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ne';
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadAirQualityData();
    _startAQIAutoUpdate();
    _startAutoScroll();
  }
  
  @override
  void dispose() {
    _aqiUpdateTimer?.cancel();
    _scrollTimer?.cancel();
    _aqiScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image_path');
      _userName = prefs.getString('user_name') ?? 'Dr. Saathi User';
    });
  }
  
  // Load air quality data from service
  Future<void> _loadAirQualityData() async {
    if (_isLoadingAQI) return;
    
    setState(() {
      _isLoadingAQI = true;
    });
    
    try {
      final data = await _airQualityService.fetchAirQuality();
      setState(() {
        _aqiData = data;
        _isLoadingAQI = false;
      });
    } catch (e) {
      print('Error loading air quality data: $e');
      setState(() {
        _isLoadingAQI = false;
      });
    }
  }
  
  // Start automatic AQI updates every 30 minutes
  void _startAQIAutoUpdate() {
    _aqiUpdateTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _loadAirQualityData();
    });
  }
  
  // Start automatic scrolling for air quality bar
  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_aqiScrollController.hasClients) {
        final maxScroll = _aqiScrollController.position.maxScrollExtent;
        final currentScroll = _aqiScrollController.offset;
        
        // Smooth continuous scroll
        if (currentScroll >= maxScroll) {
          // Reset to beginning when reaching the end
          _aqiScrollController.jumpTo(0);
        } else {
          _aqiScrollController.animateTo(
            currentScroll + 1,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_profileImagePath != null) {
      await prefs.setString('profile_image_path', _profileImagePath!);
    }
    await prefs.setString('user_name', _userName);
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppLocalizations.of(context)!.chooseFromGallery),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _profileImagePath = image.path;
                    });
                    await _saveProfileData();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(AppLocalizations.of(context)!.takeAPhoto),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      _profileImagePath = image.path;
                    });
                    await _saveProfileData();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: Text(AppLocalizations.of(context)!.removePhoto),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() {
                    _profileImagePath = null;
                  });
                  await _saveProfileData();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editUserName() {
    TextEditingController nameController = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Your Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _userName = nameController.text;
                });
                await _saveProfileData();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  ImageProvider _getProfileImage() {
    if (_profileImagePath != null && !kIsWeb) {
      final file = File(_profileImagePath!);
      // Check if file exists before trying to load it
      if (file.existsSync()) {
        return FileImage(file);
      } else {
        // File doesn't exist, reset the path and use default image
        _profileImagePath = null;
        _saveProfileData(); // Save the reset state
        return const AssetImage('assets/images/profile_pic.png');
      }
    }
    return const AssetImage('assets/images/profile_pic.png');
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            // Dr. Saathi Logo at the top
            Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.lightBlue[100],
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.lightBlue.withOpacity(0.2),
                  spreadRadius: 3,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/dr_saathi_icon.png',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dr. Saathi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue[800],
            ),
          ),
          const SizedBox(height: 8),
          
          // Air Quality Scrolling Bar
          _buildAirQualityBar(),
          
          const SizedBox(height: 10),
          
          // Health Updates in Nepal
          _buildHealthUpdates(),
          
          const SizedBox(height: 8),
          
          // Grid of Service Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
            children: [
              // Symptom Checker Card
              _buildServiceCard(
                context: context,
                icon: Icons.health_and_safety,
                label: AppLocalizations.of(context)!.symptomChecker,
                color: const Color(0xFF26C6DA), // Bright turquoise
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SymptomCheckerScreen(),
                    ),
                  );
                },
              ),
              
              // Find Doctors Card
              _buildServiceCard(
                context: context,
                icon: Icons.local_hospital,
                label: AppLocalizations.of(context)!.findDoctors,
                color: const Color(0xFF66BB6A), // Fresh green
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FindDoctorsScreen(),
                    ),
                  );
                },
              ),
              
              // Emergency Services Card
              _buildServiceCard(
                context: context,
                icon: Icons.emergency,
                label: AppLocalizations.of(context)!.emergencyServices,
                color: const Color(0xFFEF5350), // Coral red
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmergencyServicesScreen(),
                    ),
                  );
                },
              ),
              
              // Health Insurance Info Card
              _buildServiceCard(
                context: context,
                icon: Icons.info_outline,
                label: _isNepali(context) ? 'स्वास्थ्य बीमा' : 'Health Insurance',
                color: const Color(0xFFAB47BC), // Warm purple
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HealthInsuranceInfoScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Development counter (can be removed in production)
          const Text('Development counter:'),
          Text(
            '$_counter',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
          ),
        ),
      ),
    );
  }

  // Air Quality Index data for major cities of Nepal
  Map<String, Map<String, dynamic>> _getAQIData() {
    // Use real-time data if available, otherwise use fallback
    if (_aqiData != null && _aqiData!.isNotEmpty) {
      final isNepali = _isNepali(context);
      // Translate status to Nepali if needed
      final translatedData = <String, Map<String, dynamic>>{};
      _aqiData!.forEach((city, data) {
        translatedData[city] = {
          'aqi': data['aqi'],
          'status': isNepali ? _airQualityService.translateStatusToNepali(data['status']) : data['status'],
        };
      });
      return translatedData;
    }
    
    // Fallback data if service hasn't loaded yet
    final isNepali = _isNepali(context);
    return {
      'Kathmandu': {'aqi': 156, 'status': isNepali ? 'अस्वस्थ' : 'Unhealthy'},
      'Pokhara': {'aqi': 98, 'status': isNepali ? 'मध्यम' : 'Moderate'},
      'Biratnagar': {'aqi': 142, 'status': isNepali ? 'अस्वस्थ' : 'Unhealthy'},
      'Lalitpur': {'aqi': 148, 'status': isNepali ? 'अस्वस्थ' : 'Unhealthy'},
      'Bharatpur': {'aqi': 76, 'status': isNepali ? 'मध्यम' : 'Moderate'},
      'Birgunj': {'aqi': 178, 'status': isNepali ? 'अस्वस्थ' : 'Unhealthy'},
      'Dharan': {'aqi': 112, 'status': isNepali ? 'अस्वस्थ संवेदनशील' : 'Unhealthy for Sensitive'},
      'Hetauda': {'aqi': 89, 'status': isNepali ? 'मध्यम' : 'Moderate'},
    };
  }
  
  Color _getAQIColor(int aqi) {
    if (aqi <= 50) return const Color(0xFF00E400); // Good - Green
    if (aqi <= 100) return const Color(0xFFFFFF00); // Moderate - Yellow
    if (aqi <= 150) return const Color(0xFFFF7E00); // Unhealthy for Sensitive - Orange
    if (aqi <= 200) return const Color(0xFFFF0000); // Unhealthy - Red
    if (aqi <= 300) return const Color(0xFF8F3F97); // Very Unhealthy - Purple
    return const Color(0xFF7E0023); // Hazardous - Maroon
  }
  
  Widget _buildHealthUpdates() {
    final isNepali = _isNepali(context);
    
    final healthUpdates = [
      {
        'title': isNepali ? 'पोषण सल्लाह' : 'Nutritional Advice',
        'description': isNepali 
            ? 'स्वस्थ जीवनको लागि सन्तुलित आहार अपनाउनुहोस्। पूर्ण मार्गदर्शन हेर्नुहोस्।'
            : 'Adopt a balanced diet for healthy living. View complete nutrition guidance.',
        'icon': Icons.restaurant_menu,
        'color': Colors.green,
      },
      {
        'title': isNepali ? 'निपाह भाइरस अलर्ट' : 'Nipah Virus Alert',
        'description': isNepali
            ? 'भारतमा प्रकोप। फल राम्रोसँग धोएर खानुहोस्। लक्षण भए तुरुन्त अस्पताल जानुहोस्।'
            : 'Outbreak in India. Wash fruits thoroughly. Seek immediate care if symptoms appear.',
        'icon': Icons.coronavirus,
        'color': Colors.red,
      },
      {
        'title': isNepali ? 'मानसिक स्वास्थ्य सेवा' : 'Mental Health Support',
        'description': isNepali
            ? 'मानसिक स्वास्थ्य महत्वपूर्ण छ। सहयोगको आवश्यकता भए १६६० मा फोन गर्नुहोस्।'
            : 'Mental health matters. Call 1660 for support if needed.',
        'icon': Icons.psychology,
        'color': Colors.purple,
      },
      {
        'title': isNepali ? 'कुपोषण विरुद्ध लड्नुहोस्' : 'Combat Malnutrition',
        'description': isNepali
            ? 'बालबालिकामा कुपोषण रोक्न सन्तुलित आहार र पोषण सेवा लिनुहोस्।'
            : 'Prevent child malnutrition with balanced diet and nutrition services.',
        'icon': Icons.restaurant,
        'color': Colors.green,
      },
    ];
    
    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: healthUpdates.length,
        itemBuilder: (context, index) {
          final update = healthUpdates[index];
          final isNipahAlert = (update['title'] as String).contains('Nipah') || 
                               (update['title'] as String).contains('निपाह');
          final isNutritionAdvice = (update['title'] as String).contains('Nutritional Advice') || 
                                   (update['title'] as String).contains('पोषण सल्लाह');
          
          return GestureDetector(
            onTap: isNipahAlert ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NipahVirusAlertScreen(),
                ),
              );
            } : isNutritionAdvice ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NutritionalAdviceScreen(),
                ),
              );
            } : null,
            child: Container(
              width: 300,
              margin: const EdgeInsets.only(right: 12, bottom: 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (update['color'] as Color).withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (update['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    update['icon'] as IconData,
                    color: update['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        update['title'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: Text(
                          update['description'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            height: 1.3,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildAirQualityBar() {
    final isNepali = _isNepali(context);
    final aqiData = _getAQIData();
    
    return GestureDetector(
      onTap: () {
        // Manual refresh on tap
        _loadAirQualityData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isNepali ? 'वायु गुणस्तर अद्यावधिक गर्दै...' : 'Refreshing air quality data...'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.cyan.shade50],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 10, right: 10),
            child: Row(
              children: [
                Text(
                  isNepali ? 'वायु गुणस्तर सूचकांक' : 'Air Quality Index',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const Spacer(),
                if (_isLoadingAQI)
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                    ),
                  )
                else
                  Icon(Icons.refresh, color: Colors.blue.shade700, size: 14),
                const SizedBox(width: 4),
                Text(
                  isNepali ? 'नेपालका मुख्य शहरहरू' : 'Major Cities',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              controller: _aqiScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: aqiData.length * 100, // Infinite scroll
              itemBuilder: (context, index) {
                final city = aqiData.keys.elementAt(index % aqiData.length);
                final data = aqiData[city]!;
                final aqi = data['aqi'] as int;
                final status = data['status'] as String;
                
                // Determine color based on AQI health level
                Color aqiColor;
                if (aqi <= 100) {
                  aqiColor = Colors.green; // Healthy
                } else if (aqi <= 150) {
                  aqiColor = Colors.orange; // Moderate
                } else {
                  aqiColor = Colors.red; // Unhealthy
                }
                
                return Container(
                  margin: const EdgeInsets.only(right: 10, bottom: 6, top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            city,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade600,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: aqiColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          aqi.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            
            // Settings Menu Items
            _buildSettingsMenuItem(
              icon: Icons.app_registration,
              title: AppLocalizations.of(context)!.registerPatient,
              subtitle: AppLocalizations.of(context)!.addNewPatientInformation,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PatientRegistration(),
                  ),
                );
              },
            ),
            
            _buildSettingsMenuItem(
              icon: Icons.language,
              title: AppLocalizations.of(context)!.language,
              subtitle: AppLocalizations.of(context)!.changeAppLanguage,
              onTap: () {
                _showLanguageDialog();
              },
            ),
            
            _buildSettingsMenuItem(
              icon: Icons.volume_up,
              title: AppLocalizations.of(context)!.audio,
              subtitle: AppLocalizations.of(context)!.soundAndNotificationSettings,
              onTap: () {
                _showAudioDialog();
              },
            ),
            
            _buildSettingsMenuItem(
              icon: Icons.library_books,
              title: AppLocalizations.of(context)!.resources,
              subtitle: AppLocalizations.of(context)!.healthResourcesAndInformation,
              onTap: () {
                _showResourcesDialog();
              },
            ),
            
            _buildSettingsMenuItem(
              icon: Icons.contact_support,
              title: AppLocalizations.of(context)!.contactUs,
              subtitle: AppLocalizations.of(context)!.getHelpAndSupport,
              onTap: () {
                _showContactUsDialog();
              },
            ),
            
            _buildSettingsMenuItem(
              icon: Icons.privacy_tip,
              title: AppLocalizations.of(context)!.privacySettings,
              subtitle: AppLocalizations.of(context)!.controlYourPrivacy,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy settings coming soon!')),
                );
              },
            ),
            
            _buildSettingsMenuItem(
              icon: Icons.help,
              title: AppLocalizations.of(context)!.helpAndSupport,
              subtitle: AppLocalizations.of(context)!.getHelpAndSupport,
              onTap: () {
                _showHelpAndSupportDialog();
              },
            ),

            const SizedBox(height: 24),

            // App Version
            Text(
              'Dr. Saathi v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.lightBlue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).primaryColor,
                        backgroundImage: _getProfileImage(),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.lightBlue[600],
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _editUserName,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _userName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.manageHealthProfile,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Profile Menu Items
            _buildProfileMenuItem(
              icon: Icons.medication,
              title: AppLocalizations.of(context)!.prescriptions,
              subtitle: AppLocalizations.of(context)!.viewAndManagePrescriptions,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrescriptionsListScreen(),
                  ),
                );
              },
            ),
            
            _buildProfileMenuItem(
              icon: Icons.folder_shared,
              title: AppLocalizations.of(context)!.healthRecords,
              subtitle: AppLocalizations.of(context)!.accessPatientHealthRecords,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PatientsList(),
                  ),
                );
              },
            ),
            
            _buildProfileMenuItem(
              icon: Icons.language,
              title: AppLocalizations.of(context)!.languageChoice,
              subtitle: AppLocalizations.of(context)!.changeAppLanguage,
              onTap: () {
                _showLanguageDialog();
              },
            ),
            
            
            _buildProfileMenuItem(
              icon: Icons.notifications,
              title: AppLocalizations.of(context)!.notifications,
              subtitle: AppLocalizations.of(context)!.notificationPreferences,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications settings coming soon!')),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // App Version
            Text(
              'Dr. Saathi v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.lightBlue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.lightBlue[600]),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSettingsMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.lightBlue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.lightBlue[600]),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showLanguageDialog() {
    final supportedLanguages = LanguageService.getSupportedLanguages();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.chooseLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: supportedLanguages.map((language) {
              return ListTile(
                leading: const Icon(Icons.language),
                title: Text('${language['nativeName']} (${language['name']})',),
                onTap: () {
                  Navigator.pop(context);
                  // Change the app language
                  MyApp.of(context).changeLanguage(language['code']!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Language changed to ${language['name']}')),
                  );
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ],
        );
      },
    );
  }

  void _showAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Account Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Manage your account and location settings'),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Location'),
                subtitle: const Text('Current: Auto-detect'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Location settings updated')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                subtitle: const Text('Update personal information'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile settings coming soon')),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAudioDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Audio Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Configure sound and notification settings'),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Sound Effects'),
                subtitle: const Text('Enable app sounds'),
                value: true,
                onChanged: (bool value) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sound effects ${value ? 'enabled' : 'disabled'}')),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Notification Sounds'),
                subtitle: const Text('Enable notification sounds'),
                value: true,
                onChanged: (bool value) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Notification sounds ${value ? 'enabled' : 'disabled'}')),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login successful!')),
                    );
                  },
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account created successfully!')),
                    );
                  },
                  child: const Text('Create Account'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showResourcesDialog() {
    final isNepali = _isNepali(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isNepali ? 'स्वास्थ्य स्रोतहरू' : 'Health Resources'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                _buildHealthResourceCard(
                  icon: Icons.favorite,
                  color: Colors.red,
                  title: isNepali ? 'मधुमेह' : 'Diabetes',
                  description: isNepali 
                      ? 'मधुमेह रक्तमा चिनीको मात्रा बढ्ने रोग हो। नियमित व्यायाम, सन्तुलित आहार, र नियमित जाँच आवश्यक छ। रगत चिनी 100-126 mg/dL (fasting) राख्नुहोस्।'
                      : 'Diabetes is a chronic condition affecting blood sugar levels. Maintain healthy diet, exercise regularly (150 min/week), monitor blood glucose, and take prescribed medications. Target fasting glucose: 100-126 mg/dL. Updated: Nov 2024',
                  onTap: () => _showArticlesList(context, 'diabetes', isNepali),
                ),
                _buildHealthResourceCard(
                  icon: Icons.monitor_heart,
                  color: Colors.purple,
                  title: isNepali ? 'उच्च रक्तचाप' : 'High Blood Pressure',
                  description: isNepali
                      ? 'उच्च रक्तचाप (140/90 mmHg भन्दा माथि) मुटु र मस्तिष्कमा असर पार्छ। नुन घटाउनुहोस्, तनाव व्यवस्थापन गर्नुहोस्, र नियमित जाँच गराउनुहोस्।'
                      : 'Hypertension (BP >140/90 mmHg) increases risk of heart disease and stroke. Reduce sodium intake (<2300mg/day), exercise regularly, manage stress, limit alcohol, and monitor BP weekly. Updated: Nov 2024',
                  onTap: () => _showArticlesList(context, 'hypertension', isNepali),
                ),
                _buildHealthResourceCard(
                  icon: Icons.scale,
                  color: Colors.orange,
                  title: isNepali ? 'मोटोपना' : 'Obesity',
                  description: isNepali
                      ? 'BMI 30 भन्दा बढी भए मोटोपना हो। सन्तुलित आहार, दिनको 30 मिनेट व्यायाम, पानी धेरै पिउनुहोस् र पर्याप्त निद्रा लिनुहोस् (7-9 घण्टा)।'
                      : 'Obesity (BMI >30) increases risk of diabetes, heart disease, and joint problems. Aim for balanced diet with calorie deficit, 30-60 min daily exercise, adequate sleep (7-9 hrs), and gradual weight loss (1-2 lbs/week). Updated: Nov 2024',
                  onTap: () => _showArticlesList(context, 'obesity', isNepali),
                ),
                _buildHealthResourceCard(
                  icon: Icons.medication,
                  color: Colors.green,
                  title: isNepali ? 'भिटामिन कमी' : 'Vitamin Deficiency',
                  description: isNepali
                      ? 'भिटामिन D, B12, आयरन कमी सामान्य छ। घाममा 15 मिनेट, फलफुल, हरियो सागपात, दाल, मासु, अण्डा, दुध खानुहोस्। आवश्यक भए सप्लिमेन्ट लिनुहोस्।'
                      : 'Common deficiencies: Vitamin D (sunlight 15min/day), B12 (meat, eggs, dairy), Iron (leafy greens, legumes), Calcium (dairy, fortified foods). Get regular blood tests and take supplements if prescribed. Updated: Nov 2024',
                  onTap: () => _showArticlesList(context, 'vitamin', isNepali),
                ),
                _buildHealthResourceCard(
                  icon: Icons.healing,
                  color: Colors.red.shade700,
                  title: isNepali ? 'मुटु रोग' : 'Heart Disease',
                  description: isNepali
                      ? 'मुटु रोग रोक्न: धुम्रपान छोड्नुहोस्, स्वस्थ बोसो खानुहोस्, नियमित व्यायाम गर्नुहोस्, रक्तचाप र कोलेस्ट्रोल नियन्त्रण गर्नुहोस्। छाती दुखाइ भए तुरुन्त जाँच गराउनुहोस्।'
                      : 'Prevent heart disease: Quit smoking, eat heart-healthy foods (omega-3, fiber, less saturated fat), exercise 150min/week, control BP and cholesterol (LDL <100mg/dL), manage stress. Seek immediate help for chest pain. Updated: Nov 2024',
                  onTap: () => _showArticlesList(context, 'heart', isNepali),
                ),
                _buildHealthResourceCard(
                  icon: Icons.self_improvement,
                  color: Colors.indigo,
                  title: isNepali ? 'मानसिक स्वास्थ्य' : 'Mental Health',
                  description: isNepali
                      ? 'मानसिक स्वास्थ्य महत्वपूर्ण छ। पर्याप्त निद्रा, ध्यान/योग, सामाजिक सम्पर्क, व्यायाम गर्नुहोस्। डिप्रेसन/चिन्ता भए सहयोग लिनुहोस्। नेपाल: 1660 मा फोन गर्नुहोस्।'
                      : 'Mental health is vital. Practice stress management, get adequate sleep, exercise regularly, maintain social connections, meditate. Seek professional help for depression/anxiety. Nepal Helpline: 1660. Updated: Nov 2024',
                  onTap: () => _showArticlesList(context, 'mental', isNepali),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isNepali ? 'बन्द गर्नुहोस्' : 'Close'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildHealthResourceCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showArticlesList(BuildContext context, String category, bool isNepali) {
    final articles = _getArticlesForCategory(category, isNepali);
    final categoryTitle = _getCategoryTitle(category, isNepali);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(categoryTitle),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.7,
            child: ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text('${index + 1}', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(
                      article['title']!,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article['abstract']!,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              article['source']!,
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isNepali ? 'बन्द गर्नुहोस्' : 'Close'),
            ),
          ],
        );
      },
    );
  }
  
  String _getCategoryTitle(String category, bool isNepali) {
    final titles = {
      'diabetes': isNepali ? 'मधुमेह लेखहरू' : 'Diabetes Articles',
      'hypertension': isNepali ? 'उच्च रक्तचाप लेखहरू' : 'Hypertension Articles',
      'obesity': isNepali ? 'मोटोपना लेखहरू' : 'Obesity Articles',
      'vitamin': isNepali ? 'भिटामिन कमी लेखहरू' : 'Vitamin Deficiency Articles',
      'heart': isNepali ? 'मुटु रोग लेखहरू' : 'Heart Disease Articles',
      'mental': isNepali ? 'मानसिक स्वास्थ्य लेखहरू' : 'Mental Health Articles',
    };
    return titles[category] ?? '';
  }
  
  List<Map<String, String>> _getArticlesForCategory(String category, bool isNepali) {
    switch (category) {
      case 'diabetes':
        return _getDiabetesArticles(isNepali);
      case 'hypertension':
        return _getHypertensionArticles(isNepali);
      case 'obesity':
        return _getObesityArticles(isNepali);
      case 'vitamin':
        return _getVitaminArticles(isNepali);
      case 'heart':
        return _getHeartArticles(isNepali);
      case 'mental':
        return _getMentalHealthArticles(isNepali);
      default:
        return [];
    }
  }
  
  List<Map<String, String>> _getDiabetesArticles(bool isNepali) {
    if (isNepali) {
      return [
        {'title': 'मधुमेह: कारण र लक्षणहरू', 'abstract': 'मधुमेह एक दीर्घकालीन रोग हो जसमा रगतमा चिनीको मात्रा बढ्छ। यसका मुख्य कारण: इन्सुलिन उत्पादनको कमी, शरीरले इन्सुलिन प्रयोग गर्न नसक्नु, र आनुवंशिक कारण हुन्। मुख्य लक्षण: धेरै तिर्खा लाग्नु, बारम्बार पिसाब लाग्नु, थकान, घाउ ढिलो निको हुनु, र दृष्टि धमिलो हुनु।', 'source': 'WHO Nepal, 2024'},
        {'title': 'मधुमेहको आहार व्यवस्थापन', 'abstract': 'मधुमेह भएका व्यक्तिले सन्तुलित आहार लिनुपर्छ। साधा चिनी र रिफाइन्ड कार्बोहाइड्रेट घटाउनुहोस्। धेरै फाइबर (साबुत अन्न, दाल, सागपात) खानुहोस्। खाना नियमित समयमा खानुहोस् र ठूलो भाग नखानुहोस्। प्रोटीन र स्वस्थ बोसो (माछा, नट्स) समावेश गर्नुहोस्।', 'source': 'Nepal Diabetes Association, 2024'},
        {'title': 'टाइप 1 र टाइप 2 मधुमेहको फरक', 'abstract': 'टाइप 1: शरीरले इन्सुलिन बनाउँदैन, सामान्यतया बाल्यकालमा सुरु हुन्छ, इन्सुलिन इंजेक्शन आवश्यक। टाइप 2: शरीरले इन्सुलिन राम्रोसँग प्रयोग गर्न सक्दैन, वयस्कहरूमा सामान्य, जीवनशैली परिवर्तन र औषधिले नियन्त्रण गर्न सकिन्छ।', 'source': 'Medical Journal Nepal, 2024'},
        {'title': 'मधुमेहको जटिलताहरू', 'abstract': 'नियन्त्रण नभएको मधुमेहले गम्भीर जटिलताहरू निम्त्याउँछ: मुटु रोग, मिर्गौला रोग, आँखाको क्षति (रेटिनोप्याथी), तंत्रिका क्षति (न्यूरोपैथी), पाउको समस्या, छालाको संक्रमण। नियमित जाँच र रगत चिनी नियन्त्रणले यी जटिलताहरू रोक्न सकिन्छ।', 'source': 'Tribhuvan University Teaching Hospital, 2024'},
        {'title': 'मधुमेहमा व्यायामको भूमिका', 'abstract': 'नियमित व्यायामले रगत चिनी नियन्त्रण गर्न मद्दत गर्छ। हप्तामा कम्तिमा 150 मिनेट मध्यम तीव्रताको व्यायाम (हिँड्ने, साइकल चलाउने) गर्नुहोस्। व्यायामले इन्सुलिन संवेदनशीलता बढाउँछ, तौल घटाउन मद्दत गर्छ, र मुटु स्वास्थ्य सुधार गर्छ।', 'source': 'Nepal Sports Medicine, 2024'},
        {'title': 'रगत चिनी परीक्षण र लक्ष्य', 'abstract': 'मधुमेह भएका व्यक्तिले नियमित रगत चिनी जाँच गर्नुपर्छ। खाली पेट: 80-130 mg/dL, खाना खाएको २ घण्टा पछि: <180 mg/dL, HbA1c: <7%। दैनिक जाँचले औषधि र आहार समायोजन गर्न मद्दत गर्छ।', 'source': 'Nepal Diabetes Foundation, 2024'},
        {'title': 'इन्सुलिन र औषधि व्यवस्थापन', 'abstract': 'टाइप 1 मधुमेहमा इन्सुलिन अनिवार्य छ। टाइप 2 मा मेटफर्मिन जस्ता मौखिक औषधि पहिले प्रयोग गरिन्छ। औषधि नियमित समयमा लिनुहोस्, डाक्टरको परामर्श बिना नछोड्नुहोस्, र साइड इफेक्ट भए तुरुन्त रिपोर्ट गर्नुहोस्।', 'source': 'Nepal Pharmaceutical Association, 2024'},
        {'title': 'गर्भावस्थामा मधुमेह', 'abstract': 'गर्भावधि मधुमेह (GDM) गर्भावस्थाको समयमा विकास हुन्छ। आमा र बच्चा दुवैको लागि जोखिमपूर्ण हुन सक्छ। नियमित जाँच, सन्तुलित आहार, र व्यायाम आवश्यक। सामान्यतया प्रसव पछि सामान्य हुन्छ तर भविष्यमा टाइप 2 मधुमेहको जोखिम बढ्छ।', 'source': 'Nepal Gynecology Society, 2024'},
        {'title': 'मधुमेह र मानसिक स्वास्थ्य', 'abstract': 'मधुमेह व्यवस्थापनले मानसिक तनाव ल्याउन सक्छ। चिन्ता, डिप्रेसन सामान्य छन्। सहयोग समूह, परामर्श, र परिवारको सहयोग महत्वपूर्ण। तनाव व्यवस्थापन (ध्यान, योग) र नियमित चिकित्सक भेट आवश्यक।', 'source': 'Nepal Mental Health Foundation, 2024'},
        {'title': 'मधुमेह रोकथाम रणनीति', 'abstract': 'मधुमेह रोक्न सकिन्छ: स्वस्थ तौल कायम राख्नुहोस्, नियमित व्यायाम गर्नुहोस्, स्वस्थ आहार खानुहोस्, धुम्रपान नगर्नुहोस्, तनाव कम गर्नुहोस्। उच्च जोखिम भएकाहरू (पारिवारिक इतिहास, मोटोपना) नियमित जाँच गराउनुहोस्।', 'source': 'Ministry of Health Nepal, 2024'},
      ];
    } else {
      return [
        {'title': 'Understanding Diabetes: Causes and Symptoms', 'abstract': 'Diabetes is a chronic metabolic disorder characterized by elevated blood glucose levels. Type 1 results from autoimmune destruction of insulin-producing beta cells, while Type 2 involves insulin resistance and relative insulin deficiency. Common symptoms include polyuria, polydipsia, unexplained weight loss, fatigue, blurred vision, and slow-healing wounds. Early detection through screening is crucial.', 'source': 'Diabetes Care Journal, Nov 2024'},
        {'title': 'Dietary Management in Diabetes', 'abstract': 'Medical nutrition therapy is fundamental in diabetes management. Emphasize whole grains, lean proteins, healthy fats, and non-starchy vegetables. Limit refined carbohydrates and added sugars. Carbohydrate counting and glycemic index awareness help control postprandial glucose. Consistent meal timing prevents glycemic variability. Mediterranean diet shows significant benefits.', 'source': 'American Diabetes Association, 2024'},
        {'title': 'Exercise and Physical Activity Guidelines', 'abstract': 'Regular physical activity improves insulin sensitivity and glycemic control. Recommend 150 minutes/week of moderate-intensity aerobic exercise plus resistance training 2-3 times/week. Exercise lowers HbA1c by 0.5-1%, reduces cardiovascular risk, aids weight management, and improves mental health. Monitor glucose before/after exercise to prevent hypoglycemia.', 'source': 'Journal of Clinical Endocrinology, 2024'},
        {'title': 'Complications of Diabetes: Prevention and Management', 'abstract': 'Chronic hyperglycemia causes microvascular (retinopathy, nephropathy, neuropathy) and macrovascular (coronary artery disease, stroke, peripheral artery disease) complications. Strict glycemic control (HbA1c <7%), blood pressure management, lipid control, and smoking cessation significantly reduce complication risk. Annual screening recommended.', 'source': 'New England Journal of Medicine, 2024'},
        {'title': 'Insulin Therapy: Modern Approaches', 'abstract': 'Insulin therapy essential for Type 1 and advanced Type 2 diabetes. Multiple formulations available: rapid-acting (lispro, aspart), short-acting (regular), intermediate-acting (NPH), and long-acting (glargine, detemir). Basal-bolus regimens mimic physiological secretion. Insulin pumps and continuous glucose monitors improve outcomes. Patient education crucial for safe use.', 'source': 'Lancet Diabetes & Endocrinology, 2024'},
        {'title': 'Oral Antidiabetic Medications: Current Evidence', 'abstract': 'Metformin remains first-line therapy for Type 2 diabetes due to efficacy, safety, and cardiovascular benefits. Second-line options include SGLT2 inhibitors (cardio-renal benefits), GLP-1 agonists (weight loss, CV protection), DPP-4 inhibitors, sulfonylureas, and thiazolidinediones. Individualize therapy based on comorbidities, contraindications, and patient preferences.', 'source': 'Diabetes Therapy Review, 2024'},
        {'title': 'Gestational Diabetes: Screening and Management', 'abstract': 'Gestational diabetes mellitus (GDM) affects 6-9% of pregnancies. Screen at 24-28 weeks using oral glucose tolerance test. Management includes diet modification, blood glucose monitoring, and insulin if targets not met. Increases risk of maternal complications, macrosomia, and future Type 2 diabetes. Postpartum screening essential.', 'source': 'Obstetrics & Gynecology, 2024'},
        {'title': 'Continuous Glucose Monitoring Technology', 'abstract': 'CGM systems provide real-time glucose data, trends, and alerts. Improves HbA1c by 0.5-1% compared to fingerstick testing. Flash glucose monitoring offers convenience without calibration. Benefits include hypoglycemia prevention, time-in-range optimization, and reduced diabetes distress. Cost-effectiveness improving with technology advances.', 'source': 'Diabetes Technology Journal, 2024'},
        {'title': 'Psychosocial Aspects of Diabetes Management', 'abstract': 'Diabetes distress, depression, and anxiety affect 20-40% of patients, impairing self-management and glycemic control. Screen regularly using validated tools. Interventions include cognitive behavioral therapy, motivational interviewing, peer support groups, and diabetes education. Address burnout and facilitate family involvement. Mental health integral to comprehensive care.', 'source': 'Psychosomatic Medicine, 2024'},
        {'title': 'Prevention Strategies for Type 2 Diabetes', 'abstract': 'Type 2 diabetes is largely preventable through lifestyle modification. Weight loss of 5-7% reduces incidence by 58%. Interventions include 150 min/week physical activity, dietary changes (reduced calories, saturated fat, increased fiber), smoking cessation, and adequate sleep. Metformin consideration for high-risk individuals. Population-level strategies necessary.', 'source': 'Preventive Medicine, 2024'},
      ];
    }
  }
  
  List<Map<String, String>> _getHypertensionArticles(bool isNepali) {
    return isNepali ? [] : [
      {'title': 'Hypertension: Epidemiology and Risk Factors', 'abstract': 'Hypertension affects 1.28 billion adults globally. Risk factors include age, family history, obesity, high sodium intake, physical inactivity, excessive alcohol, and stress. Essential (primary) hypertension comprises 90-95% of cases. Secondary causes include renal disease, endocrine disorders, and medications.', 'source': 'Hypertension Journal, 2024'},
      {'title': 'Blood Pressure Measurement Techniques', 'abstract': 'Accurate BP measurement crucial for diagnosis and management. Use validated devices, proper cuff size, patient seated with back supported, arm at heart level. Average 2-3 readings. Home BP monitoring and 24-hour ambulatory monitoring improve diagnostic accuracy and detect white-coat/masked hypertension.', 'source': 'American Heart Association, 2024'},
      {'title': 'DASH Diet for Blood Pressure Control', 'abstract': 'Dietary Approaches to Stop Hypertension (DASH) emphasizes fruits, vegetables, whole grains, lean proteins, low-fat dairy, and limited sodium. Reduces SBP by 8-14 mmHg. Sodium restriction (<2300mg, ideally <1500mg) provides additional 2-8 mmHg reduction. Potassium, magnesium, and calcium important.', 'source': 'Nutrition Reviews, 2024'},
      {'title': 'Antihypertensive Medications: First-line Agents', 'abstract': 'First-line medications include thiazide diuretics, ACE inhibitors, ARBs, and calcium channel blockers. Choice depends on age, ethnicity, comorbidities. Most patients require combination therapy. Target BP <130/80 mmHg for most adults. Beta-blockers reserved for specific indications. Individualize treatment.', 'source': 'Journal of Hypertension, 2024'},
      {'title': 'Exercise and Hypertension Management', 'abstract': 'Regular aerobic exercise reduces SBP/DBP by 5-8/3-4 mmHg. Recommend 150 min/week moderate-intensity or 75 min vigorous activity. Resistance training 2-3 days/week. Dynamic resistance reduces BP more than isometric. Exercise effective for prevention and treatment across all populations.', 'source': 'Sports Medicine, 2024'},
      {'title': 'Hypertensive Emergency vs Urgency', 'abstract': 'Hypertensive emergency: severe BP elevation (>180/120) with acute organ damage (encephalopathy, stroke, MI, pulmonary edema, aortic dissection). Requires immediate IV therapy and ICU admission. Hypertensive urgency: severe BP without organ damage, managed with oral medications. Gradual BP reduction preferred to prevent ischemia.', 'source': 'Emergency Medicine, 2024'},
      {'title': 'Resistant Hypertension: Evaluation and Management', 'abstract': 'Resistant hypertension: BP uncontrolled despite 3 antihypertensives (including diuretic) at optimal doses. Evaluate medication adherence, white-coat effect, secondary causes. Consider spironolactone, additional diuretics, or referral to hypertension specialist. Renal denervation emerging option for select patients.', 'source': 'Clinical Hypertension, 2024'},
      {'title': 'Hypertension in Pregnancy', 'abstract': 'Gestational hypertension, preeclampsia, and chronic hypertension complicate 10% of pregnancies. Diagnosis: BP ≥140/90 after 20 weeks. Preeclampsia adds proteinuria or organ dysfunction. Management: close monitoring, antihypertensives (labetalol, nifedipine, methyldopa), delivery timing. Magnesium sulfate prevents eclampsia.', 'source': 'Obstetric Medicine, 2024'},
      {'title': 'Renovascular Hypertension', 'abstract': 'Renal artery stenosis causes secondary hypertension. Suspect in sudden-onset severe hypertension, age <30 or >50, resistant hypertension, or unexplained renal dysfunction. Diagnose with renal artery Doppler, CTA, or MRA. Treatment: medical therapy, angioplasty/stenting for select cases. Atherosclerosis most common cause.', 'source': 'Kidney International, 2024'},
      {'title': 'Stress Management and Hypertension', 'abstract': 'Chronic stress contributes to hypertension through neuroendocrine pathways. Interventions include mindfulness-based stress reduction, meditation, yoga, deep breathing, biofeedback. Meta-analyses show 4-5 mmHg reductions. Stress management complements pharmacotherapy. Address depression, anxiety. Work-life balance important.', 'source': 'Psychosomatic Medicine, 2024'},
    ];
  }
  
  List<Map<String, String>> _getObesityArticles(bool isNepali) {
    return isNepali ? [] : [
      {'title': 'Obesity: Definition and Classification', 'abstract': 'Obesity defined as BMI ≥30 kg/m². Class I: 30-34.9, Class II: 35-39.9, Class III: ≥40. Waist circumference important: >102cm men, >88cm women indicates central obesity. Prevalence increased dramatically; 650 million adults obese worldwide. Major public health challenge.', 'source': 'Obesity Reviews, 2024'},
      {'title': 'Pathophysiology of Obesity', 'abstract': 'Obesity results from complex interactions: genetic predisposition (40-70% heritability), environmental factors, behavior, metabolism. Dysregulation of appetite-regulating hormones (leptin, ghrelin), insulin resistance, inflammation, gut microbiome alterations. Energy imbalance: intake exceeds expenditure.', 'source': 'Nature Metabolism, 2024'},
      {'title': 'Obesity-Related Comorbidities', 'abstract': 'Obesity increases risk of Type 2 diabetes, cardiovascular disease, hypertension, dyslipidemia, sleep apnea, NAFLD, osteoarthritis, certain cancers, depression. Each 5-unit BMI increase: 30% mortality increase. Weight loss of 5-10% significantly improves cardiometabolic health.', 'source': 'Lancet, 2024'},
      {'title': 'Behavioral Weight Loss Interventions', 'abstract': 'Evidence-based programs include calorie restriction (500-750 kcal/day deficit), increased physical activity, behavioral strategies (self-monitoring, goal-setting, stimulus control). Intensive interventions (≥14 sessions in 6 months) achieve 5-10% weight loss. Long-term adherence challenging; maintenance strategies crucial.', 'source': 'Obesity Science & Practice, 2024'},
      {'title': 'Pharmacotherapy for Obesity', 'abstract': 'FDA-approved medications: orlistat (lipase inhibitor), phentermine-topiramate, naltrexone-bupropion, liraglutide, semaglutide. Semaglutide (GLP-1 agonist) shows 15-20% weight loss. Reserved for BMI ≥30 or ≥27 with comorbidities. Combine with lifestyle modification. Long-term use often needed.', 'source': 'Drugs Journal, 2024'},
      {'title': 'Bariatric Surgery: Indications and Outcomes', 'abstract': 'Indicated for BMI ≥40 or ≥35 with comorbidities. Procedures: Roux-en-Y gastric bypass, sleeve gastrectomy, adjustable gastric banding. Achieves 20-35% total weight loss, resolves/improves diabetes, hypertension, sleep apnea. Requires lifelong follow-up, nutritional supplementation. Most effective long-term treatment.', 'source': 'Surgery for Obesity, 2024'},
      {'title': 'Childhood Obesity: Prevention and Management', 'abstract': 'Childhood obesity tripled since 1970s; 340 million affected. Causes: poor diet, sedentary behavior, genetic factors. Consequences: early onset comorbidities, psychosocial issues, adult obesity. Prevention: family-based interventions, school programs, limit screen time, promote physical activity, healthy eating patterns.', 'source': 'Pediatric Obesity, 2024'},
      {'title': 'Role of Physical Activity in Weight Management', 'abstract': 'Exercise alone produces modest weight loss (1-3 kg) but essential for maintenance. Recommend 150-300 min/week moderate-intensity activity for prevention; 200-300+ min for maintenance. Combines aerobic and resistance training. Increases lean mass, improves metabolic health, mental wellbeing.', 'source': 'Exercise & Sport Sciences, 2024'},
      {'title': 'Nutritional Strategies for Obesity', 'abstract': 'Various dietary approaches effective: calorie restriction, low-carbohydrate, Mediterranean, intermittent fasting. Focus on whole foods, portion control, reduced processed foods, adequate protein, fiber. No single "best" diet; adherence most important. Avoid very low-calorie diets (<800 kcal) without supervision.', 'source': 'American Journal of Clinical Nutrition, 2024'},
      {'title': 'Psychological Aspects of Obesity', 'abstract': 'Obesity associated with depression, anxiety, eating disorders, body image disturbances, stigma. Binge eating disorder in 20-30%. Interventions: cognitive behavioral therapy, motivational interviewing, mindful eating. Address emotional eating, stress. Weight-neutral approaches (Health at Every Size) alternative for some.', 'source': 'Psychology of Obesity, 2024'},
    ];
  }
  
  List<Map<String, String>> _getVitaminArticles(bool isNepali) {
    return isNepali ? [] : [
      {'title': 'Vitamin D Deficiency: Global Pandemic', 'abstract': '1 billion people worldwide have vitamin D deficiency. Causes: inadequate sun exposure, dark skin, malabsorption, obesity. Consequences: osteoporosis, fractures, muscle weakness, increased infection risk. Recommendation: 600-800 IU daily, higher for deficiency. Screening in high-risk populations.', 'source': 'Endocrine Reviews, 2024'},
      {'title': 'Vitamin B12 Deficiency: Diagnosis and Management', 'abstract': 'Common in elderly, vegetarians/vegans, malabsorption disorders. Causes: pernicious anemia, gastrectomy, metformin, PPIs. Manifestations: megaloblastic anemia, neuropathy, cognitive impairment. Diagnosis: serum B12, methylmalonic acid, homocysteine. Treatment: oral supplementation (1000-2000 mcg) or IM injections.', 'source': 'Blood Reviews, 2024'},
      {'title': 'Iron Deficiency Anemia: Worldwide Problem', 'abstract': 'Most common nutritional deficiency affecting 1.6 billion people. Risk factors: menstruation, pregnancy, vegetarian diet, GI blood loss, malabsorption. Symptoms: fatigue, weakness, pale skin, shortness of breath, cold intolerance. Treatment: oral ferrous sulfate 325mg daily, IV iron for severe cases or intolerance.', 'source': 'Hematology Journal, 2024'},
      {'title': 'Folate Deficiency: Causes and Consequences', 'abstract': 'Folate essential for DNA synthesis, cell division. Deficiency causes megaloblastic anemia, neural tube defects in pregnancy. Sources: leafy greens, legumes, fortified grains. Recommendation: 400 mcg daily, 600 mcg pregnancy. Folate fortification programs reduced neural tube defects by 35-50%.', 'source': 'Nutrition & Metabolism, 2024'},
      {'title': 'Vitamin K: Deficiency and Supplementation', 'abstract': 'Vitamin K essential for blood clotting, bone metabolism. Deficiency rare in adults but occurs in newborns, malabsorption, antibiotic use. Manifestations: bleeding, bruising. Sources: leafy greens (K1), fermented foods (K2). Prophylactic vitamin K given to newborns prevents hemorrhagic disease.', 'source': 'Thrombosis Research, 2024'},
      {'title': 'Vitamin A Deficiency: Leading Cause of Blindness', 'abstract': '250 million preschool children affected. Causes: inadequate dietary intake, malabsorption. Consequences: night blindness, xerophthalmia, increased mortality from infections. WHO recommends high-dose supplementation in endemic areas. Food fortification and dietary diversification key prevention strategies.', 'source': 'WHO Bulletin, 2024'},
      {'title': 'Thiamine (Vitamin B1) Deficiency', 'abstract': 'Common in alcoholism, malnutrition, heart failure on diuretics. Causes beriberi (peripheral neuropathy, heart failure) and Wernicke-Korsakoff syndrome (confusion, ataxia, memory loss). Emergency treatment: IV thiamine 100-500mg before glucose in at-risk patients. Oral maintenance 50-100mg daily.', 'source': 'Clinical Nutrition, 2024'},
      {'title': 'Vitamin E: Functions and Deficiency', 'abstract': 'Fat-soluble antioxidant protecting cell membranes. Deficiency rare, occurs in malabsorption (cystic fibrosis, cholestasis), genetic disorders. Manifestations: neuropathy, ataxia, retinopathy, immune dysfunction. Sources: nuts, seeds, vegetable oils. RDA: 15mg (22.4 IU). Supplementation controversial for disease prevention.', 'source': 'Free Radical Biology, 2024'},
      {'title': 'Vitamin C: Beyond Scurvy Prevention', 'abstract': 'Essential for collagen synthesis, antioxidant function, immune support. Deficiency causes scurvy: bleeding gums, poor wound healing, petechiae. RDA: 75-90mg; higher for smokers. Sources: citrus, berries, peppers, broccoli. Megadose supplementation (>1000mg) not recommended except specific conditions.', 'source': 'Nutrients Journal, 2024'},
      {'title': 'Multivitamin Supplementation: Evidence and Recommendations', 'abstract': 'General population: insufficient evidence for routine supplementation if adequate diet. Benefits in specific groups: pregnancy (prenatal vitamins), elderly, malabsorption, restrictive diets. Avoid megadoses; toxicity possible with fat-soluble vitamins. Food first approach preferred. Address underlying causes of deficiency.', 'source': 'Annals of Internal Medicine, 2024'},
    ];
  }
  
  List<Map<String, String>> _getHeartArticles(bool isNepali) {
    return isNepali ? [] : [
      {'title': 'Coronary Artery Disease: Pathophysiology', 'abstract': 'Atherosclerosis results from endothelial dysfunction, lipid accumulation, inflammation, plaque formation. Risk factors: hyperlipidemia, hypertension, diabetes, smoking, family history. Stable angina vs acute coronary syndrome. Diagnosis: ECG, troponins, stress testing, coronary angiography. Primary prevention crucial.', 'source': 'Circulation, 2024'},
      {'title': 'Heart Failure: Classification and Management', 'abstract': 'HF with reduced (HFrEF, EF <40%) vs preserved (HFpEF, EF ≥50%) ejection fraction. Causes: ischemic heart disease, hypertension, valvular disease, cardiomyopathy. Symptoms: dyspnea, edema, fatigue. Treatment: GDMT for HFrEF (ACE-I/ARB/ARNI, beta-blockers, MRA, SGLT2-I), diuretics, device therapy.', 'source': 'Journal of Cardiac Failure, 2024'},
      {'title': 'Atrial Fibrillation: Stroke Prevention', 'abstract': 'AF increases stroke risk 5-fold. CHA2DS2-VASc score guides anticoagulation. DOACs (apixaban, rivaroxaban, edoxaban, dabigatran) preferred over warfarin: equivalent efficacy, less bleeding, no monitoring. Rate vs rhythm control strategies. Catheter ablation option for selected patients. Left atrial appendage occlusion alternative.', 'source': 'European Heart Journal, 2024'},
      {'title': 'Lipid Management in Cardiovascular Disease', 'abstract': 'Statins first-line for LDL reduction. High-intensity statin (atorvastatin 40-80mg, rosuvastatin 20-40mg) for ASCVD. Target LDL <70 mg/dL, <55 for very high risk. Ezetimibe, PCSK9 inhibitors for inadequate response. Icosapent ethyl for high triglycerides. Emphasize lifestyle: diet, exercise, weight loss.', 'source': 'Journal of Lipid Research, 2024'},
      {'title': 'Acute Myocardial Infarction: Treatment Advances', 'abstract': 'STEMI: primary PCI within 90 minutes gold standard. Thrombolysis if PCI unavailable. Dual antiplatelet therapy (aspirin + P2Y12 inhibitor), statin, beta-blocker, ACE-I. NSTEMI: risk stratification, invasive strategy for high-risk. Early rehabilitation, secondary prevention essential. Mortality significantly reduced with evidence-based care.', 'source': 'New England Journal of Medicine, 2024'},
      {'title': 'Hypertrophic Cardiomyopathy: Diagnosis and Management', 'abstract': 'Genetic disorder causing LV hypertrophy, dynamic obstruction, arrhythmias. Most common cause sudden cardiac death in young athletes. Diagnosis: echo, MRI, genetic testing. Treatment: beta-blockers, calcium channel blockers, disopyramide for symptoms. ICD for high SCD risk. Septal reduction for obstruction. Family screening important.', 'source': 'Cardiology Clinics, 2024'},
      {'title': 'Valvular Heart Disease: Aortic Stenosis', 'abstract': 'AS most common valve disease in developed countries. Causes: calcific degeneration, bicuspid valve, rheumatic. Triad: angina, syncope, dyspnea. Diagnosis: echo (AVA, gradient). Severe symptomatic AS: aortic valve replacement. TAVR vs SAVR based on surgical risk. Asymptomatic: watchful waiting, exercise testing.', 'source': 'Valve Disease Journal, 2024'},
      {'title': 'Cardiac Rehabilitation: Benefits and Implementation', 'abstract': 'Comprehensive program: exercise training, education, counseling, risk factor modification. Reduces mortality 20-30%, improves functional capacity, quality of life. Underutilized: <30% participation. Barriers: referral gaps, access, insurance. Home-based programs alternative. Essential component of secondary prevention post-MI, revascularization, HF.', 'source': 'Rehabilitation Medicine, 2024'},
      {'title': 'Women and Heart Disease: Sex Differences', 'abstract': 'CVD leading cause death in women, underdiagnosed and undertreated. Differences: atypical symptoms, microvascular disease, pregnancy complications (preeclampsia, GDM) increase risk. Hormone therapy not recommended for primary prevention. Risk assessment tools may underestimate. Awareness campaigns (Go Red) improving recognition.', 'source': 'Journal of Women\'s Health, 2024'},
      {'title': 'Sudden Cardiac Death: Risk Stratification', 'abstract': 'Causes: ventricular arrhythmias (VT/VF), CAD, cardiomyopathy, channelopathies. Risk factors: low EF, prior MI, syncope, family history. Primary prevention ICD if EF ≤35%. Genetic testing for inherited conditions. External defibrillators in public spaces. CPR training critical. Survival doubles with early defibrillation.', 'source': 'Resuscitation Journal, 2024'},
    ];
  }
  
  List<Map<String, String>> _getMentalHealthArticles(bool isNepali) {
    return isNepali ? [] : [
      {'title': 'Depression: Diagnosis and Treatment', 'abstract': 'Major depressive disorder affects 280 million worldwide. Symptoms: depressed mood, anhedonia, sleep/appetite changes, fatigue, worthlessness, suicidal ideation (≥2 weeks). Treatment: antidepressants (SSRIs first-line), psychotherapy (CBT, IPT), combination most effective. Severe: ECT, TMS. Suicide risk assessment crucial.', 'source': 'American Journal of Psychiatry, 2024'},
      {'title': 'Anxiety Disorders: Evidence-Based Management', 'abstract': 'Includes GAD, panic disorder, social anxiety, specific phobias, PTSD. Lifetime prevalence 30%. Treatment: CBT (exposure therapy highly effective), SSRIs/SNRIs, benzodiazepines (short-term only). Mindfulness-based therapies beneficial. Comorbid depression common. Screen for substance use. Significant functional impairment if untreated.', 'source': 'Journal of Anxiety Disorders, 2024'},
      {'title': 'Bipolar Disorder: Mood Stabilization Strategies', 'abstract': 'Characterized by manic/hypomanic and depressive episodes. Type I: mania; Type II: hypomania. Treatment: mood stabilizers (lithium, valproate), atypical antipsychotics. Avoid antidepressant monotherapy (mania risk). Psychoeducation, psychotherapy (FFT, IPSRT) adjuncts. Long-term maintenance prevents episodes. High suicide risk during depression.', 'source': 'Bipolar Disorders Journal, 2024'},
      {'title': 'Schizophrenia: Comprehensive Treatment Approaches', 'abstract': 'Chronic psychotic disorder: delusions, hallucinations, disorganized thinking, negative symptoms. First-episode: antipsychotic initiation, psychosocial interventions. Second-generation antipsychotics preferred. Clozapine for treatment-resistant. Long-acting injectables improve adherence. Cognitive remediation, supported employment, family psychoeducation essential. Early intervention improves outcomes.', 'source': 'Schizophrenia Bulletin, 2024'},
      {'title': 'Post-Traumatic Stress Disorder: Trauma-Focused Therapies', 'abstract': 'Develops after traumatic event exposure. Symptoms: intrusions, avoidance, negative cognitions/mood, hyperarousal. Gold-standard treatments: prolonged exposure, cognitive processing therapy, EMDR. SSRIs/SNRIs pharmacotherapy. Complex PTSD requires phase-based approach. High comorbidity with depression, substance use. Veterans, assault survivors particularly affected.', 'source': 'Journal of Traumatic Stress, 2024'},
      {'title': 'Attention-Deficit/Hyperactivity Disorder in Adults', 'abstract': 'Persists from childhood in 50-65%. Symptoms: inattention, hyperactivity, impulsivity affecting work, relationships. Diagnosis: clinical assessment, rating scales, rule out alternatives. Treatment: stimulants (methylphenidate, amphetamines) first-line, atomoxetine, bupropion alternatives. CBT for executive functioning. Accommodations helpful.', 'source': 'Adult ADHD Research, 2024'},
      {'title': 'Substance Use Disorders: Medication-Assisted Treatment', 'abstract': 'Opioid use disorder: methadone, buprenorphine, naltrexone reduce overdose deaths 50%. Alcohol: naltrexone, acamprosate, disulfiram. Tobacco: varenicline, bupropion, nicotine replacement. Combine with behavioral interventions. Harm reduction approaches (naloxone distribution, syringe exchange) save lives. Stigma major barrier to treatment.', 'source': 'Addiction Medicine, 2024'},
      {'title': 'Cognitive Behavioral Therapy: Mechanisms and Applications', 'abstract': 'Evidence-based psychotherapy for depression, anxiety, PTSD, eating disorders, insomnia, chronic pain. Focuses on thought-behavior-emotion connections. Techniques: cognitive restructuring, behavioral activation, exposure, problem-solving. Typically 12-16 sessions. Durable effects. Online/app-based CBT increases accessibility. Training standards important for fidelity.', 'source': 'Behavior Therapy, 2024'},
      {'title': 'Suicide Prevention: Risk Assessment and Intervention', 'abstract': '700,000 suicide deaths annually. Risk factors: mental illness, previous attempts, substance use, access to means, social isolation, hopelessness. Warning signs: talking about death, giving away possessions, mood changes. Interventions: safety planning, means restriction, crisis hotlines, follow-up contact. Zero suicide initiatives in healthcare systems.', 'source': 'Crisis: The Journal, 2024'},
      {'title': 'Digital Mental Health: Apps and Telepsychiatry', 'abstract': 'Telehealth increases access to mental healthcare, especially rural areas. Comparable effectiveness to in-person for many conditions. Mental health apps: meditation (Headspace, Calm), CBT (MoodGYM), peer support. Evidence variable; FDA approval emerging. Privacy concerns. Not replacement for severe illness. Adjunct to traditional care.', 'source': 'Digital Psychiatry, 2024'},
    ];
  }

  void _showHelpAndSupportDialog() {
    final isNepali = _isNepali(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isNepali ? 'सहायता र समर्थन' : 'Help & Support'),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.75,
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: isNepali ? 'प्लाटफर्म' : 'Platform'),
                      Tab(text: isNepali ? 'बिरामी' : 'Patients'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildPlatformGuide(isNepali),
                        _buildPatientGuide(isNepali),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isNepali ? 'बन्द गर्नुहोस्' : 'Close'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildPlatformGuide(bool isNepali) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHelpSection(
          title: isNepali ? 'डृ. साथी बारेमा' : 'About Dr. Saathi',
          content: isNepali
              ? 'डृ. साथी नेपालको सबैभन्दा अग्रणी स्वास्थ्य सेवा प्लेटफर्म हो। यसले बिरामी र डाक्टरहरूलाई जोड्छ, लक्षण परीक्षण, आपतकालीन सेवा, स्वास्थ्य जानकारी, र बीमा सेवा प्रदान गर्दछ।'
              : 'Dr. Saathi is Nepal\'s leading healthcare platform connecting patients with doctors. It provides symptom checking, doctor consultations, emergency services, health information, and insurance guidance.',
          icon: Icons.info_outline,
          color: Colors.blue,
        ),
        _buildHelpSection(
          title: isNepali ? 'मुख्य विशेषताहरू' : 'Key Features',
          content: isNepali
              ? '• लक्षण जाँचकर्ता: AI-पावर्ड लक्षण मूल्यांकन\n• डाक्टर फेला पार्नुहोस्: नजिककी विशेषज्ञहरू\n• आपतकालीन सेवा: तुरुन्त सहयोग सम्पर्क\n• स्वास्थ्य स्रोत: विस्तृत लेख र जानकारी\n• वायु गुणस्तर: वास्तविक समय AQI डेटा\n• द्विभाषी: नेपाली र अंग्रेजी'
              : '• Symptom Checker: AI-powered symptom assessment\n• Find Doctors: Locate specialists near you\n• Emergency Services: Immediate support contacts\n• Health Resources: Comprehensive articles\n• Air Quality: Real-time AQI data\n• Bilingual: English & Nepali support',
          icon: Icons.star,
          color: Colors.amber,
        ),
        _buildHelpSection(
          title: isNepali ? 'नेभिगेशन' : 'Navigation',
          content: isNepali
              ? '• घर: मुख्य ड्यासबोर्ड, सबै सेवाहरू\n• प्रोफाइल: व्यक्तिगत जानकारी सम्पादन\n• सेटिङ: भाषा, स्रोत, सम्पर्क\n• मेनु ग्रिड: छिटो पहुँच सबै सेवामा'
              : '• Home: Main dashboard with all services\n• Profile: Edit personal information\n• Settings: Language, resources, contact\n• Menu Grid: Quick access to all features',
          icon: Icons.navigation,
          color: Colors.green,
        ),
      ],
    );
  }
  
  Widget _buildPatientGuide(bool isNepali) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHelpSection(
          title: isNepali ? 'बिरामी दर्ता' : 'Patient Registration',
          content: isNepali
              ? 'सेटिङमा जानुहोस् > बिरामी दर्ता > आफ्नो जानकारी भर्नुहोस्। यसले तपाईंको स्वास्थ्य रेकर्ड राख्न र डाक्टरसँग सजिलोसँग सम्पर्क गर्न मद्दत गर्छ।'
              : 'Go to Settings > Patient Registration > Fill your details. This helps maintain your health records and facilitates easier doctor consultations.',
          icon: Icons.person_add,
          color: Colors.blue,
        ),
        _buildHelpSection(
          title: isNepali ? 'लक्षण जाँचकर्ता प्रयोग' : 'Using Symptom Checker',
          content: isNepali
              ? 'घर > लक्षण जाँचकर्ता > आफ्नो लक्षणहरू वर्णन गर्नुहोस्। AI प्रणालीले सम्भावित कारणहरू र सिफारिसहरू प्रदान गर्नेछ। नोट: यो चिकित्सकीय सलाहको विकल्प हैन।'
              : 'Home > Symptom Checker > Describe your symptoms. AI system provides possible causes and recommendations. Note: Not a substitute for professional medical advice.',
          icon: Icons.health_and_safety,
          color: Colors.cyan,
        ),
        _buildHelpSection(
          title: isNepali ? 'डाक्टर फेला पार्ने' : 'Finding Doctors',
          content: isNepali
              ? 'घर > डाक्टर फेला पार्नुहोस् > विशेषज्ञता चयन गर्नुहोस्। स्थान, उपलब्धता, रेटिङ, र फीसको आधारमा खोज्नुहोस्। अनलाइन अपोइन्टमेन्ट बुक गर्नुहोस्।'
              : 'Home > Find Doctors > Select specialty. Search by location, availability, ratings, and fees. Book online appointments directly through the platform.',
          icon: Icons.local_hospital,
          color: Colors.green,
        ),
        _buildHelpSection(
          title: isNepali ? 'बिरामीका फाइदाहरू' : 'Patient Benefits',
          content: isNepali
              ? '• 24/7 स्वास्थ्य जानकारी पहुँच\n• चित्त बुझ्ने समय र पैसा बचाउनुहोस्\n• विश्वसनीय स्वास्थ्य प्रमाणित स्रोतहरू\n• आफ्नो भाषामा जानकारी (नेपाली/अंग्रेजी)\n• गोपनीय र सुरक्षित स्वास्थ्य रेकर्ड\n• बीमा मार्गदर्शन र समर्थन'
              : '• 24/7 access to health information\n• Save time and money on consultations\n• Verified, evidence-based resources\n• Information in your language\n• Private and secure health records\n• Insurance guidance and support',
          icon: Icons.verified_user,
          color: Colors.purple,
        ),
        _buildHelpSection(
          title: isNepali ? 'आपतकालीन स्थितिमा' : 'Emergency Situations',
          content: isNepali
              ? 'घर > आपतकालीन सेवा > छिटो सम्पर्क। एम्बुलेन्स, प्रहरी, आगो, र अस्पताल हटलाइन तुरुन्त उपलब्ध। जीवन-जोखिम अवस्थामा 102 मा कल गर्नुहोस्।'
              : 'Home > Emergency Services > Quick contacts. Ambulance, police, fire, and hospital hotlines instantly available. Call 102 for life-threatening situations.',
          icon: Icons.emergency,
          color: Colors.red,
        ),
      ],
    );
  }
  
  Widget _buildDoctorGuide(bool isNepali) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHelpSection(
          title: isNepali ? 'डाक्टर पोर्टल पहुँच' : 'Doctor Portal Access',
          content: isNepali
              ? 'घर > डाक्टर पोर्टल > लगइन वा दर्ता। आफ्नो पेशागत प्रत्यय पत्र र चिकित्सा इजाजतपत्र आवश्यक पर्नेछ। प्रमाणीकरण पछि पूर्ण पहुँच।'
              : 'Home > Doctor Portal > Login or Register. Professional credentials and medical license required. Full access after verification.',
          icon: Icons.medical_services,
          color: Colors.teal,
        ),
        _buildHelpSection(
          title: isNepali ? 'बिरामी व्यवस्थापन' : 'Patient Management',
          content: isNepali
              ? 'डाक्टर ड्यासबोर्डमा सबै बिरामी रेकर्ड हेर्नुहोस्। अपोइन्टमेन्ट व्यवस्थापन, नुस्खे लेख्ने, टेस्ट परिणाम अपलोड, र फलो-अप सम्भावनाहरू।'
              : 'View all patient records in doctor dashboard. Manage appointments, write prescriptions, upload test results, and schedule follow-ups.',
          icon: Icons.people,
          color: Colors.blue,
        ),
        _buildHelpSection(
          title: isNepali ? 'विरुवापरामर्श सेवा' : 'Teleconsultation',
          content: isNepali
              ? 'भिडियो परामर्श सुविधा। बिरामीसँग अनलाइन माध्यमबाट सहज संवाद। सुरक्षित र गोपनीय प्लाटफर्म। च्याट, विडियो, र फाइल साझागर्नुहोस्।'
              : 'Video consultation feature. Easy communication with patients online. Secure and private platform. Chat, video, and file sharing available.',
          icon: Icons.video_call,
          color: Colors.green,
        ),
        _buildHelpSection(
          title: isNepali ? 'डाक्टरका फाइदाहरू' : 'Doctor Benefits',
          content: isNepali
              ? '• अभ्यास पहुँच बढाउनुहोस्\n• डिजिटल रेकर्ड व्यवस्थापन\n• अनलाइन विरुवापरामर्श अवसर\n• स्वचालित अपोइन्टमेन्ट व्यवस्था\n• आय प्रचूरता विश्लेषण\n• व्यावसायिक दृश्यता बढाउनुहोस्'
              : '• Expand practice reach\n• Digital record management\n• Online consultation opportunities\n• Automated appointment system\n• Revenue analytics\n• Increased professional visibility',
          icon: Icons.trending_up,
          color: Colors.orange,
        ),
        _buildHelpSection(
          title: isNepali ? 'आय व्यवस्थापन' : 'Revenue Management',
          content: isNepali
              ? 'पूर्ण भुक्तानी प्रणाली एकीकृत। फीस सेटिङ, इन्भॉइसिङ, र पेमेन्ट ट्र्याकिङ। मासिक र वार्षिक आय रिपोर्ट। बीमा दाबी समर्थन।'
              : 'Complete payment system integrated. Fee settings, invoicing, and payment tracking. Monthly and annual revenue reports. Insurance claim support.',
          icon: Icons.account_balance_wallet,
          color: Colors.indigo,
        ),
        _buildHelpSection(
          title: isNepali ? 'पेशागत सहयोग' : 'Professional Support',
          content: isNepali
              ? '• 24/7 प्राविधिक सहयोग\n• नियमित प्लेटफर्म अपडेट\n• प्रशिक्षण सामग्री उपलब्ध\n• अन्य डाक्टरसँग नेटवर्किङ\n• जारी चिकित्सा शिक्षा (CME)\n• कानूनी र क्लेम सहयोग'
              : '• 24/7 technical support\n• Regular platform updates\n• Training materials available\n• Networking with other doctors\n• Continuing Medical Education (CME)\n• Legal and claim support',
          icon: Icons.support_agent,
          color: Colors.purple,
        ),
      ],
    );
  }
  
  Widget _buildHelpSection({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactUsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contact Us'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Get in touch with our support team'),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email Support'),
                subtitle: const Text('support@drsaathi.com'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening email client...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Phone Support'),
                subtitle: const Text('+1 (555) 123-4567'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calling support...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('Live Chat'),
                subtitle: const Text('Chat with our team'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Live chat coming soon')),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _getCurrentTab() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildProfileTab();
      case 2:
        return _buildSettingsTab();
      default:
        return _buildHomeTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _getCurrentTab(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: AppLocalizations.of(context)!.profile,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0 ? FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Dr. Saathi',
        backgroundColor: Colors.lightBlue[600],
        child: ClipOval(
          child: Image.asset(
            'assets/images/dr_saathi_icon.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
      ) : null,
    );
  }
}
