import 'dart:math';
import '../models/operations_metrics.dart';

class OperationsMonitoringService {
  final _random = Random();

  // ---------------------------------------------------------------------------
  // Clinical Operations
  // ---------------------------------------------------------------------------

  Future<ClinicalMetrics> getClinicalMetrics(String period) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final waitTime = 4.0 + _random.nextDouble() * 12; // 4-16 min
    final successRate = 78.0 + _random.nextDouble() * 18; // 78-96%
    final noShow = 100.0 - successRate - _random.nextDouble() * 5;
    final productivity = 6.0 + _random.nextDouble() * 8; // 6-14 per shift
    final timeToTreatment = 1.5 + _random.nextDouble() * 4; // 1.5-5.5 hrs
    final totalToday = 80 + _random.nextInt(60);
    final completed = (totalToday * successRate / 100).toInt();

    return ClinicalMetrics(
      avgWaitTimeMinutes: double.parse(waitTime.toStringAsFixed(1)),
      consultationSuccessRate: double.parse(successRate.toStringAsFixed(1)),
      noShowRate: double.parse(noShow.clamp(0, 100).toStringAsFixed(1)),
      clinicianProductivity: double.parse(productivity.toStringAsFixed(1)),
      timeToTreatmentHours: double.parse(timeToTreatment.toStringAsFixed(1)),
      totalConsultationsToday: totalToday,
      completedConsultations: completed,
      cancelledConsultations: totalToday - completed,
      doctorProductivityList: _generateDoctorProductivity(),
      waitTimeTrend: _generateWaitTimeTrend(),
    );
  }

  List<DoctorProductivity> _generateDoctorProductivity() {
    final doctors = [
      'Dr. Ram Sharma',
      'Dr. Sita Thapa',
      'Dr. Krishna Rana',
      'Dr. Maya Gurung',
      'Dr. Bikram KC',
      'Dr. Anita Shrestha',
      'Dr. Rajesh Poudel',
      'Dr. Sunita Karki',
    ];
    return doctors
        .map((d) =>
            DoctorProductivity(doctorName: d, consultations: 4 + _random.nextInt(12)))
        .toList()
      ..sort((a, b) => b.consultations.compareTo(a.consultations));
  }

  List<WaitTimeTrend> _generateWaitTimeTrend() {
    final hours = [
      '8 AM', '9 AM', '10 AM', '11 AM', '12 PM',
      '1 PM', '2 PM', '3 PM', '4 PM', '5 PM',
    ];
    return hours
        .map((h) => WaitTimeTrend(
              time: h,
              waitMinutes: double.parse(
                  (3.0 + _random.nextDouble() * 14).toStringAsFixed(1)),
            ))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Technical Health (Nepal Context)
  // ---------------------------------------------------------------------------

  Future<TechnicalMetrics> getTechnicalMetrics() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final dropRate = 2.0 + _random.nextDouble() * 8; // 2-10%
    final callSuccess = 100.0 - dropRate;
    final audioOnly = 5.0 + _random.nextDouble() * 20; // 5-25%
    final bitrate = 400.0 + _random.nextDouble() * 1200; // 400-1600 kbps
    final otpLatency = 3.0 + _random.nextDouble() * 18; // 3-21 sec
    final loadTime = 0.8 + _random.nextDouble() * 2.5; // 0.8-3.3 sec
    final crashFree = 98.5 + _random.nextDouble() * 1.4; // 98.5-99.9%
    final totalCalls = 120 + _random.nextInt(80);
    final failed = (totalCalls * dropRate / 100).toInt();

    return TechnicalMetrics(
      callSuccessRate: double.parse(callSuccess.toStringAsFixed(1)),
      callDropRate: double.parse(dropRate.toStringAsFixed(1)),
      audioOnlyFallbackRate: double.parse(audioOnly.toStringAsFixed(1)),
      avgBitrateKbps: double.parse(bitrate.toStringAsFixed(0)),
      smsOtpLatencySeconds: double.parse(otpLatency.toStringAsFixed(1)),
      appLoadTimeSeconds: double.parse(loadTime.toStringAsFixed(1)),
      crashFreeSessionsRate: double.parse(crashFree.toStringAsFixed(1)),
      totalCallsToday: totalCalls,
      failedCalls: failed,
      bandwidthSnapshots: _generateBandwidthSnapshots(),
      latencyTrend: _generateLatencyTrend(),
    );
  }

  List<BandwidthSnapshot> _generateBandwidthSnapshots() {
    return [
      BandwidthSnapshot(region: 'Kathmandu Valley', avgBitrateKbps: 1200 + _random.nextDouble() * 600, connectionType: 'Wi-Fi'),
      BandwidthSnapshot(region: 'Pokhara', avgBitrateKbps: 800 + _random.nextDouble() * 400, connectionType: '4G'),
      BandwidthSnapshot(region: 'Biratnagar', avgBitrateKbps: 600 + _random.nextDouble() * 400, connectionType: '4G'),
      BandwidthSnapshot(region: 'Butwal', avgBitrateKbps: 500 + _random.nextDouble() * 300, connectionType: '4G'),
      BandwidthSnapshot(region: 'Dhangadhi', avgBitrateKbps: 300 + _random.nextDouble() * 300, connectionType: '3G'),
      BandwidthSnapshot(region: 'Surkhet', avgBitrateKbps: 250 + _random.nextDouble() * 250, connectionType: '3G'),
      BandwidthSnapshot(region: 'Janakpur', avgBitrateKbps: 400 + _random.nextDouble() * 300, connectionType: '4G'),
    ];
  }

  List<LatencyTrend> _generateLatencyTrend() {
    final hours = [
      '8 AM', '9 AM', '10 AM', '11 AM', '12 PM',
      '1 PM', '2 PM', '3 PM', '4 PM', '5 PM',
    ];
    return hours
        .map((h) => LatencyTrend(
              time: h,
              latencyMs: double.parse(
                  (80.0 + _random.nextDouble() * 200).toStringAsFixed(0)),
            ))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Compliance & Security
  // ---------------------------------------------------------------------------

  Future<ComplianceMetrics> getComplianceMetrics() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final consentRate = 92.0 + _random.nextDouble() * 7; // 92-99%
    final rbacViolations = _random.nextInt(4);

    return ComplianceMetrics(
      totalAuditTrails: 12500 + _random.nextInt(3000),
      dataLifecycleComplianceRate:
          double.parse((94.0 + _random.nextDouble() * 5).toStringAsFixed(1)),
      consentRate: double.parse(consentRate.toStringAsFixed(1)),
      rbacViolations: rbacViolations,
      pendingConsentUsers: 15 + _random.nextInt(30),
      expiredDataRecords: 5 + _random.nextInt(20),
      lastAuditDate: DateTime.now().subtract(Duration(days: _random.nextInt(7))),
      recentAuditLog: _generateAuditLog(),
    );
  }

  List<AuditLogEntry> _generateAuditLog() {
    final entries = [
      AuditLogEntry(userId: 'DOC_042', userName: 'Dr. Ram Sharma', action: 'Accessed patient record', resource: 'Patient #1823', timestamp: DateTime.now().subtract(const Duration(minutes: 12)), role: 'Doctor'),
      AuditLogEntry(userId: 'ADM_001', userName: 'Admin Sita', action: 'Exported billing data', resource: 'Billing Report Q1', timestamp: DateTime.now().subtract(const Duration(minutes: 45)), role: 'Admin'),
      AuditLogEntry(userId: 'DOC_018', userName: 'Dr. Maya Gurung', action: 'Modified prescription', resource: 'Patient #2041', timestamp: DateTime.now().subtract(const Duration(hours: 1)), role: 'Doctor'),
      AuditLogEntry(userId: 'BIL_003', userName: 'Rajesh Billing', action: 'Viewed payment file', resource: 'Invoice #4521', timestamp: DateTime.now().subtract(const Duration(hours: 2)), role: 'Billing'),
      AuditLogEntry(userId: 'DOC_055', userName: 'Dr. Anita Shrestha', action: 'Accessed patient record', resource: 'Patient #983', timestamp: DateTime.now().subtract(const Duration(hours: 3)), role: 'Doctor'),
      AuditLogEntry(userId: 'ADM_002', userName: 'Admin Krishna', action: 'RBAC role change', resource: 'User DOC_042', timestamp: DateTime.now().subtract(const Duration(hours: 5)), role: 'Admin'),
      AuditLogEntry(userId: 'DOC_031', userName: 'Dr. Bikram KC', action: 'Viewed lab results', resource: 'Patient #1456', timestamp: DateTime.now().subtract(const Duration(hours: 8)), role: 'Doctor'),
      AuditLogEntry(userId: 'BIL_001', userName: 'Sunita Billing', action: 'Attempted medical file access', resource: 'Patient #2041', timestamp: DateTime.now().subtract(const Duration(hours: 10)), role: 'Billing'),
    ];
    return entries;
  }

  // ---------------------------------------------------------------------------
  // Alert Triggers — auto-evaluated against thresholds
  // ---------------------------------------------------------------------------

  Future<List<AlertTrigger>> getAlertTriggers({
    required ClinicalMetrics clinical,
    required TechnicalMetrics technical,
    required ComplianceMetrics compliance,
  }) async {
    final alerts = <AlertTrigger>[];

    // Wait Time > 15 min = RED, > 10 min = YELLOW
    alerts.add(AlertTrigger(
      metricName: 'Patient Wait Time',
      currentValue: '${clinical.avgWaitTimeMinutes} min',
      threshold: '< 10 min (goal) / > 15 min (red)',
      severity: clinical.avgWaitTimeMinutes > 15
          ? AlertSeverity.red
          : clinical.avgWaitTimeMinutes > 10
              ? AlertSeverity.yellow
              : AlertSeverity.green,
      immediateAction: clinical.avgWaitTimeMinutes > 15
          ? 'Alert on-call backup doctors immediately.'
          : clinical.avgWaitTimeMinutes > 10
              ? 'Monitor closely — consider activating backup doctors.'
              : 'Within target range.',
      category: 'Clinical',
    ));

    // Call Drop Rate > 7% = RED, > 4% = YELLOW
    alerts.add(AlertTrigger(
      metricName: 'Call Drop Rate',
      currentValue: '${technical.callDropRate}%',
      threshold: '< 4% (goal) / > 7% (red)',
      severity: technical.callDropRate > 7
          ? AlertSeverity.red
          : technical.callDropRate > 4
              ? AlertSeverity.yellow
              : AlertSeverity.green,
      immediateAction: technical.callDropRate > 7
          ? 'Check regional server status and ISP issues.'
          : technical.callDropRate > 4
              ? 'Monitor ISP performance in affected regions.'
              : 'Within target range.',
      category: 'Technical',
    ));

    // Consultation Success Rate < 80% = RED, < 90% = YELLOW
    alerts.add(AlertTrigger(
      metricName: 'Consultation Success Rate',
      currentValue: '${clinical.consultationSuccessRate}%',
      threshold: '> 90% (goal) / < 80% (red)',
      severity: clinical.consultationSuccessRate < 80
          ? AlertSeverity.red
          : clinical.consultationSuccessRate < 90
              ? AlertSeverity.yellow
              : AlertSeverity.green,
      immediateAction: clinical.consultationSuccessRate < 80
          ? 'Investigate no-show rates and technical call failures.'
          : clinical.consultationSuccessRate < 90
              ? 'Review no-show patterns and send reminders.'
              : 'Within target range.',
      category: 'Clinical',
    ));

    // SMS/OTP Latency > 15s = RED, > 8s = YELLOW
    alerts.add(AlertTrigger(
      metricName: 'SMS/OTP Delivery Latency',
      currentValue: '${technical.smsOtpLatencySeconds} sec',
      threshold: '< 8 sec (goal) / > 15 sec (red)',
      severity: technical.smsOtpLatencySeconds > 15
          ? AlertSeverity.red
          : technical.smsOtpLatencySeconds > 8
              ? AlertSeverity.yellow
              : AlertSeverity.green,
      immediateAction: technical.smsOtpLatencySeconds > 15
          ? 'User acquisition will stall. Switch SMS provider or enable fallback OTP.'
          : technical.smsOtpLatencySeconds > 8
              ? 'Monitor SMS gateway performance closely.'
              : 'Within target range.',
      category: 'Technical',
    ));

    // Crash-Free < 99.5% = RED, < 99.8% = YELLOW
    alerts.add(AlertTrigger(
      metricName: 'Crash-Free Sessions',
      currentValue: '${technical.crashFreeSessionsRate}%',
      threshold: '> 99.8% (goal) / < 99.5% (red)',
      severity: technical.crashFreeSessionsRate < 99.5
          ? AlertSeverity.red
          : technical.crashFreeSessionsRate < 99.8
              ? AlertSeverity.yellow
              : AlertSeverity.green,
      immediateAction: technical.crashFreeSessionsRate < 99.5
          ? 'HIGH RISK: Crash during consultation. Immediate engineering review.'
          : technical.crashFreeSessionsRate < 99.8
              ? 'Review crash logs and prioritize fixes.'
              : 'Within target range.',
      category: 'Technical',
    ));

    // App Load Time > 2s = YELLOW, > 3s = RED
    alerts.add(AlertTrigger(
      metricName: 'App Load Time',
      currentValue: '${technical.appLoadTimeSeconds} sec',
      threshold: '< 2 sec (goal) / > 3 sec (red)',
      severity: technical.appLoadTimeSeconds > 3
          ? AlertSeverity.red
          : technical.appLoadTimeSeconds > 2
              ? AlertSeverity.yellow
              : AlertSeverity.green,
      immediateAction: technical.appLoadTimeSeconds > 3
          ? 'Critical in emergencies. Optimize startup and reduce bundle size.'
          : technical.appLoadTimeSeconds > 2
              ? 'Review asset loading and lazy-load non-critical modules.'
              : 'Within target range.',
      category: 'Technical',
    ));

    // RBAC Violations > 0 = RED
    alerts.add(AlertTrigger(
      metricName: 'RBAC Violations',
      currentValue: '${compliance.rbacViolations}',
      threshold: '0 (strict)',
      severity: compliance.rbacViolations > 0
          ? AlertSeverity.red
          : AlertSeverity.green,
      immediateAction: compliance.rbacViolations > 0
          ? 'Immediate audit: ${compliance.rbacViolations} unauthorized access attempt(s).'
          : 'No violations detected.',
      category: 'Compliance',
    ));

    // Consent Rate < 100% = YELLOW, < 95% = RED
    alerts.add(AlertTrigger(
      metricName: 'Consent Rate',
      currentValue: '${compliance.consentRate}%',
      threshold: '100% (goal) / < 95% (red)',
      severity: compliance.consentRate < 95
          ? AlertSeverity.red
          : compliance.consentRate < 100
              ? AlertSeverity.yellow
              : AlertSeverity.green,
      immediateAction: compliance.consentRate < 95
          ? 'Block new consultations for users without consent. ${compliance.pendingConsentUsers} users pending.'
          : compliance.consentRate < 100
              ? '${compliance.pendingConsentUsers} users need consent renewal.'
              : 'All users have valid consent.',
      category: 'Compliance',
    ));

    // Medication Errors > 0 = RED (always green in mock — real data would feed this)
    alerts.add(AlertTrigger(
      metricName: 'Medication Errors',
      currentValue: '0',
      threshold: '0 (zero tolerance)',
      severity: AlertSeverity.green,
      immediateAction: 'No medication errors. Immediate clinical audit required if > 0.',
      category: 'Clinical',
    ));

    // Sort: reds first, then yellows, then greens
    alerts.sort((a, b) => b.severity.index.compareTo(a.severity.index));

    return alerts;
  }
}
