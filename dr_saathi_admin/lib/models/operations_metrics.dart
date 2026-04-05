/// Severity levels for alert triggers
enum AlertSeverity { green, yellow, red }

/// Clinical Operations & Workflow metrics
class ClinicalMetrics {
  final double avgWaitTimeMinutes;
  final double consultationSuccessRate; // 0-100%
  final double noShowRate; // 0-100%
  final double clinicianProductivity; // consultations per doctor per shift
  final double timeToTreatmentHours;
  final int totalConsultationsToday;
  final int completedConsultations;
  final int cancelledConsultations;
  final List<DoctorProductivity> doctorProductivityList;
  final List<WaitTimeTrend> waitTimeTrend;

  ClinicalMetrics({
    required this.avgWaitTimeMinutes,
    required this.consultationSuccessRate,
    required this.noShowRate,
    required this.clinicianProductivity,
    required this.timeToTreatmentHours,
    required this.totalConsultationsToday,
    required this.completedConsultations,
    required this.cancelledConsultations,
    required this.doctorProductivityList,
    required this.waitTimeTrend,
  });
}

class DoctorProductivity {
  final String doctorName;
  final int consultations;

  DoctorProductivity({required this.doctorName, required this.consultations});
}

class WaitTimeTrend {
  final String time; // e.g. "9 AM", "10 AM"
  final double waitMinutes;

  WaitTimeTrend({required this.time, required this.waitMinutes});
}

/// Technical Health metrics (Nepal context)
class TechnicalMetrics {
  final double callSuccessRate; // 0-100%
  final double callDropRate; // 0-100%
  final double audioOnlyFallbackRate; // 0-100%
  final double avgBitrateKbps;
  final double smsOtpLatencySeconds;
  final double appLoadTimeSeconds;
  final double crashFreeSessionsRate; // 0-100%
  final int totalCallsToday;
  final int failedCalls;
  final List<BandwidthSnapshot> bandwidthSnapshots;
  final List<LatencyTrend> latencyTrend;

  TechnicalMetrics({
    required this.callSuccessRate,
    required this.callDropRate,
    required this.audioOnlyFallbackRate,
    required this.avgBitrateKbps,
    required this.smsOtpLatencySeconds,
    required this.appLoadTimeSeconds,
    required this.crashFreeSessionsRate,
    required this.totalCallsToday,
    required this.failedCalls,
    required this.bandwidthSnapshots,
    required this.latencyTrend,
  });
}

class BandwidthSnapshot {
  final String region;
  final double avgBitrateKbps;
  final String connectionType; // "3G", "4G", "Wi-Fi"

  BandwidthSnapshot({
    required this.region,
    required this.avgBitrateKbps,
    required this.connectionType,
  });
}

class LatencyTrend {
  final String time;
  final double latencyMs;

  LatencyTrend({required this.time, required this.latencyMs});
}

/// Compliance & Security metrics
class ComplianceMetrics {
  final int totalAuditTrails;
  final double dataLifecycleComplianceRate; // 0-100%
  final double consentRate; // 0-100%
  final int rbacViolations;
  final int pendingConsentUsers;
  final int expiredDataRecords;
  final DateTime lastAuditDate;
  final List<AuditLogEntry> recentAuditLog;

  ComplianceMetrics({
    required this.totalAuditTrails,
    required this.dataLifecycleComplianceRate,
    required this.consentRate,
    required this.rbacViolations,
    required this.pendingConsentUsers,
    required this.expiredDataRecords,
    required this.lastAuditDate,
    required this.recentAuditLog,
  });
}

class AuditLogEntry {
  final String userId;
  final String userName;
  final String action; // e.g. "Accessed patient record", "Modified billing"
  final String resource;
  final DateTime timestamp;
  final String role;

  AuditLogEntry({
    required this.userId,
    required this.userName,
    required this.action,
    required this.resource,
    required this.timestamp,
    required this.role,
  });
}

/// Alert trigger with red-flag evaluation
class AlertTrigger {
  final String metricName;
  final String currentValue;
  final String threshold;
  final AlertSeverity severity;
  final String immediateAction;
  final String category; // "Clinical", "Technical", "Compliance"

  AlertTrigger({
    required this.metricName,
    required this.currentValue,
    required this.threshold,
    required this.severity,
    required this.immediateAction,
    required this.category,
  });
}
