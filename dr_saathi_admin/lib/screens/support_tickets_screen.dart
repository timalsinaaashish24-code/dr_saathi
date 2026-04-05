import 'package:flutter/material.dart';
import '../models/admin_models.dart';
import '../services/admin_management_service.dart';

class SupportTicketsScreen extends StatefulWidget {
  const SupportTicketsScreen({super.key});
  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  final _service = AdminManagementService();
  List<SupportTicket> _tickets = [];
  bool _isLoading = true;
  String _filter = 'All';

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { setState(() => _isLoading = true); _tickets = await _service.getSupportTickets(); setState(() => _isLoading = false); }

  List<SupportTicket> get _filtered => _filter == 'All' ? _tickets : _tickets.where((t) => t.status.name == _filter.toLowerCase()).toList();

  @override
  Widget build(BuildContext context) {
    final open = _tickets.where((t) => t.status == TicketStatus.open).length;
    final critical = _tickets.where((t) => t.priority == TicketPriority.critical && t.status != TicketStatus.closed).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Support Tickets'), backgroundColor: Colors.indigo[700]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(children: [
        if (critical > 0) Container(color: Colors.red[50], padding: const EdgeInsets.all(10), child: Row(children: [
          const Icon(Icons.error, color: Colors.red, size: 18), const SizedBox(width: 8),
          Text('$critical critical ticket(s) need attention', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
        ])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Row(children: [
          Text('$open open', style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          ...['All', 'Open', 'InProgress', 'Resolved'].map((f) => Padding(padding: const EdgeInsets.only(left: 4), child: ChoiceChip(label: Text(f, style: const TextStyle(fontSize: 11)), selected: _filter == f, onSelected: (_) => setState(() => _filter = f), visualDensity: VisualDensity.compact))),
        ])),
        Expanded(child: RefreshIndicator(onRefresh: _load, child: ListView.builder(itemCount: _filtered.length, itemBuilder: (ctx, i) => _card(_filtered[i])))),
      ]),
    );
  }

  Widget _card(SupportTicket t) {
    final pColor = _priorityColor(t.priority);
    final sColor = _statusColor(t.status);
    return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: pColor.withValues(alpha: 0.3))), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.circle, size: 10, color: pColor), const SizedBox(width: 6),
        Expanded(child: Text(t.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
        Chip(label: Text(t.status.name, style: TextStyle(fontSize: 9, color: sColor)), backgroundColor: sColor.withValues(alpha: 0.1), side: BorderSide.none, visualDensity: VisualDensity.compact),
      ]),
      const SizedBox(height: 4),
      Text('${t.userName} (${t.userType}) • ${t.category}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      if (t.assignedTo != null) Text('Assigned: ${t.assignedTo}', style: const TextStyle(fontSize: 11, color: Colors.blue)),
      Row(children: [
        Text(t.priority.name.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: pColor)),
        const Spacer(),
        Text(_timeAgo(t.createdAt), style: TextStyle(fontSize: 10, color: Colors.grey[500])),
      ]),
    ])));
  }

  String _timeAgo(DateTime dt) { final d = DateTime.now().difference(dt); if (d.inMinutes < 60) return '${d.inMinutes}m ago'; if (d.inHours < 24) return '${d.inHours}h ago'; return '${d.inDays}d ago'; }
  Color _priorityColor(TicketPriority p) { switch (p) { case TicketPriority.critical: return Colors.red; case TicketPriority.high: return Colors.orange; case TicketPriority.medium: return Colors.blue; case TicketPriority.low: return Colors.grey; } }
  Color _statusColor(TicketStatus s) { switch (s) { case TicketStatus.open: return Colors.orange; case TicketStatus.inProgress: return Colors.blue; case TicketStatus.resolved: return Colors.green; case TicketStatus.closed: return Colors.grey; } }
}
