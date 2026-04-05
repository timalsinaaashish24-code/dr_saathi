import 'package:flutter/material.dart';
import '../models/admin_models.dart';
import '../services/admin_management_service.dart';

class RegionalCoverageScreen extends StatefulWidget {
  const RegionalCoverageScreen({super.key});
  @override
  State<RegionalCoverageScreen> createState() => _RegionalCoverageScreenState();
}

class _RegionalCoverageScreenState extends State<RegionalCoverageScreen> {
  final _service = AdminManagementService();
  List<ProvinceCoverage> _provinces = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { setState(() => _isLoading = true); _provinces = await _service.getRegionalCoverage(); setState(() => _isLoading = false); }

  @override
  Widget build(BuildContext context) {
    final totalDocs = _provinces.fold<int>(0, (s, p) => s + p.totalDoctors);
    final totalPats = _provinces.fold<int>(0, (s, p) => s + p.totalPatients);
    final underserved = _provinces.expand((p) => p.districts).where((d) => d.isUnderserved).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Regional Coverage'), backgroundColor: Colors.indigo[700]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          _summaryCard('Doctors', '$totalDocs', Colors.blue),
          const SizedBox(width: 8),
          _summaryCard('Patients', '$totalPats', Colors.green),
          const SizedBox(width: 8),
          _summaryCard('Underserved', '$underserved districts', Colors.red),
        ])),
        Expanded(child: ListView.builder(itemCount: _provinces.length, itemBuilder: (ctx, i) => _provinceCard(_provinces[i]))),
      ]),
    );
  }

  Widget _summaryCard(String title, String value, Color color) => Expanded(child: Card(color: color.withValues(alpha: 0.08), child: Padding(padding: const EdgeInsets.all(10), child: Column(children: [
    Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    Text(title, style: TextStyle(fontSize: 10, color: color)),
  ]))));

  Widget _provinceCard(ProvinceCoverage p) {
    return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: ExpansionTile(
      leading: CircleAvatar(backgroundColor: Colors.indigo[100], child: Text('${p.totalDoctors}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.indigo[700]))),
      title: Text(p.province, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text('${p.activeDoctors} active doctors • ${p.totalPatients} patients', style: const TextStyle(fontSize: 12)),
      children: p.districts.map((d) => ListTile(
        dense: true,
        leading: Icon(Icons.circle, size: 10, color: d.isUnderserved ? Colors.red : Colors.green),
        title: Text(d.district, style: const TextStyle(fontSize: 13)),
        subtitle: Text('${d.doctors} doctors • ${d.patients} patients', style: const TextStyle(fontSize: 11)),
        trailing: d.isUnderserved ? const Chip(label: Text('Underserved', style: TextStyle(fontSize: 9, color: Colors.red)), backgroundColor: Color(0x1AFF0000), side: BorderSide.none, visualDensity: VisualDensity.compact) : null,
      )).toList(),
    ));
  }
}
