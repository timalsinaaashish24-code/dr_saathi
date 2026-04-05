import 'package:flutter/material.dart';
import '../models/prescription.dart';
import '../models/patient.dart';
import '../models/pharmacy.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import '../services/pharmacy_service.dart';
import 'prescription_form.dart';
import 'prescription_details.dart';

class PrescriptionsListScreen extends StatefulWidget {
  final Patient? patient;

  const PrescriptionsListScreen({super.key, this.patient});

  @override
  State<PrescriptionsListScreen> createState() => _PrescriptionsListScreenState();
}

class _PrescriptionsListScreenState extends State<PrescriptionsListScreen> with TickerProviderStateMixin {
  final _databaseService = DatabaseService();
  final _pharmacyService = PharmacyService();
  final _searchController = TextEditingController();
  late TabController _tabController;
  
  List<Prescription> _prescriptions = [];
  List<Prescription> _filteredPrescriptions = [];
  List<Pharmacy> _pharmacies = [];
  List<PrescriptionDelivery> _deliveries = [];
  bool _isLoading = true;
  bool _isLoadingPharmacies = false;
  bool _isLoadingDeliveries = false;
  String _selectedStatus = 'all';
  String _searchQuery = '';
  final String _selectedProvince = 'all';
  final String _selectedDistrict = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPrescriptions();
    _loadPharmacies();
    if (widget.patient != null) {
      _loadDeliveries();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPrescriptions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Prescription> prescriptions;
      if (widget.patient != null) {
        prescriptions = await _databaseService.getPrescriptionsByPatientId(widget.patient!.id);
      } else {
        prescriptions = await _databaseService.getAllPrescriptions();
      }

      setState(() {
        _prescriptions = prescriptions;
        _filteredPrescriptions = prescriptions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading prescriptions: $e')),
      );
    }
  }

