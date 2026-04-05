import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/nmc_admin_service.dart';

class NMCRegistryManagementScreen extends StatefulWidget {
  const NMCRegistryManagementScreen({super.key});

  @override
  State<NMCRegistryManagementScreen> createState() => _NMCRegistryManagementScreenState();
}

class _NMCRegistryManagementScreenState extends State<NMCRegistryManagementScreen> {
  final NMCAdminService _nmcService = NMCAdminService();
  List<Map<String, dynamic>> _nmcRecords = [];
  Map<String, int> _stats = {'total': 0, 'active': 0, 'expired': 0, 'suspended': 0};
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await _nmcService.getNMCStats();
      final records = await _nmcService.getAllVerifiedNMCs();
      
      setState(() {
        _stats = stats;
        _nmcRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _searchRecords(String query) async {
    if (query.isEmpty) {
      _loadData();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _nmcService.searchNMCRecords(query);
      setState(() {
        _nmcRecords = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddRecordDialog() {
    final formKey = GlobalKey<FormState>();
    final nmcController = TextEditingController();
    final nameController = TextEditingController();
    final specializationController = TextEditingController();
    DateTime? registrationDate;
    DateTime? expiryDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add NMC Record'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nmcController,
                  decoration: const InputDecoration(
                    labelText: 'NMC Number *',
                    hintText: 'e.g., NMC12345',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Doctor Name *',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: specializationController,
                  decoration: const InputDecoration(
                    labelText: 'Specialization',
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(registrationDate == null
                      ? 'Registration Date'
                      : 'Registration: ${DateFormat('yyyy-MM-dd').format(registrationDate!)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        registrationDate = date;
                      });
                    }
                  },
                ),
                ListTile(
                  title: Text(expiryDate == null
                      ? 'Expiry Date'
                      : 'Expiry: ${DateFormat('yyyy-MM-dd').format(expiryDate!)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 3650)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2050),
                    );
                    if (date != null) {
                      setState(() {
                        expiryDate = date;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final result = await _nmcService.addOrUpdateNMCRecord(
                  nmcNumber: nmcController.text,
                  doctorName: nameController.text,
                  specialization: specializationController.text.isEmpty
                      ? null
                      : specializationController.text,
                  registrationDate: registrationDate?.toIso8601String(),
                  expiryDate: expiryDate?.toIso8601String(),
                );

                if (mounted) {
                  Navigator.pop(context);
                  if (result > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Record added successfully')),
                    );
                    _loadData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add record')),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showBulkImportDialog() {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Import NMC Records'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste records in format (one per line):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'NMC_NUMBER|DOCTOR_NAME|SPECIALIZATION|REG_DATE|EXPIRY_DATE',
                style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 4),
              const Text(
                'Example:\nNMC12345|Dr. Ram Sharma|Cardiology|2020-01-15|2030-01-15',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                maxLines: 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Paste records here...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = textController.text.trim();
              if (text.isEmpty) {
                Navigator.pop(context);
                return;
              }

              final lines = text.split('\n');
              final records = <Map<String, dynamic>>[];

              for (var line in lines) {
                if (line.trim().isEmpty) continue;
                final parts = line.split('|');
                if (parts.length >= 2) {
                  records.add({
                    'nmc_number': parts[0].trim(),
                    'doctor_name': parts[1].trim(),
                    'specialization': parts.length > 2 ? parts[2].trim() : null,
                    'registration_date': parts.length > 3 ? parts[3].trim() : null,
                    'expiry_date': parts.length > 4 ? parts[4].trim() : null,
                    'status': 'active',
                  });
                }
              }

              if (records.isEmpty) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No valid records found')),
                  );
                }
                Navigator.pop(context);
                return;
              }

              final count = await _nmcService.bulkImportNMCRecords(records);
              
              if (mounted) {
                Navigator.pop(context);
                if (count > 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Successfully imported $count records')),
                  );
                  _loadData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Import failed')),
                  );
                }
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _updateStatus(String nmcNumber, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Active'),
              leading: Radio<String>(
                value: 'active',
                groupValue: currentStatus,
                onChanged: (value) async {
                  if (value != null) {
                    await _nmcService.updateNMCStatus(nmcNumber, value);
                    if (mounted) {
                      Navigator.pop(context);
                      _loadData();
                    }
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Expired'),
              leading: Radio<String>(
                value: 'expired',
                groupValue: currentStatus,
                onChanged: (value) async {
                  if (value != null) {
                    await _nmcService.updateNMCStatus(nmcNumber, value);
                    if (mounted) {
                      Navigator.pop(context);
                      _loadData();
                    }
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Suspended'),
              leading: Radio<String>(
                value: 'suspended',
                groupValue: currentStatus,
                onChanged: (value) async {
                  if (value != null) {
                    await _nmcService.updateNMCStatus(nmcNumber, value);
                    if (mounted) {
                      Navigator.pop(context);
                      _loadData();
                    }
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NMC Registry Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    _stats['total'] ?? 0,
                    Colors.blue,
                    Icons.list,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Active',
                    _stats['active'] ?? 0,
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Expired',
                    _stats['expired'] ?? 0,
                    Colors.orange,
                    Icons.schedule,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Suspended',
                    _stats['suspended'] ?? 0,
                    Colors.red,
                    Icons.block,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by NMC number or doctor name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _searchRecords(value);
              },
            ),
          ),

          const SizedBox(height: 16),

          // Records List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _nmcRecords.isEmpty
                    ? const Center(child: Text('No records found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _nmcRecords.length,
                        itemBuilder: (context, index) {
                          final record = _nmcRecords[index];
                          return _buildRecordCard(record);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: _showBulkImportDialog,
            icon: const Icon(Icons.upload_file),
            label: const Text('Bulk Import'),
            heroTag: 'bulk_import',
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: _showAddRecordDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Record'),
            heroTag: 'add_record',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    final status = record['status'] as String;
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'active':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'expired':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'suspended':
        statusColor = Colors.red;
        statusIcon = Icons.block;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(
          record['doctor_name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'NMC: ${record['nmc_number']} • ${record['specialization'] ?? 'No specialization'}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('NMC Number', record['nmc_number'],
                    copyable: true),
                _buildDetailRow('Doctor Name', record['doctor_name']),
                _buildDetailRow('Specialization', record['specialization']),
                _buildDetailRow('Registration Date', record['registration_date']),
                _buildDetailRow('Expiry Date', record['expiry_date']),
                _buildDetailRow('Status', status.toUpperCase()),
                _buildDetailRow('Data Source', record['data_source']),
                _buildDetailRow('Last Updated', record['last_updated']),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _updateStatus(
                        record['nmc_number'],
                        status,
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text('Update Status'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value?.toString() ?? 'N/A',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                if (copyable && value != null)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: value.toString()));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
