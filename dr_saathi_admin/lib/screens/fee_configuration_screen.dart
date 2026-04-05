import 'package:flutter/material.dart';
import '../models/admin_models.dart';
import '../services/admin_management_service.dart';

class FeeConfigurationScreen extends StatefulWidget {
  const FeeConfigurationScreen({super.key});
  @override
  State<FeeConfigurationScreen> createState() => _FeeConfigurationScreenState();
}

class _FeeConfigurationScreenState extends State<FeeConfigurationScreen> {
  final _service = AdminManagementService();
  List<FeeConfig> _fees = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { setState(() => _isLoading = true); _fees = await _service.getFeeConfigs(); setState(() => _isLoading = false); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fee Configuration'), backgroundColor: Colors.indigo[700]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        padding: const EdgeInsets.all(12), itemCount: _fees.length,
        itemBuilder: (ctx, i) => _card(_fees[i]),
      ),
    );
  }

  Widget _card(FeeConfig f) {
    final platformEarning = f.consultationFee * f.platformCommissionRate / 100;
    final doctorGross = f.consultationFee - platformEarning;
    final tax = doctorGross * f.taxRate / 100;
    final doctorNet = doctorGross - tax;
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(f.specialty, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        Switch(value: f.isActive, onChanged: (v) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Toggle ${f.specialty} — mock')))),
      ]),
      const Divider(),
      _row('Consultation Fee', 'NPR ${f.consultationFee.toInt()}'),
      _row('Admin Commission', '${f.platformCommissionRate.toInt()}% (NPR ${platformEarning.toInt()})'),
      _row('Doctor Gross (${(100 - f.platformCommissionRate).toInt()}%)', 'NPR ${doctorGross.toInt()}'),
      _row('Tax/VAT on Doctor', '${f.taxRate.toInt()}% (NPR ${tax.toInt()})'),
      _row('Doctor Net Pay', 'NPR ${doctorNet.toInt()}', bold: true),
      const SizedBox(height: 8),
      Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: () => _showEditDialog(f), icon: const Icon(Icons.edit, size: 16), label: const Text('Edit'))),
    ])));
  }

  Widget _row(String l, String v, {bool bold = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(l, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
    Text(v, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w500, fontSize: 13, color: bold ? Colors.green[700] : null)),
  ]));

  void _showEditDialog(FeeConfig f) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('Edit ${f.specialty}'), content: const Text('Fee editing dialog — mock implementation'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
    ));
  }
}
