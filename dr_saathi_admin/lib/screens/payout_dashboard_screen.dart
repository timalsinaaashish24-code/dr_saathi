import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/admin_models.dart';
import '../services/admin_management_service.dart';

class PayoutDashboardScreen extends StatefulWidget {
  const PayoutDashboardScreen({super.key});
  @override
  State<PayoutDashboardScreen> createState() => _PayoutDashboardScreenState();
}

class _PayoutDashboardScreenState extends State<PayoutDashboardScreen> {
  final _service = AdminManagementService();
  List<DoctorPayout> _payouts = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { setState(() => _isLoading = true); _payouts = await _service.getDoctorPayouts(); setState(() => _isLoading = false); }

  @override
  Widget build(BuildContext context) {
    final totalPending = _payouts.where((p) => p.status == PayoutStatus.pending).fold<double>(0, (s, p) => s + p.amount);
    final totalCompleted = _payouts.where((p) => p.status == PayoutStatus.completed).fold<double>(0, (s, p) => s + p.amount);
    return Scaffold(
      appBar: AppBar(title: const Text('Payout Dashboard'), backgroundColor: Colors.indigo[700]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          Expanded(child: Card(color: Colors.orange[50], child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
            const Text('Pending', style: TextStyle(fontSize: 12, color: Colors.orange)),
            Text('NPR ${NumberFormat('#,###').format(totalPending.toInt())}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
          ])))),
          const SizedBox(width: 8),
          Expanded(child: Card(color: Colors.green[50], child: Padding(padding: const EdgeInsets.all(14), child: Column(children: [
            const Text('Completed', style: TextStyle(fontSize: 12, color: Colors.green)),
            Text('NPR ${NumberFormat('#,###').format(totalCompleted.toInt())}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          ])))),
        ])),
        Expanded(child: RefreshIndicator(onRefresh: _load, child: ListView.builder(itemCount: _payouts.length, itemBuilder: (ctx, i) => _card(_payouts[i])))),
      ]),
    );
  }

  Widget _card(DoctorPayout p) {
    final color = _statusColor(p.status);
    return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: ListTile(
      leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(Icons.account_balance, color: color, size: 20)),
      title: Text(p.doctorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text('${p.bankName} • ${p.consultationCount} consults • ${DateFormat('MMM dd').format(p.periodStart)}–${DateFormat('MMM dd').format(p.periodEnd)}', style: const TextStyle(fontSize: 12)),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('NPR ${p.amount.toInt()}', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        Text(p.status.name, style: TextStyle(fontSize: 10, color: color)),
      ]),
      onTap: () { if (p.status == PayoutStatus.pending) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Process payout ${p.id} — mock'))); },
    ));
  }

  Color _statusColor(PayoutStatus s) { switch (s) { case PayoutStatus.pending: return Colors.orange; case PayoutStatus.processing: return Colors.blue; case PayoutStatus.completed: return Colors.green; case PayoutStatus.failed: return Colors.red; } }
}
