import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/admin_models.dart';
import '../services/admin_management_service.dart';

class DoctorVerificationScreen extends StatefulWidget {
  const DoctorVerificationScreen({super.key});
  @override
  State<DoctorVerificationScreen> createState() => _DoctorVerificationScreenState();
}

class _DoctorVerificationScreenState extends State<DoctorVerificationScreen> {
  final _service = AdminManagementService();
  List<DoctorVerification> _doctors = [];
  bool _isLoading = true;
  String _filter = 'All';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    _doctors = await _service.getDoctorVerifications();
    setState(() => _isLoading = false);
  }

  List<DoctorVerification> get _filtered => _filter == 'All'
      ? _doctors
      : _doctors.where((d) => d.status.name == _filter.toLowerCase()).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Verification'), backgroundColor: Colors.indigo[700]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: Row(children: ['All', 'Pending', 'Approved', 'Rejected', 'Suspended'].map((f) =>
              Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(
                label: Text(f), selected: _filter == f,
                onSelected: (_) => setState(() => _filter = f),
              )),
            ).toList()),
          ),
          Expanded(child: RefreshIndicator(onRefresh: _load, child: ListView.builder(
            itemCount: _filtered.length,
            itemBuilder: (ctx, i) => _buildDoctorCard(_filtered[i]),
          ))),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(DoctorVerification doc) {
    final color = _statusColor(doc.status);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(Icons.person, color: color)),
        title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${doc.specialization} • ${doc.location}'),
        trailing: Chip(label: Text(doc.status.name.toUpperCase(), style: TextStyle(fontSize: 10, color: color)), backgroundColor: color.withValues(alpha: 0.1), side: BorderSide.none),
        children: [
          Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _infoRow('NMC Number', doc.nmcNumber),
            _infoRow('Email', doc.email),
            _infoRow('Phone', doc.phone),
            _infoRow('Applied', DateFormat('MMM dd, yyyy').format(doc.appliedAt)),
            if (doc.verifiedAt != null) _infoRow('Verified', DateFormat('MMM dd, yyyy').format(doc.verifiedAt!)),
            if (doc.rejectionReason != null) _infoRow('Rejection Reason', doc.rejectionReason!),
            const SizedBox(height: 12),
            if (doc.status == DoctorStatus.pending) Row(children: [
              Expanded(child: ElevatedButton.icon(onPressed: () => _showAction(doc, 'approve'), icon: const Icon(Icons.check), label: const Text('Approve'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton.icon(onPressed: () => _showAction(doc, 'reject'), icon: const Icon(Icons.close), label: const Text('Reject'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red))),
            ]),
            if (doc.status == DoctorStatus.approved) ElevatedButton.icon(onPressed: () => _showAction(doc, 'suspend'), icon: const Icon(Icons.block), label: const Text('Suspend'), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange)),
          ])),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      SizedBox(width: 120, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600]))),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
    ]),
  );

  void _showAction(DoctorVerification doc, String action) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${action.toUpperCase()}: ${doc.name} — mock action')));
  }

  Color _statusColor(DoctorStatus s) {
    switch (s) { case DoctorStatus.pending: return Colors.orange; case DoctorStatus.approved: return Colors.green; case DoctorStatus.rejected: return Colors.red; case DoctorStatus.suspended: return Colors.grey; }
  }
}
