import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/admin_models.dart';
import '../services/admin_management_service.dart';

class AppointmentManagementScreen extends StatefulWidget {
  const AppointmentManagementScreen({super.key});
  @override
  State<AppointmentManagementScreen> createState() => _AppointmentManagementScreenState();
}

class _AppointmentManagementScreenState extends State<AppointmentManagementScreen> {
  final _service = AdminManagementService();
  List<AppointmentRecord> _appointments = [];
  bool _isLoading = true;
  String _filter = 'All';

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { setState(() => _isLoading = true); _appointments = await _service.getAppointments(); setState(() => _isLoading = false); }

  List<AppointmentRecord> get _filtered => _filter == 'All' ? _appointments : _appointments.where((a) => a.status.name == _filter.toLowerCase()).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointments'), backgroundColor: Colors.indigo[700]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(children: [
        SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(12), child: Row(
          children: ['All', 'Scheduled', 'InProgress', 'Completed', 'Cancelled', 'Disputed'].map((f) => Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(label: Text(f), selected: _filter == f, onSelected: (_) => setState(() => _filter = f)))).toList(),
        )),
        Expanded(child: RefreshIndicator(onRefresh: _load, child: ListView.builder(itemCount: _filtered.length, itemBuilder: (ctx, i) => _card(_filtered[i])))),
      ]),
    );
  }

  Widget _card(AppointmentRecord a) {
    final color = _statusColor(a.status);
    final df = DateFormat('MMM dd, HH:mm');
    return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: ListTile(
      leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(_typeIcon(a.type), color: color, size: 20)),
      title: Text('${a.patientName} → ${a.doctorName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${a.type} • NPR ${a.fee.toInt()} • ${df.format(a.scheduledAt)}', style: const TextStyle(fontSize: 12)),
        if (a.disputeReason != null) Text('Dispute: ${a.disputeReason}', style: const TextStyle(fontSize: 11, color: Colors.red)),
      ]),
      trailing: Chip(label: Text(a.status.name, style: TextStyle(fontSize: 9, color: color)), backgroundColor: color.withValues(alpha: 0.1), side: BorderSide.none, padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
      onTap: () {
        if (a.status == AppointmentStatus.scheduled) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cancel/Reschedule ${a.id} — mock action')));
        } else if (a.status == AppointmentStatus.disputed) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Resolve dispute ${a.id} — mock action')));
        }
      },
    ));
  }

  IconData _typeIcon(String t) { switch (t) { case 'Video': return Icons.videocam; case 'Audio': return Icons.call; default: return Icons.chat; } }
  Color _statusColor(AppointmentStatus s) { switch (s) { case AppointmentStatus.scheduled: return Colors.blue; case AppointmentStatus.inProgress: return Colors.orange; case AppointmentStatus.completed: return Colors.green; case AppointmentStatus.cancelled: return Colors.grey; case AppointmentStatus.disputed: return Colors.red; } }
}
