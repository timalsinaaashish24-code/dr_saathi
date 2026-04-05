import 'package:flutter/material.dart';
import '../models/admin_models.dart';
import '../services/admin_management_service.dart';

class TelecomStatusScreen extends StatefulWidget {
  const TelecomStatusScreen({super.key});
  @override
  State<TelecomStatusScreen> createState() => _TelecomStatusScreenState();
}

class _TelecomStatusScreenState extends State<TelecomStatusScreen> {
  final _service = AdminManagementService();
  List<TelecomProvider> _providers = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { setState(() => _isLoading = true); _providers = await _service.getTelecomStatus(); setState(() => _isLoading = false); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Telecom Status'), backgroundColor: Colors.indigo[700], actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
      ]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.all(12), children: _providers.map(_card).toList())),
    );
  }

  Widget _card(TelecomProvider p) {
    final color = _statusColor(p.status);
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.cell_tower, color: color), const SizedBox(width: 8),
        Expanded(child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        Chip(label: Text(p.status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)), backgroundColor: color.withValues(alpha: 0.1), side: BorderSide.none),
      ]),
      if (p.isActive) ...[
        const Divider(),
        _row('Delivery Rate', '${p.deliveryRate.toStringAsFixed(1)}%'),
        _row('Avg Latency', '${p.avgLatencySeconds.toStringAsFixed(1)} sec'),
        _row('Messages Today', '${p.messagesSentToday}'),
        _row('Failed Today', '${p.failedToday}', isError: p.failedToday > 15),
      ] else
        Padding(padding: const EdgeInsets.only(top: 8), child: Text('Provider is currently inactive', style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic))),
    ])));
  }

  Widget _row(String l, String v, {bool isError = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(l, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
    Text(v, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isError ? Colors.red : null)),
  ]));

  Color _statusColor(String s) { switch (s) { case 'Healthy': return Colors.green; case 'Degraded': return Colors.orange; default: return Colors.red; } }
}
