import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'generated/l10n/app_localizations.dart';
import 'screens/doctor_login.dart';
import 'screens/doctor_dashboard.dart';
import 'screens/doctor_profile_screen.dart';
import 'screens/appointments_screen.dart';
import 'services/database_service.dart';
import 'services/sms_service.dart';
import 'services/symptom_checker_service.dart';
import 'services/pharmacy_service.dart';
import 'services/appointment_service.dart';
import 'services/nmc_verification_service.dart';
import 'services/payment_hold_service.dart';
import 'services/refund_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (optional - requires firebase_options.dart)
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization skipped: $e');
  }
  
  // Initialize services
  try {
    if (!kIsWeb) {
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
    
    // Initialize Appointment service
    final appointmentService = AppointmentService();
    await appointmentService.initialize();
    
    // Initialize NMC verification service
    final nmcService = NMCVerificationService();
    await nmcService.initialize();
    print('NMC Verification service initialized');
    
    // Load sample NMC data (remove in production)
    await nmcService.loadSampleNMCData();
    print('Sample NMC data loaded');
    
    // Initialize Payment Hold service (24-hour hold before release to doctor)
    final holdService = PaymentHoldService();
    await holdService.initialize();
    
    // Initialize Refund service
    final refundService = RefundService();
    await refundService.initialize();
    
    // Release any expired holds (past 24 hours)
    final released = await holdService.releaseExpiredHolds();
    if (released > 0) print('Released $released expired payment holds');
    
    // Initialize database
    final databaseService = DatabaseService();
    await databaseService.database;
    print('Database initialized successfully');
  } catch (e) {
    print('Service initialization error: $e');
  }
  
  runApp(const DoctorPortalApp());
}

class DoctorPortalApp extends StatelessWidget {
  const DoctorPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dr. Saathi - Doctor Portal',
      debugShowCheckedModeBanner: false,
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          primary: Colors.teal,
        ),
        primarySwatch: Colors.teal,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal[700],
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const DoctorLoginScreen(),
        '/dashboard': (context) => const DoctorDashboardScreen(),
        '/doctor_profile': (context) => const DoctorProfileScreen(),
        '/appointments': (context) => const AppointmentsScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    _controller.forward();

    // Floating animation: moves icon up 2mm and back, looping
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: -7.56).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal[700]!,
              Colors.teal[400]!,
              Colors.teal[200]!,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo — animated float showing 2mm upward movement
                  AnimatedBuilder(
                    animation: _floatAnimation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: child,
                    ),
                    child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 15,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: ClipOval(
                      child: Transform.translate(
                        offset: const Offset(0, -7.56), // 2mm up inside icon
                        child: Image.asset(
                          'assets/images/dr_saathi_icon.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  ),
                  const SizedBox(height: 30),
                  
                  // App Title
                  const Text(
                    'Dr. Saathi',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Subtitle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'DOCTOR PORTAL',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  const Text(
                    'Your Professional Healthcare Companion',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Loading indicator
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
