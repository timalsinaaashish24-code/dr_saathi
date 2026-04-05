import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../services/doctor_service.dart';
import 'appointment_confirmation.dart';

class DoctorDetailScreen extends StatefulWidget {
  final Doctor doctor;
  final Patient? patient;
  final String? symptoms;
  final bool showBooking;

  const DoctorDetailScreen({
    super.key,
    required this.doctor,
    this.patient,
    this.symptoms,
    this.showBooking = false,
  });

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> with SingleTickerProviderStateMixin {
  final DoctorService _doctorService = DoctorService();
  late TabController _tabController;
  
  DateTime _selectedDate = DateTime.now();
  AvailabilitySlot? _selectedSlot;
  ConsultationType _selectedConsultationType = ConsultationType.inPerson;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _symptomsController.text = widget.symptoms ?? '';
    
    if (widget.showBooking) {
      _tabController.animateTo(2); // Navigate to booking tab
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doctor.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profile', icon: Icon(Icons.person)),
            Tab(text: 'Availability', icon: Icon(Icons.schedule)),
            Tab(text: 'Book', icon: Icon(Icons.book_online)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          _buildAvailabilityTab(),
          _buildBookingTab(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.blue[50],
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    widget.doctor.name.split(' ').map((n) => n[0]).join(),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.doctor.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  widget.doctor.specialization,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.blue[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      widget.doctor.rating.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${widget.doctor.experience} years experience',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Details section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // About section
                _buildSectionHeader('About'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.doctor.about,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Contact information
                _buildSectionHeader('Contact Information'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildContactItem(Icons.local_hospital, 'Hospital', widget.doctor.hospital),
                        _buildContactItem(Icons.location_on, 'Address', widget.doctor.address),
                        _buildContactItem(Icons.phone, 'Phone', widget.doctor.phone, isPhone: true),
                        _buildContactItem(Icons.email, 'Email', widget.doctor.email, isEmail: true),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Qualifications
                _buildSectionHeader('Qualifications'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.doctor.qualifications.map((qualification) =>
                        Chip(
                          label: Text(qualification),
                          backgroundColor: Colors.blue[100],
                        ),
                      ).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Languages
                _buildSectionHeader('Languages'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.doctor.languages.map((language) =>
                        Chip(
                          label: Text(language),
                          backgroundColor: Colors.green[100],
                        ),
                      ).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Consultation fee
                _buildSectionHeader('Consultation Fee'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_money, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          '\$${widget.doctor.consultationFee.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.green[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const Text('per consultation'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityTab() {
    return Column(
      children: [
        // Date selector
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Date',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 14, // Next 14 days
                  itemBuilder: (context, index) {
                    final date = DateTime.now().add(Duration(days: index));
                    final isSelected = _selectedDate.day == date.day &&
                        _selectedDate.month == date.month &&
                        _selectedDate.year == date.year;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = date;
                          _selectedSlot = null;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('EEE').format(date),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM dd').format(date),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Available slots
        Expanded(
          child: _buildAvailableSlots(),
        ),
      ],
    );
  }

  Widget _buildAvailableSlots() {
    final slots = _doctorService.getAvailableSlots(widget.doctor.id, date: _selectedDate);
    
    if (slots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No slots available',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different date',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Group slots by time period
    final morningSlots = slots.where((slot) => slot.startTime.hour < 12).toList();
    final afternoonSlots = slots.where((slot) => slot.startTime.hour >= 12 && slot.startTime.hour < 17).toList();
    final eveningSlots = slots.where((slot) => slot.startTime.hour >= 17).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (morningSlots.isNotEmpty) _buildTimeSlotSection('Morning', morningSlots),
            if (afternoonSlots.isNotEmpty) _buildTimeSlotSection('Afternoon', afternoonSlots),
            if (eveningSlots.isNotEmpty) _buildTimeSlotSection('Evening', eveningSlots),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotSection(String title, List<AvailabilitySlot> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) => _buildTimeSlotChip(slot)).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTimeSlotChip(AvailabilitySlot slot) {
    final isSelected = _selectedSlot?.id == slot.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSlot = slot;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Text(
          DateFormat('h:mm a').format(slot.startTime),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected slot info
            if (_selectedSlot != null)
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Appointment',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(DateFormat('EEEE, MMM dd, yyyy').format(_selectedSlot!.startTime)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16),
                          const SizedBox(width: 8),
                          Text('${DateFormat('h:mm a').format(_selectedSlot!.startTime)} - ${DateFormat('h:mm a').format(_selectedSlot!.endTime)}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.attach_money, size: 16),
                          const SizedBox(width: 8),
                          Text('\$${widget.doctor.consultationFee.toStringAsFixed(0)}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Consultation type
            _buildSectionHeader('Consultation Type'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    RadioListTile<ConsultationType>(
                      title: const Text('In-Person'),
                      subtitle: const Text('Visit the doctor\'s clinic'),
                      value: ConsultationType.inPerson,
                      groupValue: _selectedConsultationType,
                      onChanged: (value) {
                        setState(() {
                          _selectedConsultationType = value!;
                        });
                      },
                    ),
                    RadioListTile<ConsultationType>(
                      title: const Text('Telehealth'),
                      subtitle: const Text('Video consultation from home'),
                      value: ConsultationType.telehealth,
                      groupValue: _selectedConsultationType,
                      onChanged: (value) {
                        setState(() {
                          _selectedConsultationType = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Symptoms
            _buildSectionHeader('Symptoms/Reason for Visit'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _symptomsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Please describe your symptoms or reason for consultation...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Additional notes
            _buildSectionHeader('Additional Notes (Optional)'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Any additional information for the doctor...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Book appointment button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedSlot != null && widget.patient != null
                    ? _bookAppointment
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _selectedSlot == null
                      ? 'Select a time slot'
                      : widget.patient == null
                          ? 'Patient information required'
                          : 'Book Appointment',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            if (widget.patient == null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Patient information is required to book an appointment.',
                  style: TextStyle(color: Colors.red[600]),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value, {bool isPhone = false, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (isPhone) {
                      _launchPhone(value);
                    } else if (isEmail) {
                      _launchEmail(value);
                    }
                  },
                  child: Text(
                    value,
                    style: TextStyle(
                      color: (isPhone || isEmail) ? Colors.blue : null,
                      decoration: (isPhone || isEmail) ? TextDecoration.underline : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedSlot == null || widget.patient == null) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final appointment = await _doctorService.bookAppointment(
        patientId: widget.patient!.id,
        doctorId: widget.doctor.id,
        slotId: _selectedSlot!.id,
        consultationType: _selectedConsultationType,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        symptoms: _symptomsController.text.trim().isEmpty ? null : _symptomsController.text.trim(),
      );

      Navigator.pop(context); // Close loading dialog

      if (appointment != null) {
        // Navigate to confirmation screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentConfirmationScreen(
              doctor: widget.doctor,
              selectedDate: _selectedSlot!.startTime,
              selectedTime: DateFormat('h:mm a').format(_selectedSlot!.startTime),
            ),
          ),
        );
      } else {
        _showErrorDialog('Failed to book appointment. Please try again.');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorDialog('An error occurred while booking the appointment.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
