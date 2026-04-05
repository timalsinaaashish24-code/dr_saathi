import 'package:flutter/material.dart';
import 'user_analytics_screen.dart';
import 'admin_feedback_screen.dart';
import 'nmc_registry_management.dart';
import 'doctor_analytics_screen.dart';
import 'operations_dashboard_screen.dart';
import 'doctor_verification_screen.dart';
import 'patient_management_screen.dart';
import 'appointment_management_screen.dart';
import 'fee_configuration_screen.dart';
import 'refund_management_screen.dart';
import 'payout_dashboard_screen.dart';
import 'feature_flags_screen.dart';
import 'health_content_screen.dart';
import 'localization_management_screen.dart';
import 'regional_coverage_screen.dart';
import 'regulatory_reporting_screen.dart';
import 'telecom_status_screen.dart';
import 'support_tickets_screen.dart';
import 'call_log_review_screen.dart';
import 'system_announcements_screen.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/dr_saathi_icon.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Dr. Saathi Admin'),
          ],
        ),
        backgroundColor: Colors.indigo[700],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo[700]!,
              Colors.indigo[500]!,
              Colors.white,
            ],
            stops: const [0.0, 0.3, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Dr. Saathi Logo
                    Container(
                      width: 130,
                      height: 130,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/dr_saathi_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Dr. Saathi',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Complete Management System',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Menu Items
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const SizedBox(height: 20),

                      // Doctor & Patient Management
                      _buildSectionHeader('Doctor & Patient Management'),
                      const SizedBox(height: 12),
                      _buildMenuCard(context, title: 'Doctor Verification', subtitle: 'Approve, reject, or suspend doctor accounts', icon: Icons.verified, color: Colors.blue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorVerificationScreen()))),
                      const SizedBox(height: 12),
                      _buildMenuCard(context, title: 'Patient Management', subtitle: 'Search, view, and manage patient accounts', icon: Icons.people, color: Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PatientManagementScreen()))),
                      const SizedBox(height: 12),
                      _buildMenuCard(context, title: 'Appointment Management', subtitle: 'View, cancel, reschedule, and resolve disputes', icon: Icons.calendar_month, color: Colors.purple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppointmentManagementScreen()))),

                      const SizedBox(height: 32),

                      // Revenue & Billing
                      _buildSectionHeader('Revenue & Billing'),
                      const SizedBox(height: 12),
                      _buildMenuCard(context, title: 'Fee Configuration', subtitle: 'Set consultation fees, commission, and tax rates', icon: Icons.attach_money, color: Colors.teal, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeConfigurationScreen()))),
                      const SizedBox(height: 12),
                      _buildMenuCard(context, title: 'Refund Management', subtitle: 'Process patient refund requests', icon: Icons.money_off, color: Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RefundManagementScreen()))),
                      const SizedBox(height: 12),
                      _buildMenuCard(context, title: 'Payout Dashboard', subtitle: 'Track pending and completed doctor payouts', icon: Icons.account_balance, color: Colors.indigo, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PayoutDashboardScreen()))),

                      const SizedBox(height: 32),

                      // Reports Section
                      _buildSectionHeader('Reports & Analytics'),
                      const SizedBox(height: 12),
                      
                      _buildMenuCard(
                        context,
                        title: 'User Analytics',
                        subtitle: 'View user stats, downloads, and active users',
                        icon: Icons.analytics,
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserAnalyticsScreen(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildMenuCard(
                        context,
                        title: 'Doctor Analytics',
                        subtitle: 'Doctor downloads, active users, and regions',
                        icon: Icons.medical_information,
                        color: Colors.teal,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DoctorAnalyticsScreen(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildMenuCard(
                        context,
                        title: 'Revenue Reports',
                        subtitle: 'View platform revenue and statistics',
                        icon: Icons.monetization_on,
                        color: Colors.orange,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Coming soon')),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildMenuCard(
                        context,
                        title: 'Transaction History',
                        subtitle: 'View all payment transactions',
                        icon: Icons.history,
                        color: Colors.purple,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Coming soon')),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Operations Monitoring Section
                      _buildSectionHeader('Operations Monitoring'),
                      const SizedBox(height: 12),
                      
                      _buildMenuCard(
                        context,
                        title: 'Operations Dashboard',
                        subtitle: 'Clinical, Technical & Compliance metrics',
                        icon: Icons.monitor_heart,
                        color: Colors.red,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OperationsDashboardScreen(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 32),

                      // Content & Configuration
                      _buildSectionHeader('Content & Configuration'),
                      const SizedBox(height: 12),
                      _buildMenuCard(context, title: 'Feature Flags', subtitle: 'Toggle app features on/off remotely', icon: Icons.toggle_on, color: Colors.deepPurple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeatureFlagsScreen()))),
                      const SizedBox(height: 12),
                      _buildMenuCard(context, title: 'Health Content', subtitle: 'Manage health articles, tips, and FAQs', icon: Icons.article, color: Colors.teal, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthContentScreen()))),
                      const SizedBox(height: 12),
                      _buildMenuCard(context, title: 'Localization', subtitle: 'Review and update Nepali/English translations', icon: Icons.translate, color: Colors.blue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalizationManagementScreen()))),

                      const SizedBox(height: 32),

                      // Nepal-Specific
                      _buildSectionHeader('Nepal-Specific'),
                      const SizedBox(height: 12),
                      _buildMenuCard(context, title: 'Regional Coverage', subtitle: 'Province/district doctor and patient distribution', icon: Icons.map, color: Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegionalCoverageScreen()))),
                      const SizedBox(height: 12),
                      _buildMenuCard(context, title: 'Regulatory Reporting', subtitle: 'Generate compliance reports for health bodies', icon: Icons.assessment, color: Colors.indigo, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegulatoryReportingScreen()))),
                      const SizedBox(height: 12),
                      _buildMenuCard(context, title: 'Telecom Status', subtitle: 'NTC/Ncell SMS gateway health monitoring', icon: Icons.cell_tower, color: Colors.deepOrange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TelecomStatusScreen()))),

                      const SizedBox(height: 32),

                      // Support & Moderation
                      _buildSectionHeader('Support & Moderation'),
                      const SizedBox(height: 12),
                      _buildMenuCard(context, title: 'Support Tickets', subtitle: 'Manage escalated user issues and complaints', icon: Icons.support_agent, color: Colors.red, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportTicketsScreen()))),
                      const SizedBox(height: 12),
                      _buildMenuCard(context, title: 'Call/Chat Log Review', subtitle: 'QA review and dispute resolution', icon: Icons.call_to_action, color: Colors.brown, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CallLogReviewScreen()))),
                      const SizedBox(height: 12),
                      _buildMenuCard(context, title: 'System Announcements', subtitle: 'Maintenance banners and update prompts', icon: Icons.campaign, color: Colors.amber, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SystemAnnouncementsScreen()))),

                      const SizedBox(height: 32),

                      // User Management Section
                      _buildSectionHeader('User Management'),
                      const SizedBox(height: 12),
                      _buildMenuCard(context, title: 'User Feedback', subtitle: 'View and respond to user feedback', icon: Icons.feedback, color: Colors.pink, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminFeedbackScreen()))),
                      const SizedBox(height: 12),
                      _buildMenuCard(context, title: 'NMC Registry Management', subtitle: 'Manage verified doctor registrations', icon: Icons.verified_user, color: Colors.teal, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NMCRegistryManagementScreen()))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
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
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
