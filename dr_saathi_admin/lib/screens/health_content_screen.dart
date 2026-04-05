import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/admin_models.dart';
import '../services/admin_management_service.dart';

class HealthContentScreen extends StatefulWidget {
  const HealthContentScreen({super.key});
  @override
  State<HealthContentScreen> createState() => _HealthContentScreenState();
}

class _HealthContentScreenState extends State<HealthContentScreen> {
  final _service = AdminManagementService();
  List<HealthArticle> _articles = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { setState(() => _isLoading = true); _articles = await _service.getHealthArticles(); setState(() => _isLoading = false); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Content'), backgroundColor: Colors.indigo[700], actions: [
        IconButton(icon: const Icon(Icons.add), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create article — mock')))),
      ]),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        padding: const EdgeInsets.all(12), itemCount: _articles.length,
        itemBuilder: (ctx, i) => _card(_articles[i]),
      ),
    );
  }

  Widget _card(HealthArticle a) {
    return Card(child: ListTile(
      leading: CircleAvatar(backgroundColor: a.isPublished ? Colors.green[100] : Colors.grey[200], child: Text(a.language.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: a.isPublished ? Colors.green : Colors.grey))),
      title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text('${a.category} • ${a.views} views • ${DateFormat('MMM dd').format(a.createdAt)}', style: const TextStyle(fontSize: 12)),
      trailing: Chip(label: Text(a.isPublished ? 'Published' : 'Draft', style: TextStyle(fontSize: 10, color: a.isPublished ? Colors.green : Colors.grey)), backgroundColor: a.isPublished ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1), side: BorderSide.none, visualDensity: VisualDensity.compact),
    ));
  }
}
