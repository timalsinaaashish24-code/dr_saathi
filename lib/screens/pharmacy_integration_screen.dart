import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/pharmacy.dart';
import '../models/prescription.dart';
import '../models/patient.dart';
import '../services/pharmacy_service.dart';
import '../services/database_service.dart';
import 'prescription_details.dart';

class PharmacyIntegrationScreen extends StatefulWidget {
  final String prescriptionId;
  final String patientId;

  const PharmacyIntegrationScreen({
    super.key,
    required this.prescriptionId,
    required this.patientId,
  });

  @override
  State<PharmacyIntegrationScreen> createState() => _PharmacyIntegrationScreenState();
}

class _PharmacyIntegrationScreenState extends State<PharmacyIntegrationScreen> {
  final PharmacyService _pharmacyService = PharmacyService();
  final DatabaseService _databaseService = DatabaseService();
  
  List<Pharmacy> _pharmacies = [];
  List<Pharmacy> _filteredPharmacies = [];
  String _selectedProvince = 'All Provinces';
  String _selectedDistrict = 'All Districts';
  String _searchQuery = '';
  bool _isLoading = true;
  
  Prescription? _prescription;
  Patient? _patient;
  
  // Form fields for delivery
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _pharmacyService.initialize();
      
      // Load prescription and patient data
      await _loadPrescription();
      await _loadPatient();
      await _loadPharmacies();
      
