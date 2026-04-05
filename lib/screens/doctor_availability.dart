import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../services/doctor_service.dart';
import 'doctor_detail.dart';

class DoctorAvailabilityScreen extends StatefulWidget {
  final Patient? patient;
  final String? specialization;
  final String? symptoms;

  const DoctorAvailabilityScreen({
    super.key,
    this.patient,
    this.specialization,
    this.symptoms,
  });

  @override
  State<DoctorAvailabilityScreen> createState() => _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  final DoctorService _doctorService = DoctorService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];
  String? _selectedSpecialization;
  DateTime? _selectedDate;
  double? _maxFee;
  double _minRating = 0.0;
  bool _isLoading = true;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _selectedSpecialization = widget.specialization;
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _doctorService.initialize();
      _doctors = _doctorService.doctors;
      _applyFilters();
    } catch (e) {
      print('Error loading doctors: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Doctor> filtered = _doctors;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((doctor) =>
        doctor.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
        doctor.specialization.toLowerCase().contains(_searchController.text.toLowerCase()) ||
        doctor.hospital.toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }

    // Apply specialization filter
    if (_selectedSpecialization != null && _selectedSpecialization!.isNotEmpty) {
      filtered = filtered.where((doctor) =>
        doctor.specialization.toLowerCase() == _selectedSpecialization!.toLowerCase()
      ).toList();
    }

    // Apply date filter
    if (_selectedDate != null) {
      filtered = filtered.where((doctor) {
        return doctor.availabilitySlots.any((slot) =>
          slot.isAvailable &&
          !slot.isBooked &&
          slot.startTime.day == _selectedDate!.day &&
          slot.startTime.month == _selectedDate!.month &&
          slot.startTime.year == _selectedDate!.year
        );
      }).toList();
    }

    // Apply fee filter
    if (_maxFee != null) {
      filtered = filtered.where((doctor) => doctor.consultationFee <= _maxFee!).toList();
    }

    // Apply rating filter
    if (_minRating > 0) {
      filtered = filtered.where((doctor) => doctor.rating >= _minRating).toList();
    }

    setState(() {
      _filteredDoctors = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Doctors'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list : Icons.filter_list_off),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search doctors, specializations, or hospitals...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => _applyFilters(),
            ),
          ),

          // Filter section
          if (_showFilters) _buildFilterSection(),

          // Quick filter chips
          _buildQuickFilters(),

          // Doctors list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDoctors.isEmpty
                    ? _buildEmptyState()
                    : _buildDoctorsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Specialization filter
          DropdownButtonFormField<String>(
            value: _selectedSpecialization,
            decoration: const InputDecoration(
              labelText: 'Specialization',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Specializations')),
              ..._doctorService.getAllSpecializations().map((spec) =>
                DropdownMenuItem(value: spec, child: Text(spec))
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSpecialization = value;
              });
              _applyFilters();
            },
          ),

          const SizedBox(height: 16),

          // Date filter
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Available Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: _selectedDate != null 
                        ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                        : '',
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                      _applyFilters();
                    }
                  },
                ),
              ),
              if (_selectedDate != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _selectedDate = null;
                    });
                    _applyFilters();
                  },
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Fee filter
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Max Fee (\$)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _maxFee = double.tryParse(value);
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Rating filter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Min Rating: ${_minRating.toStringAsFixed(1)}'),
                    Slider(
                      value: _minRating,
                      min: 0.0,
                      max: 5.0,
                      divisions: 10,
                      onChanged: (value) {
                        setState(() {
                          _minRating = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Available Today', () {
            setState(() {
              _selectedDate = DateTime.now();
            });
            _applyFilters();
          }),
          _buildFilterChip('Highly Rated (4.5+)', () {
            setState(() {
              _minRating = 4.5;
            });
            _applyFilters();
          }),
          _buildFilterChip('Under \$200', () {
            setState(() {
              _maxFee = 200.0;
            });
            _applyFilters();
          }),
          _buildFilterChip('Clear Filters', () {
            setState(() {
              _selectedSpecialization = widget.specialization;
              _selectedDate = null;
              _maxFee = null;
              _minRating = 0.0;
              _searchController.clear();
            });
            _applyFilters();
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        onSelected: (_) => onPressed(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_hospital_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No doctors found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search criteria or filters',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    return ListView.builder(
      itemCount: _filteredDoctors.length,
      itemBuilder: (context, index) {
        final doctor = _filteredDoctors[index];
        return _buildDoctorCard(doctor);
      },
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    final availableSlots = _doctorService.getAvailableSlots(doctor.id);
    final todaySlots = _doctorService.getAvailableSlots(doctor.id, date: DateTime.now());
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDetailScreen(
                doctor: doctor,
                patient: widget.patient,
                symptoms: widget.symptoms,
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
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      doctor.name.split(' ').map((n) => n[0]).join(),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          doctor.specialization,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.blue[600],
                          ),
                        ),
                        Text(
                          doctor.hospital,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            doctor.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text(
                        '\$${doctor.consultationFee.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Experience and languages
              Row(
                children: [
                  Icon(Icons.work, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${doctor.experience} years experience',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.language, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    doctor.languages.join(', '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Availability info
              Row(
                children: [
                  Icon(
                    todaySlots.isNotEmpty ? Icons.check_circle : Icons.schedule,
                    size: 16,
                    color: todaySlots.isNotEmpty ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    todaySlots.isNotEmpty
                        ? 'Available today (${todaySlots.length} slots)'
                        : 'Next available: ${_getNextAvailableSlot(doctor)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: todaySlots.isNotEmpty ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorDetailScreen(
                              doctor: doctor,
                              patient: widget.patient,
                              symptoms: widget.symptoms,
                            ),
                          ),
                        );
                      },
                      child: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: availableSlots.isNotEmpty
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoctorDetailScreen(
                                    doctor: doctor,
                                    patient: widget.patient,
                                    symptoms: widget.symptoms,
                                    showBooking: true,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: const Text('Book Now'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getNextAvailableSlot(Doctor doctor) {
    final availableSlots = doctor.availabilitySlots
        .where((slot) => slot.isAvailable && !slot.isBooked)
        .toList();
    
    if (availableSlots.isEmpty) {
      return 'No slots available';
    }
    
    availableSlots.sort((a, b) => a.startTime.compareTo(b.startTime));
    final nextSlot = availableSlots.first;
    
    final now = DateTime.now();
    final difference = nextSlot.startTime.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today at ${DateFormat('h:mm a').format(nextSlot.startTime)}';
    } else if (difference == 1) {
      return 'Tomorrow at ${DateFormat('h:mm a').format(nextSlot.startTime)}';
    } else {
      return DateFormat('MMM dd, h:mm a').format(nextSlot.startTime);
    }
  }
}
