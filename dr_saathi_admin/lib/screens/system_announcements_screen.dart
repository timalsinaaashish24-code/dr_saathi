import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/admin_models.dart';
import '../services/admin_management_service.dart';

class SystemAnnouncementsScreen extends StatefulWidget {
  const SystemAnnouncementsScreen({super.key});
  @override
  State<SystemAnnouncementsScreen> createState() => _SystemAnnouncementsScreenState();
}

class _SystemAnnouncementsScreenState extends State<SystemAnnouncementsScreen> {
  final _service = AdminManagementService();
  List<SystemAnnouncement> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { setState(() => _isLoading = true); _announcements = await _service.getAnnouncements(); setState(() => _isLoading = false); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements'), backgroundColor: Colors.indigo[700], actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create announcement — mock')))),
      ]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        padding: const EdgeInsets.all(12), itemCount: _announcements.length,
        itemBuilder: (ctx, i) => _card(_announcements[i]),
      ),
    );
  }

  Widget _card(SystemAnnouncement a) {
    final color = _typeColor(a.type);
    final df = DateFormat('MMM dd, yyyy');
    return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(_typeIcon(a.type), color: color, size: 20), const SizedBox(width: 8),
        Expanded(child: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
        Switch(value: a.isActive, onChanged: (v) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Toggle ${a.id} — mock')))),
      ]),
      const SizedBox(height: 4),
      Text(a.message, style: const TextStyle(fontSize: 13)),
      const SizedBox(height: 8),
      Row(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)), child: Text(a.targetAudience, style: const TextStyle(fontSize: 10))),
        const SizedBox(width: 8),
        Chip(label: Text(a.type.name, style: TextStyle(fontSize: 10, color: color)), backgroundColor: color.withValues(alpha: 0.1), side: BorderSide.none, visualDensity: VisualDensity.compact),
        const Spacer(),
        Text('${df.format(a.startDate)} – ${df.format(a.endDate)}', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
      ]),
    ])));
  }

  Color _typeColor(AnnouncementType t) { switch (t) { case AnnouncementType.maintenance: return Colors.orange; case AnnouncementType.update: return Colors.blue; case AnnouncementType.alert: return Colors.red; case AnnouncementType.info: return Colors.teal; } }
  IconData _typeIcon(AnnouncementType t) { switch (t) { case AnnouncementType.maintenance: return Icons.build; case AnnouncementType.update: return Icons.system_update; case AnnouncementType.alert: return Icons.warning; case AnnouncementType.info: return Icons.info; } }
}