      setState(() {
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

  Future<void> _loadPrescription() async {
    final db = await _databaseService.database;
    final result = await db.query(
      'prescriptions',
      where: 'id = ?',
      whereArgs: [widget.prescriptionId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      _prescription = Prescription.fromDatabaseJson(result.first);
      
      // Load medications
      final medications = await _loadMedications();
      _prescription = _prescription!.copyWith(medications: medications);
    }
  }

  Future<List<Medication>> _loadMedications() async {
    final db = await _databaseService.database;
    final result = await db.query(
      'medications',
      where: 'prescription_id = ?',
      whereArgs: [widget.prescriptionId],
    );

    return result.map((json) => Medication.fromDatabaseJson(json)).toList();
  }

  Future<void> _loadPatient() async {
    final db = await _databaseService.database;
    final result = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [widget.patientId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      _patient = Patient.fromDatabaseJson(result.first);
      
      // Pre-fill form with patient data
      _addressController.text = _patient?.address ?? '';
      _phoneController.text = _patient?.phone ?? '';
    }
  }

  Future<void> _loadPharmacies() async {
    final pharmacies = await _pharmacyService.getAllPharmacies();
    setState(() {
      _pharmacies = pharmacies;
      _filteredPharmacies = pharmacies;
    });
  }

  void _filterPharmacies() {
    setState(() {
      _filteredPharmacies = _pharmacies.where((pharmacy) {
        // Province filter
        bool provinceMatch = _selectedProvince == 'All Provinces' || 
                           pharmacy.province == _selectedProvince;
        
        // District filter
        bool districtMatch = _selectedDistrict == 'All Districts' || 
                           pharmacy.district == _selectedDistrict;
        
        // Search query filter
        bool searchMatch = _searchQuery.isEmpty ||
                          pharmacy.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          pharmacy.address.toLowerCase().contains(_searchQuery.toLowerCase());
        
        return provinceMatch && districtMatch && searchMatch;
      }).toList();
    });
  }

  void _updateDistrictsForProvince(String province) {
    setState(() {
      _selectedProvince = province;
      _selectedDistrict = 'All Districts';
    });
    _filterPharmacies();
  }

  Future<void> _sendPrescriptionToPharmacy(Pharmacy pharmacy) async {
    // Validate form data
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }
    
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter phone number')),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await _showConfirmationDialog(pharmacy);
    if (!confirmed) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Sending prescription to pharmacy...'),
          ],
        ),
      ),
    );

    try {
      final deliveryId = await _pharmacyService.sendPrescriptionToPharmacy(
        prescriptionId: widget.prescriptionId,
        pharmacyId: pharmacy.id,
        patientId: widget.patientId,
        deliveryAddress: _addressController.text.trim(),
        patientPhone: _phoneController.text.trim(),
        deliveryInstructions: _instructionsController.text.trim().isNotEmpty 
            ? _instructionsController.text.trim() 
            : null,
      );

      Navigator.of(context).pop(); // Close loading dialog

      if (deliveryId != null) {
        // Success - show confirmation
        await _showSuccessDialog(pharmacy, deliveryId);
        Navigator.of(context).pop(); // Go back to previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send prescription to pharmacy')),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<bool> _showConfirmationDialog(Pharmacy pharmacy) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Prescription Send'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send prescription to:'),
            const SizedBox(height: 8),
            Text(
              pharmacy.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(pharmacy.address),
            const SizedBox(height: 12),
            Text('Delivery Address:'),
            Text(_addressController.text),
            const SizedBox(height: 8),
            Text('Phone: ${_phoneController.text}'),
            if (_instructionsController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Instructions: ${_instructionsController.text}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Send'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _showSuccessDialog(Pharmacy pharmacy, String deliveryId) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Prescription Sent Successfully!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your prescription has been sent to ${pharmacy.name}.'),
            const SizedBox(height: 12),
            Text('Delivery ID: $deliveryId'),
            const SizedBox(height: 12),
            const Text('The pharmacy will contact you shortly with:'),
            const SizedBox(height: 8),
            const Text('• Medicine availability'),
            const Text('• Total cost'),
            const Text('• Delivery timeline'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _callPharmacy(pharmacy.phone),
            child: const Text('Call Pharmacy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _callPharmacy(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone dialer')),
      );
    }
  }

  Widget _buildPharmacyCard(Pharmacy pharmacy) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pharmacy.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pharmacy.address,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pharmacy.district}, ${pharmacy.province}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(pharmacy.rating.toStringAsFixed(1)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: pharmacy.isVerified ? Colors.green[100] : Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        pharmacy.isVerified ? 'Verified' : 'Unverified',
                        style: TextStyle(
                          fontSize: 10,
                          color: pharmacy.isVerified ? Colors.green[800] : Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: pharmacy.services.map((service) => Chip(
                label: Text(service),
                backgroundColor: Colors.blue[50],
                labelStyle: TextStyle(
                  fontSize: 10,
                  color: Colors.blue[800],
                ),
              )).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  pharmacy.operatingHours,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _callPharmacy(pharmacy.phone),
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue[600],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendPrescriptionToPharmacy(pharmacy),
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('Send Prescription'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Delivery Address *',
                hintText: 'Enter full delivery address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                hintText: '+977-...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Delivery Instructions (Optional)',
                hintText: 'Any special instructions for delivery',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Send to Pharmacy'),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send to Pharmacy'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              if (_prescription != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrescriptionDetailsScreen(
                      prescription: _prescription!,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prescription summary
            if (_prescription != null && _patient != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.receipt_long, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Prescription Summary',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Patient: ${_patient!.name}'),
                      Text('Doctor: ${_prescription!.doctorName}'),
                      Text('Date: ${_prescription!.prescriptionDate.toLocal().toString().split(' ')[0]}'),
                      Text('Diagnosis: ${_prescription!.diagnosis}'),
                      const SizedBox(height: 8),
                      Text('Medications: ${_prescription!.medications.length} items'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Delivery form
            _buildDeliveryForm(),
            const SizedBox(height: 16),

            // Filter section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find Pharmacies in Nepal',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Search bar
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search pharmacies...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        _filterPharmacies();
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Province and District filters
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Province',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedProvince,
                            items: ['All Provinces', ...PharmacyService.getAllProvinces()]
                                .map((province) => DropdownMenuItem(
                                      value: province,
                                      child: Text(province),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                _updateDistrictsForProvince(value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'District',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedDistrict,
                            items: [
                              'All Districts',
                              if (_selectedProvince != 'All Provinces')
                                ...PharmacyService.getDistrictsForProvince(_selectedProvince)
                            ]
                                .map((district) => DropdownMenuItem(
                                      value: district,
                                      child: Text(district),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDistrict = value ?? 'All Districts';
                              });
                              _filterPharmacies();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Pharmacies list
            Text(
              'Available Pharmacies (${_filteredPharmacies.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            if (_filteredPharmacies.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.local_pharmacy, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No pharmacies found',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Try adjusting your search or location filters',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...(_filteredPharmacies.map((pharmacy) => _buildPharmacyCard(pharmacy))),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
}