  void _filterPrescriptions() {
    setState(() {
      _filteredPrescriptions = _prescriptions.where((prescription) {
        final matchesSearch = _searchQuery.isEmpty ||
            prescription.diagnosis.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            prescription.notes.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            prescription.medications.any((med) => 
                med.name.toLowerCase().contains(_searchQuery.toLowerCase()));

        final matchesStatus = _selectedStatus == 'all' || 
            prescription.status == _selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterPrescriptions();
  }

  void _onStatusFilterChanged(String status) {
    setState(() {
      _selectedStatus = status;
    });
    _filterPrescriptions();
  }

  Future<void> _createPrescription() async {
    if (widget.patient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient first')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescriptionFormScreen(patient: widget.patient!),
      ),
    );

    if (result == true) {
      _loadPrescriptions();
    }
  }

  Future<void> _editPrescription(Prescription prescription) async {
    final patient = await _databaseService.getPatientById(prescription.patientId);
    if (patient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient not found')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescriptionFormScreen(
          patient: patient,
          existingPrescription: prescription,
        ),
      ),
    );

    if (result == true) {
      _loadPrescriptions();
    }
  }

  Future<void> _deletePrescription(Prescription prescription) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prescription'),
        content: const Text('Are you sure you want to delete this prescription?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _databaseService.deletePrescription(prescription.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription deleted successfully')),
        );
        _loadPrescriptions();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting prescription: $e')),
        );
      }
    }
  }

  Future<void> _printPrescription(Prescription prescription) async {
    try {
      final patient = await _databaseService.getPatientById(prescription.patientId);
      if (patient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient not found')),
        );
        return;
      }

      await PdfService.printPrescription(prescription, patient);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error printing prescription: $e')),
      );
    }
  }

  Future<void> _sharePrescription(Prescription prescription) async {
    try {
      final patient = await _databaseService.getPatientById(prescription.patientId);
      if (patient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient not found')),
        );
        return;
      }

      await PdfService.sharePrescription(prescription, patient);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing prescription: $e')),
      );
    }
  }

  Future<void> _loadPharmacies() async {
    setState(() {
      _isLoadingPharmacies = true;
    });

    try {
      final pharmacies = await _pharmacyService.getAllPharmacies();
      setState(() {
        _pharmacies = pharmacies;
        _isLoadingPharmacies = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPharmacies = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading pharmacies: $e')),
      );
    }
  }

  Future<void> _loadDeliveries() async {
    if (widget.patient == null) return;
    
    setState(() {
      _isLoadingDeliveries = true;
    });

    try {
      final deliveries = await _pharmacyService.getPatientDeliveries(widget.patient!.id);
      setState(() {
        _deliveries = deliveries;
        _isLoadingDeliveries = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDeliveries = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading deliveries: $e')),
      );
    }
  }

  Future<void> _sendToPharmacy(Prescription prescription) async {
    if (widget.patient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient information not available')),
      );
      return;
    }

    // Show pharmacy selection dialog
    final selectedPharmacy = await _showPharmacySelectionDialog();
    if (selectedPharmacy == null) return;

    // Show delivery address dialog
    final deliveryInfo = await _showDeliveryAddressDialog();
    if (deliveryInfo == null) return;

    try {
      final deliveryId = await _pharmacyService.sendPrescriptionToPharmacy(
        prescriptionId: prescription.id!.toString(),
        pharmacyId: selectedPharmacy.id,
        patientId: widget.patient!.id,
        deliveryAddress: deliveryInfo['address']!,
        patientPhone: deliveryInfo['phone']!,
        deliveryInstructions: deliveryInfo['instructions'],
      );

      if (deliveryId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription sent to pharmacy successfully!')),
        );
        _loadDeliveries();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send prescription to pharmacy')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending to pharmacy: $e')),
      );
    }
  }

  Future<Pharmacy?> _showPharmacySelectionDialog() async {
    return showDialog<Pharmacy>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Pharmacy'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _isLoadingPharmacies
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _pharmacies.length,
                  itemBuilder: (context, index) {
                    final pharmacy = _pharmacies[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          pharmacy.type == PharmacyType.hospital
                              ? Icons.local_hospital
                              : Icons.local_pharmacy,
                        ),
                      ),
                      title: Text(pharmacy.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pharmacy.address),
                          Text('Rating: ${pharmacy.rating}/5.0'),
                          Text('Hours: ${pharmacy.operatingHours}'),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () => Navigator.pop(context, pharmacy),
                    );
                  },
                ),
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

  Future<Map<String, String>?> _showDeliveryAddressDialog() async {
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final instructionsController = TextEditingController();

    // Pre-fill with patient information if available
    if (widget.patient != null) {
      addressController.text = widget.patient!.address;
      phoneController.text = widget.patient!.phoneNumber;
    }

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delivery Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: instructionsController,
              decoration: const InputDecoration(
                labelText: 'Delivery Instructions (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (addressController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                Navigator.pop(context, {
                  'address': addressController.text,
                  'phone': phoneController.text,
                  'instructions': instructionsController.text,
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in required fields')),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient != null 
            ? 'Prescriptions for ${widget.patient!.firstName}'
            : 'All Prescriptions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPrescriptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search prescriptions',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Status: '),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(value: 'all', child: Text('All')),
                          const DropdownMenuItem(value: 'active', child: Text('Active')),
                          const DropdownMenuItem(value: 'completed', child: Text('Completed')),
                          const DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _onStatusFilterChanged(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Prescriptions List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPrescriptions.isEmpty
                    ? const Center(
                        child: Text('No prescriptions found'),
                      )
                    : ListView.builder(
                        itemCount: _filteredPrescriptions.length,
                        itemBuilder: (context, index) {
                          final prescription = _filteredPrescriptions[index];
                          return _buildPrescriptionCard(prescription);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: widget.patient != null
          ? FloatingActionButton(
              onPressed: _createPrescription,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildPrescriptionCard(Prescription prescription) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrescriptionDetailsScreen(
                prescriptionId: prescription.id!,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Prescription #${prescription.id}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _buildStatusChip(prescription.statusDisplay),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${prescription.prescriptionDate.toString().split(' ')[0]}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Diagnosis: ${prescription.diagnosis}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Doctor: ${prescription.doctorName}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Medications: ${prescription.medications.length} item(s)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (prescription.medications.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  prescription.medications.map((m) => m.name).join(', '),
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              // First row of buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    onPressed: () => _editPrescription(prescription),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.print),
                    label: const Text('Print'),
                    onPressed: () => _printPrescription(prescription),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    onPressed: () => _sharePrescription(prescription),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Second row of buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.local_pharmacy, color: Colors.blue),
                    label: const Text('Send to Pharmacy', style: TextStyle(color: Colors.blue)),
                    onPressed: () => _sendToPharmacy(prescription),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    onPressed: () => _deletePrescription(prescription),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'active':
        color = Colors.green;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }
}
