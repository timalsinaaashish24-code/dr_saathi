import 'package:flutter/material.dart';
import '../services/patient_auth_service.dart';
import 'patient_invoice_view.dart';
import '../utils/nepali_number_utils.dart';
import 'nipah_virus_alert_screen.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  final PatientAuthService _authService = PatientAuthService();
  Map<String, String> patientInfo = {};
  bool isLoading = true;
  
  bool _isNepali(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ne';
  }

  @override
  void initState() {
    super.initState();
    _loadPatientInfo();
  }

  Future<void> _loadPatientInfo() async {
    try {
      final info = await _authService.getPatientInfo();
      setState(() {
        patientInfo = info;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading patient info: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final isNepali = _isNepali(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isNepali ? 'लगआउट' : 'Logout'),
        content: Text(isNepali ? 'के तपाईं लगआउट गर्न निश्चित हुनुहुन्छ?' : 'Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isNepali ? 'रद्द गर्नुहोस्' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isNepali ? 'लगआउट' : 'Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNepali = _isNepali(context);
    
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(isNepali ? 'बिरामी ड्यासबोर्ड' : 'Patient Dashboard'),
        backgroundColor: Colors.lightBlue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: isNepali ? 'लगआउट' : 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Critical Health Alert Banner
            _buildNipahAlertBanner(),
            
            const SizedBox(height: 16),
            
            // Welcome Header
            _buildWelcomeCard(),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            Text(
              isNepali ? 'छिट्रो कार्यहरू' : 'Quick Actions',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildActionCard(
                  title: isNepali ? 'मेरो बिलहरू' : 'My Invoices',
                  subtitle: isNepali ? 'बिल र भुक्तानीहरू हेर्नुहोस्' : 'View bills & payments',
                  icon: Icons.receipt_long,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientInvoiceView(
                          patientId: patientInfo['id'],
                        ),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  title: isNepali ? 'चिकित्सा रेकर्डहरू' : 'Medical Records',
                  subtitle: isNepali ? 'स्वास्थ्य इतिहास' : 'Health history',
                  icon: Icons.folder_special,
                  color: Colors.green,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isNepali ? 'चिकित्सा रेकर्ड सुविधा छिट्टै आउँदैछ!' : 'Medical Records feature coming soon!'),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  title: isNepali ? 'भेटघाट' : 'Appointments',
                  subtitle: isNepali ? 'भेट तालिका' : 'Schedule visits',
                  icon: Icons.calendar_today,
                  color: Colors.purple,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isNepali ? 'भेटघाट सुविधा छिट्टै आउँदैछ!' : 'Appointments feature coming soon!'),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  title: isNepali ? 'प्रेस्क्रिप्शनहरू' : 'Prescriptions',
                  subtitle: isNepali ? 'हालको औषधि' : 'Current medications',
                  icon: Icons.medication,
                  color: Colors.orange,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isNepali ? 'प्रेस्क्रिप्शन सुविधा छिट्टै आउँदैछ!' : 'Prescriptions feature coming soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Recent Activity Section
            _buildRecentActivitySection(),
            
            const SizedBox(height: 24),
            
            // Health Tips Section
            _buildHealthTipsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlue[600]!, Colors.lightBlue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.lightBlue.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isNepali(context) ? 'फेरि स्वागत छ!' : 'Welcome back!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      patientInfo['name'] ?? 'Patient',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.email,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  patientInfo['email'] ?? (_isNepali(context) ? 'इमेल छैन' : 'No email'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isNepali(context) ? 'हालसालै कार्यहरू' : 'Recent Activity',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildActivityItem(
                  icon: Icons.receipt,
                  title: _isNepali(context) ? 'बिल सिर्जना भयो' : 'Invoice Generated',
                  subtitle: _isNepali(context) ? 'नयाँ चिकित्सा बिल उपलब्ध छ' : 'New medical bill available',
                  time: _isNepali(context) ? '${NepaliNumberUtils.formatNumber(2, true)} घण्टा अघि' : '2 hours ago',
                  color: Colors.blue,
                ),
                const Divider(),
                _buildActivityItem(
                  icon: Icons.calendar_today,
                  title: _isNepali(context) ? 'भेटघाट तालिका बनाइयो' : 'Appointment Scheduled',
                  subtitle: _isNepali(context) ? 'अर्को भेट शुक्रबार' : 'Next visit on Friday',
                  time: _isNepali(context) ? '${NepaliNumberUtils.formatNumber(1, true)} दिन अघि' : '1 day ago',
                  color: Colors.green,
                ),
                const Divider(),
                _buildActivityItem(
                  icon: Icons.medication,
                  title: _isNepali(context) ? 'प्रेस्क्रिप्शन अपडेट भयो' : 'Prescription Updated',
                  subtitle: _isNepali(context) ? 'नयाँ औषधि थपियो' : 'New medication added',
                  time: _isNepali(context) ? '${NepaliNumberUtils.formatNumber(3, true)} दिन अघि' : '3 days ago',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Text(
        time,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildHealthTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isNepali(context) ? 'स्वास्थ्य सुझावहरू' : 'Health Tips',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: Colors.green[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    Text(
                      _isNepali(context) ? 'दैनिक स्वास्थ्य सुझाव' : 'Daily Health Tip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _isNepali(context) 
                      ? 'हाइड्रेटेड रहन र आफ्नो समग्र स्वास्थ्यलाई समर्थन गर्न प्रतिदिन कम्तिमा ${NepaliNumberUtils.formatNumber(8, true)} गिलास पानी पिउनुहोस्।'
                      : 'Remember to drink at least 8 glasses of water daily to stay hydrated and support your overall health.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNipahAlertBanner() {
    final isNepali = _isNepali(context);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NipahVirusAlertScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red[700]!, Colors.red[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isNepali ? 'गम्भीर स्वास्थ्य चेतावनी' : 'CRITICAL HEALTH ALERT',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isNepali 
                        ? 'निपाह भाइरस - नेपाल उच्च सतर्कतामा'
                        : 'Nipah Virus - Nepal on High Alert',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        isNepali ? 'थप जान्नुहोस्' : 'Learn More',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
