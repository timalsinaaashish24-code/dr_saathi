import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/doctor_analytics_service.dart';

class DoctorAnalyticsScreen extends StatefulWidget {
  const DoctorAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<DoctorAnalyticsScreen> createState() => _DoctorAnalyticsScreenState();
}

class _DoctorAnalyticsScreenState extends State<DoctorAnalyticsScreen> {
  final DoctorAnalyticsService _analyticsService = DoctorAnalyticsService();
  bool _isLoading = true;
  
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _geographicData = [];
  List<Map<String, dynamic>> _activityData = [];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await _analyticsService.getDoctorStats();
      final geoData = await _analyticsService.getGeographicDistribution();
      final activityData = await _analyticsService.getDoctorActivityData();

      setState(() {
        _stats = stats;
        _geographicData = geoData;
        _activityData = activityData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Analytics'),
        backgroundColor: Colors.indigo[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Key Metrics Cards
                    _buildKeyMetrics(),
                    
                    const SizedBox(height: 24),
                    
                    // Activity Status
                    _buildActivitySection(),
                    
                    const SizedBox(height: 24),
                    
                    // Geographic Distribution
                    _buildGeographicSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Activity
                    _buildRecentActivitySection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildKeyMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Doctor Portal Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Downloads',
                _stats['totalDownloads'] ?? 0,
                Icons.download,
                Colors.blue,
                'All-time app installs',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Registered Doctors',
                _stats['registeredDoctors'] ?? 0,
                Icons.people,
                Colors.green,
                'Completed signup',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Active Doctors',
                _stats['activeDoctors'] ?? 0,
                Icons.verified_user,
                Colors.orange,
                'Active in last 30 days',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Online Now',
                _stats['onlineNow'] ?? 0,
                Icons.circle,
                Colors.red,
                'Currently active',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    int value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Doctor Activity Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Activity breakdown
            _buildActivityRow(
              'Active (Last 7 days)',
              _stats['activeLastWeek'] ?? 0,
              Colors.green,
            ),
            const Divider(height: 24),
            _buildActivityRow(
              'Active (Last 30 days)',
              _stats['activeLastMonth'] ?? 0,
              Colors.orange,
            ),
            const Divider(height: 24),
            _buildActivityRow(
              'Inactive (>30 days)',
              _stats['inactiveDoctors'] ?? 0,
              Colors.red,
            ),
            
            const SizedBox(height: 20),
            
            // Activity pie chart
            if (_stats['activeDoctors'] != null && _stats['inactiveDoctors'] != null)
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: (_stats['activeDoctors'] ?? 0).toDouble(),
                        title: 'Active\n${_stats['activeDoctors']}',
                        color: Colors.green,
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: (_stats['inactiveDoctors'] ?? 0).toDouble(),
                        title: 'Inactive\n${_stats['inactiveDoctors']}',
                        color: Colors.red,
                        radius: 80,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(String label, int count, Color color) {
    final total = _stats['registeredDoctors'] ?? 1;
    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0';
    
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          '$count ($percentage%)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGeographicSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Geographic Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text('${_geographicData.length} Regions'),
                  backgroundColor: Colors.indigo[50],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Doctors by Province/Region',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            
            // Top regions list
            if (_geographicData.isNotEmpty)
              Column(
                children: _geographicData.take(10).map((region) {
                  return _buildGeographicRow(
                    region['region'] ?? 'Unknown',
                    region['count'] ?? 0,
                    region['percentage'] ?? 0.0,
                  );
                }).toList(),
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No geographic data available'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeographicRow(String region, int count, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                region,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$count doctors (${percentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getRegionColor(percentage),
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Color _getRegionColor(double percentage) {
    if (percentage >= 20) return Colors.green;
    if (percentage >= 10) return Colors.orange;
    return Colors.blue;
  }

  Widget _buildRecentActivitySection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Doctor Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Last 7 days',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            
            if (_activityData.isNotEmpty)
              Column(
                children: _activityData.take(10).map((activity) {
                  return _buildActivityItem(
                    activity['doctorName'] ?? 'Unknown',
                    activity['action'] ?? '',
                    activity['timestamp'] ?? '',
                    activity['location'] ?? '',
                  );
                }).toList(),
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No recent activity'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String doctorName,
    String action,
    String timestamp,
    String location,
  ) {
    IconData icon;
    Color color;
    
    switch (action.toLowerCase()) {
      case 'signup':
        icon = Icons.person_add;
        color = Colors.green;
        break;
      case 'login':
        icon = Icons.login;
        color = Colors.blue;
        break;
      case 'consultation':
        icon = Icons.medical_services;
        color = Colors.orange;
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      action,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (location.isNotEmpty) ...[
                      Text(' • ', style: TextStyle(color: Colors.grey[400])),
                      Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 2),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            _formatTimestamp(timestamp),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return timestamp;
    }
  }
}
