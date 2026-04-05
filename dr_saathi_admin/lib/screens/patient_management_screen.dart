import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/admin_models.dart';
import '../services/admin_management_service.dart';

class PatientManagementScreen extends StatefulWidget {
  const PatientManagementScreen({super.key});
  @override
  State<PatientManagementScreen> createState() => _PatientManagementScreenState();
}

class _PatientManagementScreenState extends State<PatientManagementScreen> {
  final _service = AdminManagementService();
  List<PatientRecord> _patients = [];
  bool _isLoading = true;
  String _search = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    _patients = await _service.getPatients();
    setState(() => _isLoading = false);
  }

  List<PatientRecord> get _filtered => _search.isEmpty ? _patients : _patients.where((p) => p.name.toLowerCase().contains(_search.toLowerCase()) || p.phone.contains(_search) || p.id.contains(_search)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Management'), backgroundColor: Colors.indigo[700]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: TextField(
          decoration: InputDecoration(hintText: 'Search by name, phone, or ID...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12)),
          onChanged: (v) => setState(() => _search = v),
        )),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
          Text('${_filtered.length} patients', style: TextStyle(color: Colors.grey[600])),
          const Spacer(),
          Text('Active: ${_filtered.where((p) => p.isActive).length}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Text('Inactive: ${_filtered.where((p) => !p.isActive).length}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ])),
        const SizedBox(height: 8),
        Expanded(child: RefreshIndicator(onRefresh: _load, child: ListView.builder(
          itemCount: _filtered.length,
          itemBuilder: (ctx, i) => _buildPatientCard(_filtered[i]),
        ))),
      ]),
    );
  }

  Widget _buildPatientCard(PatientRecord p) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: p.isActive ? Colors.green[100] : Colors.red[100], child: Icon(Icons.person, color: p.isActive ? Colors.green : Colors.red)),
        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${p.age}y ${p.gender} • ${p.location} • ${p.totalConsultations} consults'),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(p.isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 11, color: p.isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
          Text(DateFormat('MMM dd').format(p.lastActiveAt), style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ]),
        onTap: () => _showDetail(p),
      ),
    );
  }

  void _showDetail(PatientRecord p) {
    showModalBottomSheet(context: context, builder: (ctx) => Padding(
      padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _row('ID', p.id), _row('Phone', p.phone), _row('Email', p.email),
        _row('Age / Gender', '${p.age} / ${p.gender}'), _row('Location', p.location),
        _row('Registered', DateFormat('MMM dd, yyyy').format(p.registeredAt)),
        _row('Last Active', DateFormat('MMM dd, yyyy HH:mm').format(p.lastActiveAt)),
        _row('Consultations', '${p.totalConsultations}'),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.pop(ctx), icon: Icon(p.isActive ? Icons.block : Icons.check), label: Text(p.isActive ? 'Deactivate' : 'Activate'), style: ElevatedButton.styleFrom(backgroundColor: p.isActive ? Colors.red : Colors.green))),
        ]),
      ]),
    ));
  }

  Widget _row(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [
    SizedBox(width: 110, child: Text(l, style: TextStyle(color: Colors.grey[600], fontSize: 13))),
    Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
  ]));
}
