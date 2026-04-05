import 'package:uuid/uuid.dart';
import '../models/doctor.dart';

class DoctorService {
  static final DoctorService _instance = DoctorService._internal();
  factory DoctorService() => _instance;
  DoctorService._internal();

  final List<Doctor> _doctors = [];
  final List<Appointment> _appointments = [];
  final Uuid _uuid = const Uuid();

  List<Doctor> get doctors => _doctors;
  List<Appointment> get appointments => _appointments;

  Future<void> initialize() async {
    // Load sample doctors
    await _loadSampleDoctors();
  }

  Future<void> _loadSampleDoctors() async {
    final now = DateTime.now();
    
    // Sample doctors with availability
    final sampleDoctors = [
      Doctor(
        id: _uuid.v4(),
        name: 'Dr. Sarah Johnson',
        specialization: 'General Practitioner',
        hospital: 'City Medical Center',
        phone: '+1234567890',
        email: 'sarah.johnson@citymed.com',
        address: '123 Main St, City, State 12345',
        rating: 4.8,
        experience: 12,
        profileImage: 'assets/images/doctor1.png',
        qualifications: ['MBBS', 'MD'],
        languages: ['English', 'Spanish'],
        consultationFee: 150.0,
        about: 'Experienced general practitioner with expertise in family medicine and preventive care.',
        availabilitySlots: _generateAvailabilitySlots('dr1', now),
        isActive: true,
        nmcRegistrationNumber: 'NMC/GP/2020/001',
        isNmcVerified: true,
        createdAt: now,
        updatedAt: now,
      ),
      Doctor(
        id: _uuid.v4(),
        name: 'Dr. Michael Chen',
        specialization: 'Cardiologist',
        hospital: 'Heart Specialists Hospital',
        phone: '+1234567891',
        email: 'michael.chen@heartspec.com',
        address: '456 Oak Ave, City, State 12345',
        rating: 4.9,
        experience: 15,
        profileImage: 'assets/images/doctor2.png',
        qualifications: ['MBBS', 'MD', 'DM Cardiology'],
        languages: ['English', 'Mandarin'],
        consultationFee: 250.0,
        about: 'Leading cardiologist specializing in interventional cardiology and heart disease prevention.',
        availabilitySlots: _generateAvailabilitySlots('dr2', now),
        isActive: true,
        nmcRegistrationNumber: 'NMC/CARD/2018/002',
        isNmcVerified: true,
        createdAt: now,
        updatedAt: now,
      ),
      Doctor(
        id: _uuid.v4(),
        name: 'Dr. Emily Rodriguez',
        specialization: 'Pediatrician',
        hospital: 'Children\'s Medical Center',
        phone: '+1234567892',
        email: 'emily.rodriguez@childmed.com',
        address: '789 Pine St, City, State 12345',
        rating: 4.7,
        experience: 8,
        profileImage: 'assets/images/doctor3.png',
        qualifications: ['MBBS', 'MD Pediatrics'],
        languages: ['English', 'Spanish'],
        consultationFee: 180.0,
        about: 'Caring pediatrician dedicated to providing comprehensive healthcare for children.',
        availabilitySlots: _generateAvailabilitySlots('dr3', now),
        isActive: true,
        nmcRegistrationNumber: 'NMC/PED/2019/003',
        isNmcVerified: true,
        createdAt: now,
        updatedAt: now,
      ),
      Doctor(
        id: _uuid.v4(),
        name: 'Dr. David Kim',
        specialization: 'Dermatologist',
        hospital: 'Skin Care Clinic',
        phone: '+1234567893',
        email: 'david.kim@skincare.com',
        address: '321 Elm St, City, State 12345',
        rating: 4.6,
        experience: 10,
        profileImage: 'assets/images/doctor4.png',
        qualifications: ['MBBS', 'MD Dermatology'],
        languages: ['English', 'Korean'],
        consultationFee: 200.0,
        about: 'Expert dermatologist specializing in skin conditions and cosmetic treatments.',
        availabilitySlots: _generateAvailabilitySlots('dr4', now),
        isActive: true,
        nmcRegistrationNumber: 'NMC/DERM/2017/004',
        isNmcVerified: true,
        createdAt: now,
        updatedAt: now,
      ),
      Doctor(
        id: _uuid.v4(),
        name: 'Dr. Lisa Thompson',
        specialization: 'Psychiatrist',
        hospital: 'Mental Health Institute',
        phone: '+1234567894',
        email: 'lisa.thompson@mentalhealth.com',
        address: '654 Maple Ave, City, State 12345',
        rating: 4.9,
        experience: 14,
        profileImage: 'assets/images/doctor5.png',
        qualifications: ['MBBS', 'MD Psychiatry'],
        languages: ['English', 'French'],
        consultationFee: 220.0,
        about: 'Compassionate psychiatrist helping patients with mental health and emotional wellness.',
        availabilitySlots: _generateAvailabilitySlots('dr5', now),
        isActive: true,
        nmcRegistrationNumber: 'NMC/PSY/2016/005',
        isNmcVerified: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    _doctors.addAll(sampleDoctors);
  }

  List<AvailabilitySlot> _generateAvailabilitySlots(String doctorId, DateTime baseDate) {
    final slots = <AvailabilitySlot>[];
    final now = DateTime.now();
    
    // Generate slots for the next 7 days
    for (int day = 0; day < 7; day++) {
      final date = baseDate.add(Duration(days: day));
      final dayName = _getDayName(date.weekday);
      
      // Skip weekends for some doctors
      if (date.weekday == 6 || date.weekday == 7) {
        continue;
      }
      
      // Morning slots (9:00 AM - 12:00 PM)
      for (int hour = 9; hour < 12; hour++) {
        final startTime = DateTime(date.year, date.month, date.day, hour, 0);
        final endTime = startTime.add(const Duration(hours: 1));
        
        slots.add(AvailabilitySlot(
          id: _uuid.v4(),
          doctorId: doctorId,
          startTime: startTime,
          endTime: endTime,
          isAvailable: startTime.isAfter(now),
          isBooked: false,
          dayOfWeek: dayName,
          consultationType: ConsultationType.both,
          createdAt: now,
          updatedAt: now,
        ));
      }
      
      // Afternoon slots (2:00 PM - 5:00 PM)
      for (int hour = 14; hour < 17; hour++) {
        final startTime = DateTime(date.year, date.month, date.day, hour, 0);
        final endTime = startTime.add(const Duration(hours: 1));
        
        slots.add(AvailabilitySlot(
          id: _uuid.v4(),
          doctorId: doctorId,
          startTime: startTime,
          endTime: endTime,
          isAvailable: startTime.isAfter(now),
          isBooked: false,
          dayOfWeek: dayName,
          consultationType: ConsultationType.both,
          createdAt: now,
          updatedAt: now,
        ));
      }
    }
    
    return slots;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }

  // Search doctors by various criteria
  List<Doctor> searchDoctors({
    String? name,
    String? specialization,
    String? hospital,
    DateTime? availableDate,
    double? maxFee,
    double? minRating,
  }) {
    return _doctors.where((doctor) {
      if (name != null && !doctor.name.toLowerCase().contains(name.toLowerCase())) {
        return false;
      }
      if (specialization != null && !doctor.specialization.toLowerCase().contains(specialization.toLowerCase())) {
        return false;
      }
      if (hospital != null && !doctor.hospital.toLowerCase().contains(hospital.toLowerCase())) {
        return false;
      }
      if (maxFee != null && doctor.consultationFee > maxFee) {
        return false;
      }
      if (minRating != null && doctor.rating < minRating) {
        return false;
      }
      if (availableDate != null) {
        final hasAvailability = doctor.availabilitySlots.any((slot) =>
          slot.isAvailable && 
          !slot.isBooked &&
          slot.startTime.day == availableDate.day &&
          slot.startTime.month == availableDate.month &&
          slot.startTime.year == availableDate.year
        );
        if (!hasAvailability) return false;
      }
      return doctor.isActive;
    }).toList();
  }

  // Get doctors by specialization
  List<Doctor> getDoctorsBySpecialization(String specialization) {
    return _doctors.where((doctor) => 
      doctor.specialization.toLowerCase() == specialization.toLowerCase() && 
      doctor.isActive
    ).toList();
  }

  // Get doctor by ID
  Doctor? getDoctorById(String doctorId) {
    try {
      return _doctors.firstWhere((doctor) => doctor.id == doctorId);
    } catch (e) {
      return null;
    }
  }

  // Get available slots for a doctor
  List<AvailabilitySlot> getAvailableSlots(String doctorId, {DateTime? date}) {
    final doctor = getDoctorById(doctorId);
    if (doctor == null) return [];
    
    List<AvailabilitySlot> slots = doctor.availabilitySlots
      .where((slot) => slot.isAvailable && !slot.isBooked)
      .toList();
    
    if (date != null) {
      slots = slots.where((slot) =>
        slot.startTime.day == date.day &&
        slot.startTime.month == date.month &&
        slot.startTime.year == date.year
      ).toList();
    }
    
    return slots;
  }

  // Book an appointment
  Future<Appointment?> bookAppointment({
    required String patientId,
    required String doctorId,
    required String slotId,
    required ConsultationType consultationType,
    String? notes,
    String? symptoms,
  }) async {
    final doctor = getDoctorById(doctorId);
    if (doctor == null) return null;
    
    // Find the slot
    final slotIndex = doctor.availabilitySlots.indexWhere((slot) => slot.id == slotId);
    if (slotIndex == -1) return null;
    
    final slot = doctor.availabilitySlots[slotIndex];
    if (!slot.isAvailable || slot.isBooked) return null;
    
    // Create appointment
    final appointment = Appointment(
      id: _uuid.v4(),
      patientId: patientId,
      doctorId: doctorId,
      slotId: slotId,
      appointmentDate: slot.startTime,
      startTime: slot.startTime,
      endTime: slot.endTime,
      status: AppointmentStatus.scheduled,
      consultationType: consultationType,
      notes: notes,
      symptoms: symptoms,
      consultationFee: doctor.consultationFee,
      isPaid: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Update slot
    final updatedSlot = slot.copyWith(
      isBooked: true,
      patientId: patientId,
      appointmentId: appointment.id,
      updatedAt: DateTime.now(),
    );
    
    // Update doctor's slots
    final updatedSlots = List<AvailabilitySlot>.from(doctor.availabilitySlots);
    updatedSlots[slotIndex] = updatedSlot;
    
    final updatedDoctor = doctor.copyWith(
      availabilitySlots: updatedSlots,
      updatedAt: DateTime.now(),
    );
    
    // Update doctor in list
    final doctorIndex = _doctors.indexWhere((d) => d.id == doctorId);
    _doctors[doctorIndex] = updatedDoctor;
    
    // Add appointment
    _appointments.add(appointment);
    
    return appointment;
  }

  // Cancel appointment
  Future<bool> cancelAppointment(String appointmentId) async {
    final appointmentIndex = _appointments.indexWhere((apt) => apt.id == appointmentId);
    if (appointmentIndex == -1) return false;
    
    final appointment = _appointments[appointmentIndex];
    
    // Update appointment status
    final updatedAppointment = appointment.copyWith(
      status: AppointmentStatus.cancelled,
      updatedAt: DateTime.now(),
    );
    _appointments[appointmentIndex] = updatedAppointment;
    
    // Free up the slot
    final doctor = getDoctorById(appointment.doctorId);
    if (doctor != null) {
      final slotIndex = doctor.availabilitySlots.indexWhere((slot) => slot.id == appointment.slotId);
      if (slotIndex != -1) {
        final updatedSlot = doctor.availabilitySlots[slotIndex].copyWith(
          isBooked: false,
          patientId: null,
          appointmentId: null,
          updatedAt: DateTime.now(),
        );
        
        final updatedSlots = List<AvailabilitySlot>.from(doctor.availabilitySlots);
        updatedSlots[slotIndex] = updatedSlot;
        
        final updatedDoctor = doctor.copyWith(
          availabilitySlots: updatedSlots,
          updatedAt: DateTime.now(),
        );
        
        final doctorIndex = _doctors.indexWhere((d) => d.id == appointment.doctorId);
        _doctors[doctorIndex] = updatedDoctor;
      }
    }
    
    return true;
  }

  // Get patient appointments
  List<Appointment> getPatientAppointments(String patientId) {
    return _appointments.where((apt) => apt.patientId == patientId).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Get doctor appointments
  List<Appointment> getDoctorAppointments(String doctorId) {
    return _appointments.where((apt) => apt.doctorId == doctorId).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Get upcoming appointments
  List<Appointment> getUpcomingAppointments(String patientId) {
    final now = DateTime.now();
    return _appointments.where((apt) => 
      apt.patientId == patientId &&
      apt.startTime.isAfter(now) &&
      apt.status != AppointmentStatus.cancelled
    ).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  // Get appointment by ID
  Appointment? getAppointmentById(String appointmentId) {
    try {
      return _appointments.firstWhere((apt) => apt.id == appointmentId);
    } catch (e) {
      return null;
    }
  }

  // Update appointment status
  Future<bool> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    final appointmentIndex = _appointments.indexWhere((apt) => apt.id == appointmentId);
    if (appointmentIndex == -1) return false;
    
    final updatedAppointment = _appointments[appointmentIndex].copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    _appointments[appointmentIndex] = updatedAppointment;
    
    return true;
  }

  // Add consultation notes
  Future<bool> addConsultationNotes(String appointmentId, {
    String? diagnosis,
    String? prescription,
    String? notes,
  }) async {
    final appointmentIndex = _appointments.indexWhere((apt) => apt.id == appointmentId);
    if (appointmentIndex == -1) return false;
    
    final updatedAppointment = _appointments[appointmentIndex].copyWith(
      diagnosis: diagnosis,
      prescription: prescription,
      notes: notes,
      updatedAt: DateTime.now(),
    );
    _appointments[appointmentIndex] = updatedAppointment;
    
    return true;
  }

  // Get all specializations
  List<String> getAllSpecializations() {
    return _doctors.map((doctor) => doctor.specialization).toSet().toList()
      ..sort();
  }

  // Get doctors with immediate availability (today)
  List<Doctor> getDoctorsWithImmediateAvailability() {
    final today = DateTime.now();
    return _doctors.where((doctor) {
      return doctor.availabilitySlots.any((slot) =>
        slot.isAvailable &&
        !slot.isBooked &&
        slot.startTime.day == today.day &&
        slot.startTime.month == today.month &&
        slot.startTime.year == today.year &&
        slot.startTime.isAfter(today)
      );
    }).toList();
  }

  // Get highly rated doctors
  List<Doctor> getHighlyRatedDoctors({double minRating = 4.5}) {
    return _doctors.where((doctor) => doctor.rating >= minRating && doctor.isActive).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  // Get doctors by language
  List<Doctor> getDoctorsByLanguage(String language) {
    return _doctors.where((doctor) => 
      doctor.languages.any((lang) => lang.toLowerCase() == language.toLowerCase()) &&
      doctor.isActive
    ).toList();
  }
}
