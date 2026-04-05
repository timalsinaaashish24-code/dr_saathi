// =============================================================================
// Doctor Verification & Onboarding
// =============================================================================

enum DoctorStatus { pending, approved, rejected, suspended }

class DoctorVerification {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String specialization;
  final String nmcNumber;
  final DoctorStatus status;
  final DateTime appliedAt;
  final DateTime? verifiedAt;
  final String? rejectionReason;
  final String location;

  DoctorVerification({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialization,
    required this.nmcNumber,
    required this.status,
    required this.appliedAt,
    this.verifiedAt,
    this.rejectionReason,
    required this.location,
  });
}

// =============================================================================
// Patient Management
// =============================================================================

class PatientRecord {
  final String id;
  final String name;
  final String phone;
  final String email;
  final int age;
  final String gender;
  final String location;
  final bool isActive;
  final DateTime registeredAt;
  final DateTime lastActiveAt;
  final int totalConsultations;

  PatientRecord({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.age,
    required this.gender,
    required this.location,
    required this.isActive,
    required this.registeredAt,
    required this.lastActiveAt,
    required this.totalConsultations,
  });
}

// =============================================================================
// Appointment Management
// =============================================================================

enum AppointmentStatus { scheduled, inProgress, completed, cancelled, disputed }

class AppointmentRecord {
  final String id;
  final String patientName;
  final String doctorName;
  final DateTime scheduledAt;
  final AppointmentStatus status;
  final double fee;
  final String type; // "Video", "Audio", "Chat"
  final String? disputeReason;

  AppointmentRecord({
    required this.id,
    required this.patientName,
    required this.doctorName,
    required this.scheduledAt,
    required this.status,
    required this.fee,
    required this.type,
    this.disputeReason,
  });
}

// =============================================================================
// Fee Configuration
// =============================================================================

class FeeConfig {
  final String specialty;
  final double consultationFee;
  final double platformCommissionRate; // percentage
  final double taxRate; // percentage
  final bool isActive;

  FeeConfig({
    required this.specialty,
    required this.consultationFee,
    required this.platformCommissionRate,
    required this.taxRate,
    required this.isActive,
  });

  FeeConfig copyWith({
    double? consultationFee,
    double? platformCommissionRate,
    double? taxRate,
    bool? isActive,
  }) {
    return FeeConfig(
      specialty: specialty,
      consultationFee: consultationFee ?? this.consultationFee,
      platformCommissionRate: platformCommissionRate ?? this.platformCommissionRate,
      taxRate: taxRate ?? this.taxRate,
      isActive: isActive ?? this.isActive,
    );
  }
}

// =============================================================================
// Refund Management
// =============================================================================

enum RefundStatus { pending, approved, rejected, processed }

class RefundRequest {
  final String id;
  final String patientName;
  final String doctorName;
  final String appointmentId;
  final double amount;
  final String reason;
  final RefundStatus status;
  final DateTime requestedAt;
  final DateTime? processedAt;

  RefundRequest({
    required this.id,
    required this.patientName,
    required this.doctorName,
    required this.appointmentId,
    required this.amount,
    required this.reason,
    required this.status,
    required this.requestedAt,
    this.processedAt,
  });
}

// =============================================================================
// Payout Dashboard
// =============================================================================

enum PayoutStatus { pending, processing, completed, failed }

class DoctorPayout {
  final String id;
  final String doctorName;
  final String bankName;
  final String accountNumber;
  final double amount;
  final int consultationCount;
  final PayoutStatus status;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime? paidAt;

  DoctorPayout({
    required this.id,
    required this.doctorName,
    required this.bankName,
    required this.accountNumber,
    required this.amount,
    required this.consultationCount,
    required this.status,
    required this.periodStart,
    required this.periodEnd,
    this.paidAt,
  });
}

// =============================================================================
// Feature Flags
// =============================================================================

class FeatureFlag {
  final String key;
  final String name;
  final String description;
  bool isEnabled;
  final String category;

  FeatureFlag({
    required this.key,
    required this.name,
    required this.description,
    required this.isEnabled,
    required this.category,
  });
}

