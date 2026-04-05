import 'package:flutter/material.dart';
import 'package:dr_saathi/generated/l10n/app_localizations.dart';
import '../models/patient.dart';
import '../services/database_service.dart';
import '../services/sync_service.dart';
import 'patient_details.dart';
import 'patient_registration.dart';

class PatientsList extends StatefulWidget {
  const PatientsList({super.key});

  @override
  _PatientsListState createState() => _PatientsListState();
}

class _PatientsListState extends State<PatientsList> {
  final DatabaseService _databaseService = DatabaseService();
  final SyncService _syncService = SyncService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  Map<String, dynamic> _syncStatus = {};

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _loadSyncStatus();
    _startAutoSync();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _syncService.stopAutoSync();
    super.dispose();
  }

  void _startAutoSync() {
    _syncService.startAutoSync();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final patients = await _databaseService.getAllPatients();
      setState(() {
        _patients = patients;
        _filteredPatients = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error loading patients: $e');
    }
  }

  Future<void> _loadSyncStatus() async {
    try {
      final status = await _syncService.getSyncStatus();
      setState(() {
        _syncStatus = status;
      });
    } catch (e) {
      print('Error loading sync status: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Try to sync first if online
      if (_syncStatus['isOnline'] == true) {
        await _syncService.syncPendingChanges();
      }
      
      // Reload patients
      await _loadPatients();
      await _loadSyncStatus();
    } catch (e) {
      _showErrorSnackBar('Error refreshing data: $e');
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _filterPatients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _patients;
      } else {
        _filteredPatients = _patients.where((patient) {
          return patient.fullName.toLowerCase().contains(query.toLowerCase()) ||
                 patient.phoneNumber.contains(query) ||
                 patient.address.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _deletePatient(Patient patient) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmDelete),
        content: Text('Are you sure you want to delete ${patient.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _databaseService.deletePatient(patient.id);
        _loadPatients();
        _loadSyncStatus();
        _showSuccessSnackBar('Patient deleted successfully');
      } catch (e) {
        _showErrorSnackBar('Error deleting patient: $e');
      }
    }
  }

  Future<void> _forceSyncNow() async {
    if (_syncStatus['isOnline'] != true) {
      _showErrorSnackBar('No internet connection available');
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    try {
      final success = await _syncService.forceSyncNow();
      if (success) {
        _showSuccessSnackBar('Sync completed successfully');
        _loadPatients();
        _loadSyncStatus();
      } else {
        _showErrorSnackBar('Sync failed. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('Sync error: $e');
    } finally {
      setState(() {
        _isRefreshing = false;
      });
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

  Widget _buildSyncStatusIndicator() {
    if (_syncStatus.isEmpty) return const SizedBox.shrink();

    final isOnline = _syncStatus['isOnline'] == true;
    final isSyncing = _syncStatus['isSyncing'] == true;
    final unsyncedCount = _syncStatus['unsyncedCount'] ?? 0;
    final queueCount = _syncStatus['queueCount'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOnline ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOnline ? Colors.green.shade300 : Colors.orange.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOnline ? Icons.cloud_done : Icons.cloud_off,
            color: isOnline ? Colors.green.shade700 : Colors.orange.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isOnline ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
                if (unsyncedCount > 0 || queueCount > 0)
                  Text(
                    '${unsyncedCount + queueCount} items pending sync',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOnline ? Colors.green.shade600 : Colors.orange.shade600,
                    ),
                  ),
              ],
            ),
          ),
          if (isSyncing)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (isOnline && (unsyncedCount > 0 || queueCount > 0))
            IconButton(
              onPressed: _forceSyncNow,
              icon: const Icon(Icons.sync),
              iconSize: 20,
              tooltip: 'Sync now',
            ),
        ],
      ),
    );
  }

  Widget _buildPatientTile(Patient patient) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: patient.synced ? Colors.green : Colors.orange,
          child: Text(
            patient.firstName.isNotEmpty ? patient.firstName[0].toUpperCase() : 'P',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          patient.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Age: ${patient.age} • Phone: ${patient.phoneNumber}'),
            if (patient.address.isNotEmpty)
              Text(
                patient.address,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'view':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientDetails(patient: patient),
                  ),
                ).then((_) {
                  _loadPatients();
                  _loadSyncStatus();
                });
                break;
              case 'edit':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientRegistration(patient: patient),
                  ),
                ).then((_) {
                  _loadPatients();
                  _loadSyncStatus();
                });
                break;
              case 'delete':
                _deletePatient(patient);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  const Icon(Icons.visibility),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.view),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.edit),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.delete),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientDetails(patient: patient),
            ),
          ).then((_) {
            _loadPatients();
            _loadSyncStatus();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.patients),
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: _isRefreshing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSyncStatusIndicator(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.searchPatients,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _filterPatients('');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
              onChanged: _filterPatients,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPatients.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? AppLocalizations.of(context)!.noResults
                                  : AppLocalizations.of(context)!.noPatients,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshData,
                        child: ListView.builder(
                          itemCount: _filteredPatients.length,
                          itemBuilder: (context, index) {
                            return _buildPatientTile(_filteredPatients[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PatientRegistration(),
            ),
          ).then((_) {
            _loadPatients();
            _loadSyncStatus();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
