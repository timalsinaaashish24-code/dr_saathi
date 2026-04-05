import 'dart:math';
import '../models/admin_models.dart';

class AdminManagementService {
  final _r = Random();

  // ===========================================================================
  // Doctor Verification
  // ===========================================================================

  Future<List<DoctorVerification>> getDoctorVerifications() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final statuses = DoctorStatus.values;
    final specs = ['General Medicine', 'Cardiology', 'Pediatrics', 'Orthopedics', 'Dermatology', 'ENT', 'Gynecology', 'Neurology'];
    final locations = ['Kathmandu', 'Pokhara', 'Biratnagar', 'Lalitpur', 'Butwal', 'Dharan', 'Bharatpur', 'Hetauda'];
    final names = ['Dr. Ram Sharma', 'Dr. Sita Thapa', 'Dr. Krishna Rana', 'Dr. Maya Gurung', 'Dr. Bikram KC', 'Dr. Anita Shrestha', 'Dr. Rajesh Poudel', 'Dr. Sunita Karki', 'Dr. Dipak Adhikari', 'Dr. Pramila Tamang'];
    return List.generate(names.length, (i) {
      final status = statuses[i % statuses.length];
      return DoctorVerification(
        id: 'DOC_${100 + i}', name: names[i], email: '${names[i].split(' ').last.toLowerCase()}@email.com',
        phone: '98${40 + _r.nextInt(20)}${_r.nextInt(9000000) + 1000000}',
        specialization: specs[i % specs.length], nmcNumber: 'NMC${20000 + _r.nextInt(5000)}',
        status: status, appliedAt: DateTime.now().subtract(Duration(days: 30 + _r.nextInt(60))),
        verifiedAt: status == DoctorStatus.approved ? DateTime.now().subtract(Duration(days: _r.nextInt(20))) : null,
        rejectionReason: status == DoctorStatus.rejected ? 'Incomplete documentation' : null,
        location: locations[i % locations.length],
      );
    });
  }

  // ===========================================================================
  // Patient Management
  // ===========================================================================

  Future<List<PatientRecord>> getPatients() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final names = ['Hari Bahadur', 'Sita Devi', 'Ram Kumar', 'Gita Sharma', 'Bikash Thapa', 'Sarita Rana', 'Deepak Gurung', 'Anita Poudel', 'Suresh KC', 'Mina Tamang', 'Prakash Shrestha', 'Kamala Adhikari'];
    final locations = ['Kathmandu', 'Pokhara', 'Biratnagar', 'Lalitpur', 'Butwal', 'Dharan', 'Bharatpur', 'Hetauda', 'Birgunj', 'Janakpur', 'Dhangadhi', 'Surkhet'];
    return List.generate(names.length, (i) => PatientRecord(
      id: 'PAT_${1000 + i}', name: names[i], phone: '98${40 + _r.nextInt(20)}${_r.nextInt(9000000) + 1000000}',
      email: '${names[i].split(' ').first.toLowerCase()}@email.com', age: 20 + _r.nextInt(50),
      gender: i % 2 == 0 ? 'Male' : 'Female', location: locations[i % locations.length],
      isActive: _r.nextBool(), registeredAt: DateTime.now().subtract(Duration(days: 30 + _r.nextInt(300))),
      lastActiveAt: DateTime.now().subtract(Duration(hours: _r.nextInt(72))),
      totalConsultations: _r.nextInt(20),
    ));
  }

  // ===========================================================================
  // Appointment Management
  // ===========================================================================

  Future<List<AppointmentRecord>> getAppointments() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final patients = ['Hari Bahadur', 'Sita Devi', 'Ram Kumar', 'Gita Sharma', 'Bikash Thapa', 'Sarita Rana', 'Deepak Gurung', 'Anita Poudel'];
    final doctors = ['Dr. Ram Sharma', 'Dr. Sita Thapa', 'Dr. Krishna Rana', 'Dr. Maya Gurung', 'Dr. Bikram KC', 'Dr. Anita Shrestha'];
    final types = ['Video', 'Audio', 'Chat'];
    final statuses = AppointmentStatus.values;
    return List.generate(15, (i) {
      final status = statuses[i % statuses.length];
      return AppointmentRecord(
        id: 'APT_${2000 + i}', patientName: patients[i % patients.length],
        doctorName: doctors[i % doctors.length],
        scheduledAt: DateTime.now().subtract(Duration(hours: _r.nextInt(72))).add(Duration(hours: _r.nextInt(48))),
        status: status, fee: (500 + _r.nextInt(1500)).toDouble(), type: types[i % types.length],
        disputeReason: status == AppointmentStatus.disputed ? 'Doctor was unavailable during scheduled time' : null,
      );
    });
  }

  // ===========================================================================
  // Fee Configuration
  // ===========================================================================

  Future<List<FeeConfig>> getFeeConfigs() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Admin gets clean 30%, Doctor gets 70% minus 13% tax/VAT
    return [
      FeeConfig(specialty: 'General Medicine', consultationFee: 500, platformCommissionRate: 30, taxRate: 13, isActive: true),
      FeeConfig(specialty: 'Cardiology', consultationFee: 1200, platformCommissionRate: 30, taxRate: 13, isActive: true),
      FeeConfig(specialty: 'Pediatrics', consultationFee: 600, platformCommissionRate: 30, taxRate: 13, isActive: true),
      FeeConfig(specialty: 'Orthopedics', consultationFee: 1000, platformCommissionRate: 30, taxRate: 13, isActive: true),
      FeeConfig(specialty: 'Dermatology', consultationFee: 800, platformCommissionRate: 30, taxRate: 13, isActive: true),
      FeeConfig(specialty: 'ENT', consultationFee: 700, platformCommissionRate: 30, taxRate: 13, isActive: true),
      FeeConfig(specialty: 'Gynecology', consultationFee: 900, platformCommissionRate: 30, taxRate: 13, isActive: true),
      FeeConfig(specialty: 'Neurology', consultationFee: 1500, platformCommissionRate: 30, taxRate: 13, isActive: true),
      FeeConfig(specialty: 'Psychiatry', consultationFee: 1000, platformCommissionRate: 30, taxRate: 13, isActive: false),
    ];
  }

  // ===========================================================================
  // Refund Management
  // ===========================================================================

  Future<List<RefundRequest>> getRefundRequests() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final reasons = ['Call dropped during consultation', 'Doctor no-show', 'Wrong prescription', 'Technical failure', 'Double charged', 'Appointment cancelled by doctor'];
    return List.generate(8, (i) => RefundRequest(
      id: 'REF_${3000 + i}', patientName: 'Patient ${i + 1}',
      doctorName: 'Dr. ${['Sharma', 'Thapa', 'Rana', 'Gurung', 'KC', 'Shrestha'][i % 6]}',
      appointmentId: 'APT_${2000 + i}', amount: (300 + _r.nextInt(1200)).toDouble(),
      reason: reasons[i % reasons.length], status: RefundStatus.values[i % RefundStatus.values.length],
      requestedAt: DateTime.now().subtract(Duration(days: _r.nextInt(14))),
      processedAt: i % 3 == 0 ? DateTime.now().subtract(Duration(days: _r.nextInt(5))) : null,
    ));
  }

  // ===========================================================================
  // Payout Dashboard
  // ===========================================================================

  Future<List<DoctorPayout>> getDoctorPayouts() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final doctors = ['Dr. Ram Sharma', 'Dr. Sita Thapa', 'Dr. Krishna Rana', 'Dr. Maya Gurung', 'Dr. Bikram KC', 'Dr. Anita Shrestha', 'Dr. Rajesh Poudel', 'Dr. Sunita Karki'];
    final banks = ['NIC Asia', 'Nabil Bank', 'Himalayan Bank', 'Sanima Bank', 'Global IME', 'Machhapuchchhre Bank'];
    return List.generate(doctors.length, (i) => DoctorPayout(
      id: 'PAY_${4000 + i}', doctorName: doctors[i],
      bankName: banks[i % banks.length], accountNumber: '${_r.nextInt(9000000) + 1000000}00${i}',
      amount: (5000 + _r.nextInt(25000)).toDouble(), consultationCount: 5 + _r.nextInt(30),
      status: PayoutStatus.values[i % PayoutStatus.values.length],
      periodStart: DateTime.now().subtract(const Duration(days: 30)),
      periodEnd: DateTime.now(), paidAt: i % 3 == 0 ? DateTime.now().subtract(Duration(days: _r.nextInt(5))) : null,
    ));
  }

  // ===========================================================================
  // Feature Flags
  // ===========================================================================

  Future<List<FeatureFlag>> getFeatureFlags() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      FeatureFlag(key: 'video_calls', name: 'Video Calls', description: 'Enable video consultations', isEnabled: true, category: 'Consultation'),
      FeatureFlag(key: 'audio_calls', name: 'Audio Calls', description: 'Enable audio-only consultations', isEnabled: true, category: 'Consultation'),
      FeatureFlag(key: 'chat_consult', name: 'Chat Consultation', description: 'Enable text-based consultations', isEnabled: true, category: 'Consultation'),
      FeatureFlag(key: 'symptom_checker', name: 'Symptom Checker', description: 'AI-powered symptom analysis', isEnabled: true, category: 'Features'),
      FeatureFlag(key: 'pharmacy_module', name: 'Pharmacy Module', description: 'In-app pharmacy ordering', isEnabled: false, category: 'Features'),
      FeatureFlag(key: 'lab_booking', name: 'Lab Booking', description: 'Book lab tests through app', isEnabled: false, category: 'Features'),
      FeatureFlag(key: 'push_notifications', name: 'Push Notifications', description: 'Send push notifications to users', isEnabled: true, category: 'Communication'),
      FeatureFlag(key: 'sms_reminders', name: 'SMS Reminders', description: 'Send appointment reminders via SMS', isEnabled: true, category: 'Communication'),
      FeatureFlag(key: 'nepali_language', name: 'Nepali Language', description: 'Enable Nepali language support', isEnabled: true, category: 'Localization'),
      FeatureFlag(key: 'dark_mode', name: 'Dark Mode', description: 'Enable dark mode for apps', isEnabled: false, category: 'UI'),
      FeatureFlag(key: 'maintenance_mode', name: 'Maintenance Mode', description: 'Put all apps in maintenance mode', isEnabled: false, category: 'System'),
    ];
  }

  // ===========================================================================
  // Health Content
  // ===========================================================================

  Future<List<HealthArticle>> getHealthArticles() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final articles = [
      ('Dengue Prevention in Nepal', 'Prevention', 'en', true, 1245),
      ('डेंगु रोकथाम', 'Prevention', 'ne', true, 890),
      ('Managing Diabetes at Home', 'Chronic Care', 'en', true, 2100),
      ('Heart Health Tips', 'Cardiology', 'en', true, 1800),
      ('Pregnancy Care Guide', 'Maternal Health', 'en', true, 3200),
      ('गर्भावस्था स्याहार गाइड', 'Maternal Health', 'ne', true, 2400),
      ('Mental Health Awareness', 'Mental Health', 'en', false, 0),
      ('COVID-19 Booster Information', 'Vaccination', 'en', true, 5600),
      ('Child Nutrition Guide', 'Pediatrics', 'en', true, 1560),
      ('बाल पोषण गाइड', 'Pediatrics', 'ne', false, 0),
    ];
    return List.generate(articles.length, (i) => HealthArticle(
      id: 'ART_${5000 + i}', title: articles[i].$1, category: articles[i].$2,
      language: articles[i].$3, isPublished: articles[i].$4,
      createdAt: DateTime.now().subtract(Duration(days: 10 + _r.nextInt(90))),
      publishedAt: articles[i].$4 ? DateTime.now().subtract(Duration(days: _r.nextInt(30))) : null,
      views: articles[i].$5,
    ));
  }

  // ===========================================================================
  // Localization
  // ===========================================================================

  Future<List<TranslationEntry>> getTranslations() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      TranslationEntry(key: 'login_title', englishText: 'Login', nepaliText: 'लग इन', isReviewed: true, screen: 'Login'),
      TranslationEntry(key: 'signup_title', englishText: 'Sign Up', nepaliText: 'साइन अप', isReviewed: true, screen: 'Login'),
      TranslationEntry(key: 'dashboard', englishText: 'Dashboard', nepaliText: 'ड्यासबोर्ड', isReviewed: true, screen: 'Home'),
      TranslationEntry(key: 'appointments', englishText: 'Appointments', nepaliText: 'अपोइन्टमेन्ट', isReviewed: true, screen: 'Home'),
      TranslationEntry(key: 'book_appointment', englishText: 'Book Appointment', nepaliText: 'अपोइन्टमेन्ट बुक गर्नुहोस्', isReviewed: false, screen: 'Appointments'),
      TranslationEntry(key: 'cancel', englishText: 'Cancel', nepaliText: 'रद्द गर्नुहोस्', isReviewed: true, screen: 'Common'),
      TranslationEntry(key: 'confirm', englishText: 'Confirm', nepaliText: 'पुष्टि गर्नुहोस्', isReviewed: true, screen: 'Common'),
      TranslationEntry(key: 'doctor_profile', englishText: 'Doctor Profile', nepaliText: 'चिकित्सक प्रोफाइल', isReviewed: false, screen: 'Doctor'),
      TranslationEntry(key: 'consultation_fee', englishText: 'Consultation Fee', nepaliText: 'परामर्श शुल्क', isReviewed: true, screen: 'Payment'),
      TranslationEntry(key: 'symptom_checker', englishText: 'Symptom Checker', nepaliText: 'लक्षण जाँचकर्ता', isReviewed: false, screen: 'Features'),
      TranslationEntry(key: 'emergency', englishText: 'Emergency', nepaliText: 'आपतकालीन', isReviewed: true, screen: 'Home'),
      TranslationEntry(key: 'health_tips', englishText: 'Health Tips', nepaliText: 'स्वास्थ्य सुझावहरू', isReviewed: false, screen: 'Content'),
    ];
  }

  // ===========================================================================
  // Regional Coverage
  // ===========================================================================

  Future<List<ProvinceCoverage>> getRegionalCoverage() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      ProvinceCoverage(province: 'Bagmati Province', totalDoctors: 156, activeDoctors: 120, totalPatients: 4500, districts: [
        DistrictCoverage(district: 'Kathmandu', doctors: 85, patients: 2800, isUnderserved: false),
        DistrictCoverage(district: 'Lalitpur', doctors: 35, patients: 900, isUnderserved: false),
        DistrictCoverage(district: 'Bhaktapur', doctors: 20, patients: 450, isUnderserved: false),
        DistrictCoverage(district: 'Nuwakot', doctors: 3, patients: 120, isUnderserved: true),
        DistrictCoverage(district: 'Rasuwa', doctors: 1, patients: 45, isUnderserved: true),
      ]),
      ProvinceCoverage(province: 'Gandaki Province', totalDoctors: 62, activeDoctors: 48, totalPatients: 1800, districts: [
        DistrictCoverage(district: 'Kaski (Pokhara)', doctors: 40, patients: 1200, isUnderserved: false),
        DistrictCoverage(district: 'Tanahu', doctors: 8, patients: 200, isUnderserved: true),
        DistrictCoverage(district: 'Mustang', doctors: 1, patients: 30, isUnderserved: true),
      ]),
      ProvinceCoverage(province: 'Province 1 (Koshi)', totalDoctors: 78, activeDoctors: 55, totalPatients: 2200, districts: [
        DistrictCoverage(district: 'Morang (Biratnagar)', doctors: 35, patients: 1000, isUnderserved: false),
        DistrictCoverage(district: 'Sunsari (Dharan)', doctors: 25, patients: 700, isUnderserved: false),
        DistrictCoverage(district: 'Taplejung', doctors: 2, patients: 60, isUnderserved: true),
      ]),
      ProvinceCoverage(province: 'Lumbini Province', totalDoctors: 54, activeDoctors: 38, totalPatients: 1500, districts: [
        DistrictCoverage(district: 'Rupandehi (Butwal)', doctors: 30, patients: 800, isUnderserved: false),
        DistrictCoverage(district: 'Kapilvastu', doctors: 5, patients: 150, isUnderserved: true),
        DistrictCoverage(district: 'Rolpa', doctors: 1, patients: 35, isUnderserved: true),
      ]),
      ProvinceCoverage(province: 'Madhesh Province', totalDoctors: 48, activeDoctors: 30, totalPatients: 1300, districts: [
        DistrictCoverage(district: 'Dhanusha (Janakpur)', doctors: 20, patients: 500, isUnderserved: false),
        DistrictCoverage(district: 'Parsa (Birgunj)', doctors: 15, patients: 400, isUnderserved: false),
        DistrictCoverage(district: 'Sarlahi', doctors: 3, patients: 100, isUnderserved: true),
      ]),
      ProvinceCoverage(province: 'Karnali Province', totalDoctors: 18, activeDoctors: 10, totalPatients: 400, districts: [
        DistrictCoverage(district: 'Surkhet', doctors: 10, patients: 200, isUnderserved: false),
        DistrictCoverage(district: 'Jumla', doctors: 2, patients: 40, isUnderserved: true),
        DistrictCoverage(district: 'Dolpa', doctors: 0, patients: 15, isUnderserved: true),
        DistrictCoverage(district: 'Humla', doctors: 0, patients: 10, isUnderserved: true),
      ]),
      ProvinceCoverage(province: 'Sudurpashchim Province', totalDoctors: 32, activeDoctors: 20, totalPatients: 800, districts: [
        DistrictCoverage(district: 'Kailali (Dhangadhi)', doctors: 18, patients: 450, isUnderserved: false),
        DistrictCoverage(district: 'Doti', doctors: 3, patients: 80, isUnderserved: true),
        DistrictCoverage(district: 'Bajhang', doctors: 1, patients: 25, isUnderserved: true),
        DistrictCoverage(district: 'Darchula', doctors: 1, patients: 20, isUnderserved: true),
      ]),
    ];
  }

  // ===========================================================================
  // Regulatory Reporting
  // ===========================================================================

  Future<List<RegulatoryReport>> getRegulatoryReports() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      RegulatoryReport(id: 'RPT_001', title: 'Monthly Compliance Report - March 2026', type: 'Monthly', periodStart: DateTime(2026, 3, 1), periodEnd: DateTime(2026, 3, 31), status: 'Generated', generatedAt: DateTime.now().subtract(const Duration(days: 1))),
      RegulatoryReport(id: 'RPT_002', title: 'Q1 2026 Health Service Report', type: 'Quarterly', periodStart: DateTime(2026, 1, 1), periodEnd: DateTime(2026, 3, 31), status: 'Submitted', generatedAt: DateTime.now().subtract(const Duration(days: 3))),
      RegulatoryReport(id: 'RPT_003', title: 'Monthly Compliance Report - February 2026', type: 'Monthly', periodStart: DateTime(2026, 2, 1), periodEnd: DateTime(2026, 2, 28), status: 'Submitted', generatedAt: DateTime(2026, 3, 2)),
      RegulatoryReport(id: 'RPT_004', title: 'Annual Report 2025', type: 'Annual', periodStart: DateTime(2025, 1, 1), periodEnd: DateTime(2025, 12, 31), status: 'Submitted', generatedAt: DateTime(2026, 1, 15)),
      RegulatoryReport(id: 'RPT_005', title: 'Monthly Compliance Report - April 2026', type: 'Monthly', periodStart: DateTime(2026, 4, 1), periodEnd: DateTime(2026, 4, 30), status: 'Pending', generatedAt: DateTime.now()),
    ];
  }

  // ===========================================================================
  // Telecom Integration
  // ===========================================================================

  Future<List<TelecomProvider>> getTelecomStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      TelecomProvider(name: 'Nepal Telecom (NTC)', isActive: true, deliveryRate: 96.5 + _r.nextDouble() * 3, avgLatencySeconds: 3.0 + _r.nextDouble() * 5, messagesSentToday: 800 + _r.nextInt(400), failedToday: 5 + _r.nextInt(20), status: 'Healthy'),
      TelecomProvider(name: 'Ncell', isActive: true, deliveryRate: 94.0 + _r.nextDouble() * 4, avgLatencySeconds: 4.0 + _r.nextDouble() * 8, messagesSentToday: 600 + _r.nextInt(300), failedToday: 8 + _r.nextInt(25), status: _r.nextBool() ? 'Healthy' : 'Degraded'),
      TelecomProvider(name: 'Smart Telecom', isActive: false, deliveryRate: 0, avgLatencySeconds: 0, messagesSentToday: 0, failedToday: 0, status: 'Down'),
    ];
  }

  // ===========================================================================
  // Support Tickets
  // ===========================================================================

  Future<List<SupportTicket>> getSupportTickets() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final tickets = [
      ('Video call keeps freezing', 'Technical', TicketPriority.high, TicketStatus.open, 'Patient', 'Hari Bahadur'),
      ('Cannot upload prescription', 'Technical', TicketPriority.medium, TicketStatus.inProgress, 'Doctor', 'Dr. Ram Sharma'),
      ('Wrong bill amount charged', 'Billing', TicketPriority.high, TicketStatus.open, 'Patient', 'Sita Devi'),
      ('App crashes on appointment page', 'Technical', TicketPriority.critical, TicketStatus.open, 'Patient', 'Ram Kumar'),
      ('Doctor profile not showing NMC', 'Account', TicketPriority.medium, TicketStatus.inProgress, 'Doctor', 'Dr. Maya Gurung'),
      ('Payment not reflecting', 'Billing', TicketPriority.high, TicketStatus.open, 'Patient', 'Gita Sharma'),
      ('Cannot change phone number', 'Account', TicketPriority.low, TicketStatus.resolved, 'Patient', 'Bikash Thapa'),
      ('Audio quality very poor', 'Technical', TicketPriority.medium, TicketStatus.resolved, 'Doctor', 'Dr. Anita Shrestha'),
      ('Refund not processed', 'Billing', TicketPriority.high, TicketStatus.inProgress, 'Patient', 'Sarita Rana'),
      ('Medical report complaint', 'Medical', TicketPriority.critical, TicketStatus.open, 'Patient', 'Deepak Gurung'),
    ];
    return List.generate(tickets.length, (i) => SupportTicket(
      id: 'TKT_${6000 + i}', subject: tickets[i].$1, category: tickets[i].$2,
      priority: tickets[i].$3, status: tickets[i].$4, userType: tickets[i].$5,
      userName: tickets[i].$6,
      description: 'Detailed description for: ${tickets[i].$1}',
      createdAt: DateTime.now().subtract(Duration(hours: _r.nextInt(168))),
      resolvedAt: tickets[i].$4 == TicketStatus.resolved ? DateTime.now().subtract(Duration(hours: _r.nextInt(24))) : null,
      assignedTo: tickets[i].$4 == TicketStatus.inProgress ? 'Support Agent ${_r.nextInt(3) + 1}' : null,
    ));
  }

  // ===========================================================================
  // Call/Chat Log Review
  // ===========================================================================

  Future<List<CallLogEntry>> getCallLogs() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final patients = ['Hari Bahadur', 'Sita Devi', 'Ram Kumar', 'Gita Sharma', 'Bikash Thapa', 'Sarita Rana', 'Deepak Gurung', 'Anita Poudel'];
    final doctors = ['Dr. Ram Sharma', 'Dr. Sita Thapa', 'Dr. Krishna Rana', 'Dr. Maya Gurung', 'Dr. Bikram KC', 'Dr. Anita Shrestha'];
    final types = ['Video', 'Audio', 'Chat'];
    return List.generate(12, (i) {
      final flagged = i == 2 || i == 7;
      return CallLogEntry(
        id: 'CALL_${7000 + i}', patientName: patients[i % patients.length],
        doctorName: doctors[i % doctors.length], type: types[i % types.length],
        startTime: DateTime.now().subtract(Duration(hours: _r.nextInt(72))),
        durationMinutes: 5 + _r.nextInt(25),
        qualityScore: 2.0 + _r.nextDouble() * 3, flagged: flagged,
        flagReason: flagged ? (i == 2 ? 'Patient complaint about diagnosis' : 'Call terminated abruptly') : null,
      );
    });
  }

  // ===========================================================================
  // System Announcements
  // ===========================================================================

  Future<List<SystemAnnouncement>> getAnnouncements() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      SystemAnnouncement(id: 'ANN_001', title: 'Scheduled Maintenance', message: 'System will be down for maintenance on April 5, 2026 from 2:00 AM to 5:00 AM NPT.', type: AnnouncementType.maintenance, isActive: true, startDate: DateTime(2026, 4, 3), endDate: DateTime(2026, 4, 5), targetAudience: 'All'),
      SystemAnnouncement(id: 'ANN_002', title: 'App Update v2.5 Available', message: 'New features include improved video quality and Nepali language support.', type: AnnouncementType.update, isActive: true, startDate: DateTime(2026, 3, 28), endDate: DateTime(2026, 4, 15), targetAudience: 'All'),
      SystemAnnouncement(id: 'ANN_003', title: 'New Doctor Onboarding Webinar', message: 'Join us for a training session on April 10, 2026.', type: AnnouncementType.info, isActive: true, startDate: DateTime(2026, 4, 1), endDate: DateTime(2026, 4, 10), targetAudience: 'Doctors'),
      SystemAnnouncement(id: 'ANN_004', title: 'Dengue Alert - Terai Region', message: 'Increased dengue cases reported. Patients advised to consult immediately if symptoms appear.', type: AnnouncementType.alert, isActive: true, startDate: DateTime(2026, 3, 25), endDate: DateTime(2026, 4, 30), targetAudience: 'Patients'),
      SystemAnnouncement(id: 'ANN_005', title: 'Payment Gateway Update', message: 'eSewa integration updated. Brief disruptions possible.', type: AnnouncementType.maintenance, isActive: false, startDate: DateTime(2026, 3, 15), endDate: DateTime(2026, 3, 16), targetAudience: 'All'),
    ];
  }
}
