import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/operations_metrics.dart';
import '../services/operations_monitoring_service.dart';

class OperationsDashboardScreen extends StatefulWidget {
  const OperationsDashboardScreen({Key? key}) : super(key: key);

  @override
  State<OperationsDashboardScreen> createState() =>
      _OperationsDashboardScreenState();
}

class _OperationsDashboardScreenState extends State<OperationsDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _service = OperationsMonitoringService();
  late TabController _tabController;

  ClinicalMetrics? _clinical;
  TechnicalMetrics? _technical;
  ComplianceMetrics? _compliance;
  List<AlertTrigger>? _alerts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final clinical = await _service.getClinicalMetrics('today');
      final technical = await _service.getTechnicalMetrics();
      final compliance = await _service.getComplianceMetrics();
      final alerts = await _service.getAlertTriggers(
        clinical: clinical,
        technical: technical,
        compliance: compliance,
      );
      setState(() {
        _clinical = clinical;
        _technical = technical;
        _compliance = compliance;
        _alerts = alerts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading metrics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operations Monitoring'),
        backgroundColor: Colors.indigo[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAll,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              text: 'Clinical',
              icon: Badge(
                isLabelVisible: _alerts != null &&
                    _alerts!.any((a) =>
                        a.category == 'Clinical' &&
                        a.severity == AlertSeverity.red),
                backgroundColor: Colors.red,
                child: const Icon(Icons.local_hospital),
              ),
            ),
            Tab(
              text: 'Technical',
              icon: Badge(
                isLabelVisible: _alerts != null &&
                    _alerts!.any((a) =>
                        a.category == 'Technical' &&
                        a.severity == AlertSeverity.red),
                backgroundColor: Colors.red,
                child: const Icon(Icons.wifi),
              ),
            ),
            Tab(
              text: 'Compliance',
              icon: Badge(
                isLabelVisible: _alerts != null &&
                    _alerts!.any((a) =>
                        a.category == 'Compliance' &&
                        a.severity == AlertSeverity.red),
                backgroundColor: Colors.red,
                child: const Icon(Icons.shield),
              ),
            ),
            const Tab(text: 'Alerts', icon: Icon(Icons.warning_amber)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildClinicalTab(),
                _buildTechnicalTab(),
                _buildComplianceTab(),
                _buildAlertsTab(),
              ],
            ),
    );
  }

  // ===========================================================================
  // TAB 1: Clinical Operations
  // ===========================================================================

  Widget _buildClinicalTab() {
    final c = _clinical!;
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stat cards — row 1
            Row(children: [
              Expanded(
                child: _statCard(
                  'Avg Wait Time',
                  '${c.avgWaitTimeMinutes} min',
                  Icons.timer,
                  _colorForWait(c.avgWaitTimeMinutes),
                  'Goal: < 10 min',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Success Rate',
                  '${c.consultationSuccessRate}%',
                  Icons.check_circle,
                  c.consultationSuccessRate >= 90 ? Colors.green : Colors.orange,
                  '${c.completedConsultations}/${c.totalConsultationsToday}',
                ),
              ),
            ]),
            const SizedBox(height: 12),
            // Stat cards — row 2
            Row(children: [
              Expanded(
                child: _statCard(
                  'Productivity',
                  '${c.clinicianProductivity}/shift',
                  Icons.speed,
                  Colors.blue,
                  'Per doctor avg',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Time to Treatment',
                  '${c.timeToTreatmentHours} hrs',
                  Icons.access_time,
                  c.timeToTreatmentHours <= 3 ? Colors.green : Colors.orange,
                  'Symptom → resolution',
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _statCard(
                  'No-Show Rate',
                  '${c.noShowRate}%',
                  Icons.person_off,
                  c.noShowRate > 15 ? Colors.red : Colors.amber,
                  '${c.cancelledConsultations} missed',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Total Today',
                  '${c.totalConsultationsToday}',
                  Icons.calendar_today,
                  Colors.indigo,
                  'Consultations',
                ),
              ),
            ]),

            const SizedBox(height: 28),
            const Text('Wait Time Trend (Today)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildWaitTimeChart(c.waitTimeTrend),

            const SizedBox(height: 28),
            const Text('Doctor Productivity (Consultations)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildDoctorProductivityChart(c.doctorProductivityList),
          ],
        ),
      ),
    );
  }

  Color _colorForWait(double mins) {
    if (mins > 15) return Colors.red;
    if (mins > 10) return Colors.orange;
    return Colors.green;
  }

  Widget _buildWaitTimeChart(List<WaitTimeTrend> data) {
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                getTitlesWidget: (v, _) =>
                    Text('${v.toInt()}m', style: const TextStyle(fontSize: 10)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i >= 0 && i < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(data[i].time,
                          style: const TextStyle(fontSize: 9)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(horizontalLines: [
            HorizontalLine(
              y: 10,
              color: Colors.orange.withValues(alpha: 0.5),
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (_) => 'Goal: 10 min',
                style: const TextStyle(fontSize: 9, color: Colors.orange),
              ),
            ),
            HorizontalLine(
              y: 15,
              color: Colors.red.withValues(alpha: 0.5),
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (_) => 'Red: 15 min',
                style: const TextStyle(fontSize: 9, color: Colors.red),
              ),
            ),
          ]),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(data.length,
                  (i) => FlSpot(i.toDouble(), data[i].waitMinutes)),
              isCurved: true,
              color: Colors.indigo,
              barWidth: 2,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.indigo.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorProductivityChart(List<DoctorProductivity> data) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (data.first.consultations + 4).toDouble(),
          barGroups: data.asMap().entries.map((e) {
            return BarChartGroupData(x: e.key, barRods: [
              BarChartRodData(
                toY: e.value.consultations.toDouble(),
                color: Colors.indigo[400],
                width: 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ]);
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (v, _) =>
                    Text('${v.toInt()}', style: const TextStyle(fontSize: 10)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i >= 0 && i < data.length) {
                    final name = data[i].doctorName.replaceFirst('Dr. ', '');
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Text(name,
                            style: const TextStyle(fontSize: 9)),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 2: Technical Health (Nepal Context)
  // ===========================================================================

  Widget _buildTechnicalTab() {
    final t = _technical!;
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: _statCard(
                  'Call Success',
                  '${t.callSuccessRate}%',
                  Icons.call,
                  t.callSuccessRate >= 93 ? Colors.green : Colors.orange,
                  '${t.totalCallsToday} calls today',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Call Drop Rate',
                  '${t.callDropRate}%',
                  Icons.call_end,
                  t.callDropRate > 7
                      ? Colors.red
                      : t.callDropRate > 4
                          ? Colors.orange
                          : Colors.green,
                  '${t.failedCalls} dropped',
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _statCard(
                  'SMS/OTP Latency',
                  '${t.smsOtpLatencySeconds} sec',
                  Icons.sms,
                  t.smsOtpLatencySeconds > 15
                      ? Colors.red
                      : t.smsOtpLatencySeconds > 8
                          ? Colors.orange
                          : Colors.green,
                  'Goal: < 8 sec',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'App Load Time',
                  '${t.appLoadTimeSeconds} sec',
                  Icons.speed,
                  t.appLoadTimeSeconds > 3
                      ? Colors.red
                      : t.appLoadTimeSeconds > 2
                          ? Colors.orange
                          : Colors.green,
                  'Goal: < 2 sec',
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _statCard(
                  'Crash-Free',
                  '${t.crashFreeSessionsRate}%',
                  Icons.bug_report,
                  t.crashFreeSessionsRate >= 99.5 ? Colors.green : Colors.red,
                  'Benchmark: 99.5%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Audio-Only Fallback',
                  '${t.audioOnlyFallbackRate}%',
                  Icons.mic,
                  t.audioOnlyFallbackRate > 20 ? Colors.orange : Colors.blue,
                  'Low bandwidth switch',
                ),
              ),
            ]),

            const SizedBox(height: 28),
            const Text('Regional Bandwidth (Nepal)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildBandwidthList(t.bandwidthSnapshots),

            const SizedBox(height: 28),
            const Text('Latency Trend (Today)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildLatencyChart(t.latencyTrend),
          ],
        ),
      ),
    );
  }

  Widget _buildBandwidthList(List<BandwidthSnapshot> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: data.map((snap) {
            final kbps = snap.avgBitrateKbps;
            final color = kbps >= 800
                ? Colors.green
                : kbps >= 500
                    ? Colors.orange
                    : Colors.red;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(snap.region,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(snap.connectionType,
                        style: const TextStyle(fontSize: 11)),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.circle, size: 10, color: color),
                        const SizedBox(width: 4),
                        Text('${kbps.toInt()} kbps',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLatencyChart(List<LatencyTrend> data) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, _) => Text('${v.toInt()}ms',
                    style: const TextStyle(fontSize: 9)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i >= 0 && i < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(data[i].time,
                          style: const TextStyle(fontSize: 9)),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(data.length,
                  (i) => FlSpot(i.toDouble(), data[i].latencyMs)),
              isCurved: true,
              color: Colors.deepOrange,
              barWidth: 2,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.deepOrange.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 3: Compliance & Security
  // ===========================================================================

  Widget _buildComplianceTab() {
    final cm = _compliance!;
    final dateFormat = DateFormat('MMM dd, yyyy');
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: _statCard(
                  'Audit Trails',
                  NumberFormat.compact().format(cm.totalAuditTrails),
                  Icons.history,
                  Colors.indigo,
                  'Total logged events',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Consent Rate',
                  '${cm.consentRate}%',
                  Icons.verified_user,
                  cm.consentRate >= 99
                      ? Colors.green
                      : cm.consentRate >= 95
                          ? Colors.orange
                          : Colors.red,
                  '${cm.pendingConsentUsers} pending',
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _statCard(
                  'RBAC Violations',
                  '${cm.rbacViolations}',
                  Icons.gpp_bad,
                  cm.rbacViolations > 0 ? Colors.red : Colors.green,
                  cm.rbacViolations > 0
                      ? 'Audit required!'
                      : 'No violations',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Data Lifecycle',
                  '${cm.dataLifecycleComplianceRate}%',
                  Icons.delete_sweep,
                  cm.dataLifecycleComplianceRate >= 95
                      ? Colors.green
                      : Colors.orange,
                  '${cm.expiredDataRecords} expired records',
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Card(
              color: Colors.indigo[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Colors.indigo),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Last Full Audit',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey)),
                        Text(dateFormat.format(cm.lastAuditDate),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),
            const Text('Recent Audit Log (Traceability)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Who accessed what and when — 2026 standard',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 12),
            ...cm.recentAuditLog.map(_buildAuditLogTile),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditLogTile(AuditLogEntry entry) {
    final timeAgo = _timeAgo(entry.timestamp);
    final isViolation =
        entry.action.toLowerCase().contains('attempted') ||
            entry.action.toLowerCase().contains('unauthorized');
    return Card(
      color: isViolation ? Colors.red[50] : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isViolation ? Colors.red[100] : Colors.indigo[100],
          child: Icon(
            isViolation ? Icons.warning : Icons.person,
            color: isViolation ? Colors.red : Colors.indigo,
            size: 20,
          ),
        ),
        title: Text(entry.userName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.action, style: const TextStyle(fontSize: 13)),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(entry.role,
                      style: const TextStyle(fontSize: 10)),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(entry.resource,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(timeAgo,
            style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      ),
    );
  }

  // ===========================================================================
  // TAB 4: Alerts
  // ===========================================================================

  Widget _buildAlertsTab() {
    final redCount =
        _alerts!.where((a) => a.severity == AlertSeverity.red).length;
    final yellowCount =
        _alerts!.where((a) => a.severity == AlertSeverity.yellow).length;
    final greenCount =
        _alerts!.where((a) => a.severity == AlertSeverity.green).length;

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary bar
            Row(children: [
              _alertCountChip(redCount, Colors.red, 'Critical'),
              const SizedBox(width: 8),
              _alertCountChip(yellowCount, Colors.orange, 'Warning'),
              const SizedBox(width: 8),
              _alertCountChip(greenCount, Colors.green, 'OK'),
            ]),
            const SizedBox(height: 20),
            ..._alerts!.map(_buildAlertCard),
          ],
        ),
      ),
    );
  }

  Widget _alertCountChip(int count, Color color, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text('$count',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(AlertTrigger alert) {
    final color = _severityColor(alert.severity);
    final icon = _severityIcon(alert.severity);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(alert.metricName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(alert.category,
                      style: TextStyle(fontSize: 11, color: color)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current: ${alert.currentValue}',
                          style: TextStyle(
                              fontSize: 13,
                              color: color,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('Threshold: ${alert.threshold}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            if (alert.severity != AlertSeverity.green) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.flash_on, size: 16, color: color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(alert.immediateAction,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: color)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _severityColor(AlertSeverity s) {
    switch (s) {
      case AlertSeverity.red:
        return Colors.red;
      case AlertSeverity.yellow:
        return Colors.orange;
      case AlertSeverity.green:
        return Colors.green;
    }
  }

  IconData _severityIcon(AlertSeverity s) {
    switch (s) {
      case AlertSeverity.red:
        return Icons.error;
      case AlertSeverity.yellow:
        return Icons.warning;
      case AlertSeverity.green:
        return Icons.check_circle;
    }
  }

  // ===========================================================================
  // Shared helpers
  // ===========================================================================

  Widget _statCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const Spacer(),
                Icon(Icons.circle, size: 8, color: color),
              ],
            ),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(title,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
