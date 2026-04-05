import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../services/refund_service.dart';
import '../services/payment_hold_service.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AppointmentService _appointmentService = AppointmentService();
  
  String _doctorId = '';
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  
  List<Appointment> _appointments = [];
  List<Map<String, dynamic>> _patients = [];
  Map<DateTime, DoctorAvailability> _availabilityMap = {};
  Map<String, int> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _doctorId = prefs.getString('doctor_id') ?? 'DOCTOR_001';
      
      // Load appointments
      final appointments = await _appointmentService.getAppointmentsByDoctor(_doctorId);
      
      // Load patients
      final patients = await _appointmentService.getPatientsList(_doctorId);
      
      // Load stats
      final stats = await _appointmentService.getAppointmentStats(_doctorId);
      
      // Load availability for current month
      final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
      final availabilities = await _appointmentService.getAvailabilityRange(
        _doctorId,
        startOfMonth,
        endOfMonth,
      );
      
      final availMap = <DateTime, DoctorAvailability>{};
      for (var avail in availabilities) {
        availMap[DateTime(avail.date.year, avail.date.month, avail.date.day)] = avail;
      }
      
      setState(() {
        _appointments = appointments;
        _patients = patients;
        _stats = stats;
        _availabilityMap = availMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _setAvailability(DateTime date, String status) async {
    try {
      final availability = DoctorAvailability(
        doctorId: _doctorId,
        date: date,
        status: status,
        startTime: status == 'available' ? '09:00' : null,
        endTime: status == 'available' ? '17:00' : null,
        createdAt: DateTime.now(),
      );
      
      await _appointmentService.setAvailability(availability);
      
      setState(() {
        _availabilityMap[DateTime(date.year, date.month, date.day)] = availability;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Availability set to $status')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting availability: $e')),
        );
      }
    }
  }

  void _showAvailabilityDialog(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final currentAvailability = _availabilityMap[dateKey];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Availability\n${DateFormat('MMM dd, yyyy').format(date)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentAvailability != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Current: ${currentAvailability.status}',
                  style: TextStyle(
                    color: _getStatusColor(currentAvailability.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green[700]),
              title: const Text('Available'),
              onTap: () {
                Navigator.pop(context);
                _setAvailability(date, 'available');
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.red[700]),
              title: const Text('Unavailable'),
              onTap: () {
                Navigator.pop(context);
                _setAvailability(date, 'unavailable');
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule, color: Colors.orange[700]),
              title: const Text('Busy'),
              onTap: () {
                Navigator.pop(context);
                _setAvailability(date, 'busy');
              },
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'unavailable':
        return Colors.red;
      case 'busy':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: Colors.teal[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month), text: 'Calendar'),
            Tab(icon: Icon(Icons.event), text: 'Appointments'),
            Tab(icon: Icon(Icons.people), text: 'My Patients'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCalendarTab(),
                _buildAppointmentsTab(),
                _buildPatientsTab(),
              ],
            ),
    );
  }

  Widget _buildCalendarTab() {
    return Column(
      children: [
        // Statistics Cards
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.teal[50],
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Today',
                  _stats['today']?.toString() ?? '0',
                  Icons.today,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Scheduled',
                  _stats['scheduled']?.toString() ?? '0',
                  Icons.schedule,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Completed',
                  _stats['completed']?.toString() ?? '0',
                  Icons.check_circle,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ),
        
        // Calendar
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _showAvailabilityDialog(selectedDay);
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.teal[300],
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.teal[700],
              shape: BoxShape.circle,
            ),
            weekendTextStyle: const TextStyle(color: Colors.red),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              final dateKey = DateTime(day.year, day.month, day.day);
              final availability = _availabilityMap[dateKey];
              
              if (availability != null) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(availability.status).withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getStatusColor(availability.status),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: _getStatusColor(availability.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem('Available', Colors.green),
              _buildLegendItem('Unavailable', Colors.red),
              _buildLegendItem('Busy', Colors.orange),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Today's Appointments
        Expanded(
          child: _buildDayAppointments(_selectedDay),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDayAppointments(DateTime day) {
    final dayAppointments = _appointments.where((apt) {
      final aptDate = DateTime(apt.appointmentDate.year, apt.appointmentDate.month, apt.appointmentDate.day);
      final selectedDate = DateTime(day.year, day.month, day.day);
      return aptDate == selectedDate;
    }).toList();
    
    if (dayAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No appointments for ${DateFormat('MMM dd, yyyy').format(day)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dayAppointments.length,
      itemBuilder: (context, index) {
        final appointment = dayAppointments[index];
        return _buildAppointmentCard(appointment);
      },
    );
  }

  Widget _buildAppointmentsTab() {
    if (_appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No appointments yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointment = _appointments[index];
        return _buildAppointmentCard(appointment);
      },
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    Color statusColor;
    IconData statusIcon;
    
    switch (appointment.status) {
      case 'scheduled':
        statusColor = Colors.blue;
        statusIcon = Icons.schedule;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'no_show':
        statusColor = Colors.orange;
        statusIcon = Icons.warning;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.event;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal[100],
                  child: Icon(Icons.person, color: Colors.teal[700]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        appointment.patientPhone,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        appointment.status,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM dd, yyyy').format(appointment.appointmentDate),
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  appointment.timeSlot,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            if (appointment.chiefComplaint != null) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.chiefComplaint!,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (appointment.status == 'scheduled') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await _appointmentService.updateAppointmentStatus(
                          appointment.id!,
                          'completed',
                        );
                        _loadData();
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Complete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showCancelWithRefundDialog(appointment),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancel & Refund'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelWithRefundDialog(Appointment appointment) {
    String? selectedReason;
    final reasonController = TextEditingController();
    bool isProcessing = false;

    final reasons = [
      'Doctor unavailable',
      'Patient requested cancellation',
      'Schedule conflict',
      'Emergency situation',
      'Technical issues',
      'Other (specify below)',
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cancel, color: Colors.red),
              SizedBox(width: 8),
              Text('Cancel Appointment'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${DateFormat('MMM dd, yyyy').format(appointment.appointmentDate)} • ${appointment.timeSlot}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Reason dropdown
                const Text('Reason for cancellation *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  hint: const Text('Select a reason'),
                  items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 14)))).toList(),
                  onChanged: (v) => setDialogState(() => selectedReason = v),
                ),

                // Additional details
                if (selectedReason == 'Other (specify below)') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Please specify the reason...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Refund info — check if on 24-hour hold
                FutureBuilder<bool>(
                  future: () async {
                    final svc = PaymentHoldService();
                    await svc.initialize();
                    return await svc.isPaymentOnHold(appointment.id!);
                  }(),
                  builder: (ctx, snap) {
                    final onHold = snap.data ?? false;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: onHold ? Colors.blue[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: onHold ? Colors.blue[300]! : Colors.green[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(onHold ? Icons.flash_on : Icons.account_balance, color: onHold ? Colors.blue : Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  onHold ? 'Instant Refund (24hr Hold Active)' : 'Bank Transfer Refund',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: onHold ? Colors.blue : Colors.green, fontSize: 13),
                                ),
                                Text(
                                  onHold
                                      ? 'Payment is still on hold. Refund will be processed instantly — no waiting.'
                                      : 'Payment has been released. Full refund will be transferred to the patient\'s bank account.',
                                  style: TextStyle(fontSize: 12, color: onHold ? Colors.blue : Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                if (isProcessing) ...[
                  const SizedBox(height: 16),
                  const Center(child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Processing refund to bank...', style: TextStyle(fontSize: 13, color: Colors.blue)),
                    ],
                  )),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isProcessing ? null : () => Navigator.pop(ctx),
              child: const Text('Keep Appointment'),
            ),
            ElevatedButton(
              onPressed: isProcessing || selectedReason == null
                  ? null
                  : () async {
                      final reason = selectedReason == 'Other (specify below)'
                          ? reasonController.text.trim()
                          : selectedReason!;

                      if (reason.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please provide a reason')),
                        );
                        return;
                      }

                      setDialogState(() => isProcessing = true);

                      // Cancel appointment and process refund to bank
                      final result = await _appointmentService.cancelAppointmentWithRefund(
                        appointmentId: appointment.id!,
                        cancellationReason: reason,
                        cancelledBy: _doctorId,
                        refundAmount: 500, // TODO: Get actual fee from appointment
                      );

                      setDialogState(() => isProcessing = false);

                      if (ctx.mounted) Navigator.pop(ctx);

                      if (result.success) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(
                                'Appointment cancelled. Refund sent to ${appointment.patientName}\'s bank account. TXN: ${result.transactionId}',
                              ),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.orange,
                              content: Text(
                                'Appointment cancelled but refund failed: ${result.errorMessage}. Admin will process manually.',
                              ),
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      }

                      _loadData();
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Cancel & Refund'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientsTab() {
    if (_patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No patients yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _patients.length,
      itemBuilder: (context, index) {
        final patient = _patients[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.teal[100],
              child: Icon(Icons.person, size: 30, color: Colors.teal[700]),
            ),
            title: Text(
              patient['patient_name'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(patient['patient_phone']),
                  ],
                ),
                if (patient['patient_email'] != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.email, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          patient['patient_email'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${patient['visit_count']} visits',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Last: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(patient['last_visit']))}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to patient details
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Patient details coming soon')),
              );
            },
          ),
        );
      },
    );
  }
}
