import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/admin_models.dart';
import '../services/admin_management_service.dart';

class CallLogReviewScreen extends StatefulWidget {
  const CallLogReviewScreen({super.key});
  @override
  State<CallLogReviewScreen> createState() => _CallLogReviewScreenState();
}

class _CallLogReviewScreenState extends State<CallLogReviewScreen> {
  final _service = AdminManagementService();
  List<CallLogEntry> _logs = [];
  bool _isLoading = true;
  bool _showFlaggedOnly = false;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { setState(() => _isLoading = true); _logs = await _service.getCallLogs(); setState(() => _isLoading = false); }

  List<CallLogEntry> get _filtered => _showFlaggedOnly ? _logs.where((l) => l.flagged).toList() : _logs;

  @override
  Widget build(BuildContext context) {
    final flagged = _logs.where((l) => l.flagged).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Call/Chat Logs'), backgroundColor: Colors.indigo[700]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          FilterChip(label: Text('All (${_logs.length})'), selected: !_showFlaggedOnly, onSelected: (_) => setState(() => _showFlaggedOnly = false)),
          const SizedBox(width: 8),
          FilterChip(label: Text('Flagged ($flagged)', style: TextStyle(color: flagged > 0 ? Colors.red : null)), selected: _showFlaggedOnly, onSelected: (_) => setState(() => _showFlaggedOnly = true), avatar: flagged > 0 ? const Icon(Icons.flag, size: 16, color: Colors.red) : null),
        ])),
        Expanded(child: RefreshIndicator(onRefresh: _load, child: ListView.builder(itemCount: _filtered.length, itemBuilder: (ctx, i) => _card(_filtered[i])))),
      ]),
    );
  }

  Widget _card(CallLogEntry l) {
    final stars = l.qualityScore;
    return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), color: l.flagged ? Colors.red[50] : null, child: ListTile(
      leading: CircleAvatar(backgroundColor: l.flagged ? Colors.red[100] : Colors.indigo[100], child: Icon(_typeIcon(l.type), color: l.flagged ? Colors.red : Colors.indigo, size: 20)),
      title: Text('${l.patientName} ↔ ${l.doctorName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${l.type} • ${l.durationMinutes} min • ${DateFormat('MMM dd, HH:mm').format(l.startTime)}', style: const TextStyle(fontSize: 12)),
        Row(children: [
          ...List.generate(5, (i) => Icon(i < stars.round() ? Icons.star : Icons.star_border, size: 14, color: Colors.amber)),
          Text(' ${stars.toStringAsFixed(1)}', style: const TextStyle(fontSize: 11)),
        ]),
        if (l.flagged && l.flagReason != null) Text('⚠ ${l.flagReason}', style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w500)),
      ]),
    ));
  }

  IconData _typeIcon(String t) { switch (t) { case 'Video': return Icons.videocam; case 'Audio': return Icons.call; default: return Icons.chat; } }
}
