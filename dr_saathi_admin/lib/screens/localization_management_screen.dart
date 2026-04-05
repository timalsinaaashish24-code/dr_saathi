import 'package:flutter/material.dart';
import '../models/admin_models.dart';
import '../services/admin_management_service.dart';

class LocalizationManagementScreen extends StatefulWidget {
  const LocalizationManagementScreen({super.key});
  @override
  State<LocalizationManagementScreen> createState() => _LocalizationManagementScreenState();
}

class _LocalizationManagementScreenState extends State<LocalizationManagementScreen> {
  final _service = AdminManagementService();
  List<TranslationEntry> _translations = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { setState(() => _isLoading = true); _translations = await _service.getTranslations(); setState(() => _isLoading = false); }

  @override
  Widget build(BuildContext context) {
    final reviewed = _translations.where((t) => t.isReviewed).length;
    final pending = _translations.length - reviewed;
    return Scaffold(
      appBar: AppBar(title: const Text('Localization'), backgroundColor: Colors.indigo[700]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          Expanded(child: Card(color: Colors.green[50], child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
            Text('$reviewed', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
            const Text('Reviewed', style: TextStyle(fontSize: 11, color: Colors.green)),
          ])))),
          const SizedBox(width: 8),
          Expanded(child: Card(color: Colors.orange[50], child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
            Text('$pending', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
            const Text('Pending Review', style: TextStyle(fontSize: 11, color: Colors.orange)),
          ])))),
        ])),
        Expanded(child: ListView.builder(itemCount: _translations.length, itemBuilder: (ctx, i) => _card(_translations[i]))),
      ]),
    );
  }

  Widget _card(TranslationEntry t) {
    return Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)), child: Text(t.screen, style: const TextStyle(fontSize: 10))),
        const SizedBox(width: 8),
        Text(t.key, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontFamily: 'monospace')),
        const Spacer(),
        Icon(t.isReviewed ? Icons.check_circle : Icons.pending, size: 16, color: t.isReviewed ? Colors.green : Colors.orange),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        const SizedBox(width: 24, child: Text('EN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue))),
        Expanded(child: Text(t.englishText, style: const TextStyle(fontSize: 13))),
      ]),
      const SizedBox(height: 4),
      Row(children: [
        const SizedBox(width: 24, child: Text('NE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.deepPurple))),
        Expanded(child: Text(t.nepaliText, style: const TextStyle(fontSize: 13))),
      ]),
    ])));
  }
}