// =============================================================================
// Health Content
// =============================================================================

class HealthArticle {
  final String id;
  final String title;
  final String category;
  final String language;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final int views;

  HealthArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.language,
    required this.isPublished,
    required this.createdAt,
    this.publishedAt,
    required this.views,
  });
}

// =============================================================================
// Localization
// =============================================================================

class TranslationEntry {
  final String key;
  final String englishText;
  final String nepaliText;
  final bool isReviewed;
  final String screen;

  TranslationEntry({
    required this.key,
    required this.englishText,
    required this.nepaliText,
    required this.isReviewed,
    required this.screen,
  });
}

// =============================================================================
// Regional Coverage
// =============================================================================

class ProvinceCoverage {
  final String province;
  final int totalDoctors;
  final int activeDoctors;
  final int totalPatients;
  final List<DistrictCoverage> districts;

  ProvinceCoverage({
    required this.province,
    required this.totalDoctors,
    required this.activeDoctors,
    required this.totalPatients,
    required this.districts,
  });
}

class DistrictCoverage {
  final String district;
  final int doctors;
  final int patients;
  final bool isUnderserved;

  DistrictCoverage({
    required this.district,
    required this.doctors,
    required this.patients,
    required this.isUnderserved,
  });
}

// =============================================================================
// Regulatory Reporting
// =============================================================================

class RegulatoryReport {
  final String id;
  final String title;
  final String type; // "Monthly", "Quarterly", "Annual"
  final DateTime periodStart;
  final DateTime periodEnd;
  final String status; // "Generated", "Submitted", "Pending"
  final DateTime generatedAt;

  RegulatoryReport({
    required this.id,
    required this.title,
    required this.type,
    required this.periodStart,
    required this.periodEnd,
    required this.status,
    required this.generatedAt,
  });
}

// =============================================================================
// Telecom Integration
// =============================================================================

class TelecomProvider {
  final String name; // "NTC", "Ncell"
  final bool isActive;
  final double deliveryRate; // percentage
  final double avgLatencySeconds;
  final int messagesSentToday;
  final int failedToday;
  final String status; // "Healthy", "Degraded", "Down"

  TelecomProvider({
    required this.name,
    required this.isActive,
    required this.deliveryRate,
    required this.avgLatencySeconds,
    required this.messagesSentToday,
    required this.failedToday,
    required this.status,
  });
}

// =============================================================================
// Support Tickets
// =============================================================================

enum TicketPriority { low, medium, high, critical }
enum TicketStatus { open, inProgress, resolved, closed }

class SupportTicket {
  final String id;
  final String userName;
  final String userType; // "Patient", "Doctor"
  final String subject;
  final String description;
  final TicketPriority priority;
  final TicketStatus status;
  final String category;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? assignedTo;

  SupportTicket({
    required this.id,
    required this.userName,
    required this.userType,
    required this.subject,
    required this.description,
    required this.priority,
    required this.status,
    required this.category,
    required this.createdAt,
    this.resolvedAt,
    this.assignedTo,
  });
}

// =============================================================================
// Call/Chat Log Review
// =============================================================================

class CallLogEntry {
  final String id;
  final String patientName;
  final String doctorName;
  final String type; // "Video", "Audio", "Chat"
  final DateTime startTime;
  final int durationMinutes;
  final double qualityScore; // 1-5
  final bool flagged;
  final String? flagReason;

  CallLogEntry({
    required this.id,
    required this.patientName,
    required this.doctorName,
    required this.type,
    required this.startTime,
    required this.durationMinutes,
    required this.qualityScore,
    required this.flagged,
    this.flagReason,
  });
}

// =============================================================================
// System Announcements
// =============================================================================

enum AnnouncementType { maintenance, update, alert, info }

class SystemAnnouncement {
  final String id;
  final String title;
  final String message;
  final AnnouncementType type;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final String targetAudience; // "All", "Doctors", "Patients"

  SystemAnnouncement({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    required this.targetAudience,
  });
}
