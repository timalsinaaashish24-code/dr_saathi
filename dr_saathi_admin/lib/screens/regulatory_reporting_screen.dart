import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/admin_models.dart';
import '../services/admin_management_service.dart';

class RegulatoryReportingScreen extends StatefulWidget {
  const RegulatoryReportingScreen({super.key});
  @override
  State<RegulatoryReportingScreen> createState() => _RegulatoryReportingScreenState();
}

class _RegulatoryReportingScreenState extends State<RegulatoryReportingScreen> {
  final _service = AdminManagementService();
  List<RegulatoryReport> _reports = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { setState(() => _isLoading = true); _reports = await _service.getRegulatoryReports(); setState(() => _isLoading = false); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Regulatory Reports'), backgroundColor: Colors.indigo[700], actions: [
        IconButton(icon: const Icon(Icons.add), tooltip: 'Generate Report', onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generate report — mock')))),
      ]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        padding: const EdgeInsets.all(12), itemCount: _reports.length,
        itemBuilder: (ctx, i) => _card(_reports[i]),
      ),
    );
  }

  Widget _card(RegulatoryReport r) {
    final color = _statusColor(r.status);
    final df = DateFormat('MMM dd, yyyy');
    return Card(child: ListTile(
      leading: CircleAvatar(backgroundColor: _typeColor(r.type).withValues(alpha: 0.15), child: Icon(_typeIcon(r.type), color: _typeColor(r.type), size: 20)),
      title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text('${r.type} • ${df.format(r.periodStart)} – ${df.format(r.periodEnd)}', style: const TextStyle(fontSize: 12)),
      trailing: Chip(label: Text(r.status, style: TextStyle(fontSize: 10, color: color)), backgroundColor: color.withValues(alpha: 0.1), side: BorderSide.none, visualDensity: VisualDensity.compact),
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download ${r.id} — mock'))),
    ));
  }

  Color _statusColor(String s) { switch (s) { case 'Submitted': return Colors.green; case 'Generated': return Colors.blue; default: return Colors.orange; } }
  Color _typeColor(String t) { switch (t) { case 'Monthly': return Colors.blue; case 'Quarterly': return Colors.purple; default: return Colors.indigo; } }
  IconData _typeIcon(String t) { switch (t) { case 'Monthly': return Icons.calendar_month; case 'Quarterly': return Icons.date_range; default: return Icons.assessment; } }
}
