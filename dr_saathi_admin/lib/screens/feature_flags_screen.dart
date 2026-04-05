import 'package:flutter/material.dart';
import '../models/admin_models.dart';
import '../services/admin_management_service.dart';

class FeatureFlagsScreen extends StatefulWidget {
  const FeatureFlagsScreen({super.key});
  @override
  State<FeatureFlagsScreen> createState() => _FeatureFlagsScreenState();
}

class _FeatureFlagsScreenState extends State<FeatureFlagsScreen> {
  final _service = AdminManagementService();
  List<FeatureFlag> _flags = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { setState(() => _isLoading = true); _flags = await _service.getFeatureFlags(); setState(() => _isLoading = false); }

  @override
  Widget build(BuildContext context) {
    final categories = _flags.map((f) => f.category).toSet().toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Feature Flags'), backgroundColor: Colors.indigo[700]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.all(12), children: [
        Card(color: Colors.amber[50], child: const Padding(padding: EdgeInsets.all(12), child: Row(children: [
          Icon(Icons.info_outline, color: Colors.amber, size: 20), SizedBox(width: 8),
          Expanded(child: Text('Toggle features on/off across all Dr. Saathi apps. Changes take effect immediately.', style: TextStyle(fontSize: 12))),
        ]))),
        const SizedBox(height: 8),
        ...categories.map((cat) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4), child: Text(cat, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]))),
          ..._flags.where((f) => f.category == cat).map((f) => Card(child: SwitchListTile(
            title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(f.description, style: const TextStyle(fontSize: 12)),
            value: f.isEnabled,
            activeColor: Colors.green,
            secondary: Icon(f.isEnabled ? Icons.toggle_on : Icons.toggle_off, color: f.isEnabled ? Colors.green : Colors.grey),
            onChanged: (v) => setState(() => f.isEnabled = v),
          ))),
        ])),
      ]),
    );
  }
}
