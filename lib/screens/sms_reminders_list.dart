import 'package:flutter/material.dart';
import 'package:dr_saathi/generated/l10n/app_localizations.dart';
import '../models/sms_reminder.dart';
import '../services/sms_service.dart';
import '../services/database_service.dart';
import 'sms_reminder_screen.dart';

class SmsRemindersList extends StatefulWidget {
  const SmsRemindersList({super.key});

  @override
  _SmsRemindersListState createState() => _SmsRemindersListState();
}

class _SmsRemindersListState extends State<SmsRemindersList> {
  final SmsService _smsService = SmsService();
  final DatabaseService _databaseService = DatabaseService();
  
  List<SmsReminder> _reminders = [];
  List<SmsReminder> _filteredReminders = [];
  Map<String, int> _stats = {};
  bool _isLoading = true;
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReminders();
    _loadStats();
  }

  Future<void> _loadReminders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reminders = await _databaseService.getAllSmsReminders();
      setState(() {
        _reminders = reminders;
        _filteredReminders = reminders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading reminders: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _smsService.getReminderStats();
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  void _filterReminders() {
    setState(() {
      _filteredReminders = _reminders.where((reminder) {
        // Apply status filter
        bool statusMatch = true;
        if (_selectedFilter != 'all') {
          switch (_selectedFilter) {
            case 'pending':
              statusMatch = reminder.isPending;
              break;
            case 'sent':
              statusMatch = reminder.isSent;
              break;
            case 'failed':
              statusMatch = reminder.isFailed;
              break;
            case 'overdue':
              statusMatch = reminder.isOverdue;
              break;
          }
        }

        // Apply search filter
        bool searchMatch = true;
        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          searchMatch = reminder.patientName.toLowerCase().contains(query) ||
                       reminder.phoneNumber.contains(query) ||
                       reminder.message.toLowerCase().contains(query);
        }

        return statusMatch && searchMatch;
      }).toList();
    });
  }

  Future<void> _cancelReminder(SmsReminder reminder) async {
    try {
      await _smsService.cancelReminder(reminder.id);
      _loadReminders();
      _loadStats();
      _showSuccessSnackBar('Reminder cancelled successfully');
    } catch (e) {
      _showErrorSnackBar('Error cancelling reminder: $e');
    }
  }

  Future<void> _retryReminder(SmsReminder reminder) async {
    try {
      await _smsService.sendImmediateSms(
        patientId: reminder.patientId,
        patientName: reminder.patientName,
        phoneNumber: reminder.phoneNumber,
        message: reminder.message,
        type: reminder.type,
      );
      _loadReminders();
      _loadStats();
      _showSuccessSnackBar('SMS sent successfully');
    } catch (e) {
      _showErrorSnackBar('Error sending SMS: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SMS Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Pending', _stats['pending'] ?? 0, Colors.orange),
                _buildStatItem('Sent', _stats['sent'] ?? 0, Colors.green),
                _buildStatItem('Failed', _stats['failed'] ?? 0, Colors.red),
                _buildStatItem('Cancelled', _stats['cancelled'] ?? 0, Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'pending', 'label': 'Pending'},
      {'key': 'sent', 'label': 'Sent'},
      {'key': 'failed', 'label': 'Failed'},
      {'key': 'overdue', 'label': 'Overdue'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter['key']!;
                });
                _filterReminders();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReminderTile(SmsReminder reminder) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(reminder.status),
          child: Icon(
            _getStatusIcon(reminder.status),
            color: Colors.white,
          ),
        ),
        title: Text(
          reminder.patientName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${reminder.phoneNumber}'),
            Text('Type: ${reminder.typeDisplayName}'),
            Text('Scheduled: ${_formatDateTime(reminder.scheduledTime)}'),
            if (reminder.isOverdue)
              const Text(
                'OVERDUE',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'cancel':
                _cancelReminder(reminder);
                break;
              case 'retry':
                _retryReminder(reminder);
                break;
            }
          },
          itemBuilder: (context) => [
            if (reminder.isPending)
              const PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: [
                    Icon(Icons.cancel, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cancel'),
                  ],
                ),
              ),
            if (reminder.isFailed)
              const PopupMenuItem(
                value: 'retry',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Retry'),
                  ],
                ),
              ),
          ],
        ),
        onTap: () {
          _showReminderDetails(reminder);
        },
      ),
    );
  }

  void _showReminderDetails(SmsReminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reminder.patientName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Status', reminder.statusDisplayName),
            _buildDetailRow('Type', reminder.typeDisplayName),
            _buildDetailRow('Phone', reminder.phoneNumber),
            _buildDetailRow('Scheduled', _formatDateTime(reminder.scheduledTime)),
            _buildDetailRow('Created', _formatDateTime(reminder.createdAt)),
            const SizedBox(height: 12),
            const Text('Message:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(reminder.message),
            if (reminder.errorMessage != null) ...[
              const SizedBox(height: 12),
              const Text('Error:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 4),
              Text(reminder.errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getStatusColor(SmsReminderStatus status) {
    switch (status) {
      case SmsReminderStatus.pending:
        return Colors.orange;
      case SmsReminderStatus.sent:
        return Colors.green;
      case SmsReminderStatus.failed:
        return Colors.red;
      case SmsReminderStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(SmsReminderStatus status) {
    switch (status) {
      case SmsReminderStatus.pending:
        return Icons.schedule;
      case SmsReminderStatus.sent:
        return Icons.check;
      case SmsReminderStatus.failed:
        return Icons.error;
      case SmsReminderStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.smsReminders),
        actions: [
          IconButton(
            onPressed: () {
              _loadReminders();
              _loadStats();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics
          _buildStatsCard(),
          
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search reminders...',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _filterReminders();
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                  ),
                  onChanged: (value) => _filterReminders(),
                ),
                const SizedBox(height: 16),
                _buildFilterChips(),
              ],
            ),
          ),
          
          // Reminders List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredReminders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.message_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No reminders found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredReminders.length,
                        itemBuilder: (context, index) {
                          return _buildReminderTile(_filteredReminders[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SmsReminderScreen(),
            ),
          ).then((_) {
            _loadReminders();
            _loadStats();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
