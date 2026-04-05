import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/admin_models.dart';
import '../services/admin_management_service.dart';

class RefundManagementScreen extends StatefulWidget {
  const RefundManagementScreen({super.key});
  @override
  State<RefundManagementScreen> createState() => _RefundManagementScreenState();
}

class _RefundManagementScreenState extends State<RefundManagementScreen> {
  final _service = AdminManagementService();
  List<RefundRequest> _refunds = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { setState(() => _isLoading = true); _refunds = await _service.getRefundRequests(); setState(() => _isLoading = false); }

  @override
  Widget build(BuildContext context) {
    final pending = _refunds.where((r) => r.status == RefundStatus.pending).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Refund Management'), backgroundColor: Colors.indigo[700]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(children: [
        Container(color: Colors.orange[50], padding: const EdgeInsets.all(12), child: Row(children: [
          const Icon(Icons.warning_amber, color: Colors.orange), const SizedBox(width: 8),
          Text('$pending pending refund(s)', style: const TextStyle(fontWeight: FontWeight.bold)),
        ])),
        Expanded(child: RefreshIndicator(onRefresh: _load, child: ListView.builder(itemCount: _refunds.length, itemBuilder: (ctx, i) => _card(_refunds[i])))),
      ]),
    );
  }

  Widget _card(RefundRequest r) {
    final color = _statusColor(r.status);
    return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text('${r.patientName} → ${r.doctorName}', style: const TextStyle(fontWeight: FontWeight.bold))),
        Chip(label: Text(r.status.name, style: TextStyle(fontSize: 10, color: color)), backgroundColor: color.withValues(alpha: 0.1), side: BorderSide.none, visualDensity: VisualDensity.compact),
      ]),
      const SizedBox(height: 4),
      Text('NPR ${r.amount.toInt()} • ${r.reason}', style: const TextStyle(fontSize: 13)),
      Text('Requested: ${DateFormat('MMM dd, yyyy').format(r.requestedAt)}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      if (r.status == RefundStatus.pending) Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [
        Expanded(child: ElevatedButton(onPressed: () => _action(r, 'approve'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('Approve'))),
        const SizedBox(width: 8),
        Expanded(child: ElevatedButton(onPressed: () => _action(r, 'reject'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Reject'))),
      ])),
    ])));
  }

  void _action(RefundRequest r, String a) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${a.toUpperCase()} refund ${r.id} — mock'))); }
  Color _statusColor(RefundStatus s) { switch (s) { case RefundStatus.pending: return Colors.orange; case RefundStatus.approved: return Colors.green; case RefundStatus.rejected: return Colors.red; case RefundStatus.processed: return Colors.blue; } }
}
