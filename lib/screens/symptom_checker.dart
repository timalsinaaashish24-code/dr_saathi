import 'package:flutter/material.dart';
import '../models/symptom.dart';
import '../models/patient.dart';
import '../services/symptom_checker_service.dart';
import 'symptom_results.dart';

class SymptomCheckerScreen extends StatefulWidget {
  final Patient? patient;

  const SymptomCheckerScreen({super.key, this.patient});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> with SingleTickerProviderStateMixin {
  final SymptomCheckerService _symptomService = SymptomCheckerService();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  
  List<Symptom> _allSymptoms = [];
  List<Symptom> _filteredSymptoms = [];
  final Set<String> _selectedSymptoms = {};
  final Map<String, int> _symptomSeverity = {};
  final Map<String, String> _symptomDetails = {};
  
  String _searchQuery = '';
  bool _isLoading = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeSymptoms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeSymptoms() async {
    setState(() {
      _isLoading = true;
    });
    
    await _symptomService.initialize();
    setState(() {
      _allSymptoms = _symptomService.symptoms;
      _filteredSymptoms = _symptomService.getCommonSymptoms();
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSymptoms = _symptomService.getCommonSymptoms();
      } else {
        _filteredSymptoms = _symptomService.searchSymptoms(query);
      }
    });
  }

  void _onSymptomSelected(String symptomId, bool selected) {
    setState(() {
      if (selected) {
        _selectedSymptoms.add(symptomId);
        _symptomSeverity[symptomId] = 5; // Default severity
        _symptomDetails[symptomId] = '';
      } else {
        _selectedSymptoms.remove(symptomId);
        _symptomSeverity.remove(symptomId);
        _symptomDetails.remove(symptomId);
      }
    });
  }

  void _onSeverityChanged(String symptomId, int severity) {
    setState(() {
      _symptomSeverity[symptomId] = severity;
    });
  }

  void _onDetailsChanged(String symptomId, String details) {
    setState(() {
      _symptomDetails[symptomId] = details;
    });
  }

  void _showSymptomsByCategory(String category) {
    setState(() {
      _filteredSymptoms = _symptomService.getSymptomsByCategory(category);
    });
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _analyzeSymptoms() async {
    if (_selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one symptom')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create symptom check record
      final checkId = _symptomService.createSymptomCheck(
        patientId: widget.patient?.id,
        selectedSymptoms: _selectedSymptoms.toList(),
        symptomSeverity: _symptomSeverity,
        symptomDetails: _symptomDetails,
      );

      // Analyze symptoms
      final result = _symptomService.analyzeSymptoms(
        _selectedSymptoms.toList(),
        _symptomSeverity,
      );

      // Update the symptom check with results
      _symptomService.updateSymptomCheckResult(checkId, result);

      // Navigate to results screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SymptomResultsScreen(
            symptomCheck: _symptomService.getSymptomCheckById(checkId)!,
            patient: widget.patient,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing symptoms: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Checker'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Common', icon: Icon(Icons.star)),
            Tab(text: 'Search', icon: Icon(Icons.search)),
            Tab(text: 'Categories', icon: Icon(Icons.category)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress indicator
                _buildProgressIndicator(),
                
                // Content based on current step
                Expanded(
                  child: _currentStep == 0
                      ? _buildSymptomSelection()
                      : _currentStep == 1
                          ? _buildSeverityAssessment()
                          : _buildReviewAndSubmit(),
                ),
                
                // Bottom navigation
                _buildBottomNavigation(),
              ],
            ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 3,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              const SizedBox(width: 16),
              Text('${_currentStep + 1} of 3'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getStepTitle(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_selectedSymptoms.isNotEmpty)
                Chip(
                  label: Text('${_selectedSymptoms.length} selected'),
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Select Symptoms';
      case 1:
        return 'Rate Severity';
      case 2:
        return 'Review & Submit';
      default:
        return 'Symptom Checker';
    }
  }

  Widget _buildSymptomSelection() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildCommonSymptomsTab(),
        _buildSearchTab(),
        _buildCategoriesTab(),
      ],
    );
  }

  Widget _buildCommonSymptomsTab() {
    final commonSymptoms = _symptomService.getCommonSymptoms();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: commonSymptoms.length,
      itemBuilder: (context, index) {
        final symptom = commonSymptoms[index];
        return _buildSymptomCard(symptom);
      },
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search symptoms',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredSymptoms.length,
            itemBuilder: (context, index) {
              final symptom = _filteredSymptoms[index];
              return _buildSymptomCard(symptom);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesTab() {
    final categories = [
      {'name': 'General', 'value': 'general', 'icon': Icons.person},
      {'name': 'Head & Neck', 'value': 'headAndNeck', 'icon': Icons.face},
      {'name': 'Respiratory', 'value': 'respiratory', 'icon': Icons.air},
      {'name': 'Cardiovascular', 'value': 'cardiovascular', 'icon': Icons.favorite},
      {'name': 'Gastrointestinal', 'value': 'gastrointestinal', 'icon': Icons.restaurant},
      {'name': 'Musculoskeletal', 'value': 'musculoskeletal', 'icon': Icons.accessibility},
      {'name': 'Neurological', 'value': 'neurological', 'icon': Icons.psychology},
      {'name': 'Dermatological', 'value': 'dermatological', 'icon': Icons.healing},
      {'name': 'Mental Health', 'value': 'psychiatric', 'icon': Icons.psychology_alt},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          child: InkWell(
            onTap: () => _showSymptomsByCategory(category['value'] as String),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'] as IconData,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSymptomCard(Symptom symptom) {
    final isSelected = _selectedSymptoms.contains(symptom.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        title: Text(symptom.name),
        subtitle: Text(symptom.description),
        value: isSelected,
        onChanged: (value) => _onSymptomSelected(symptom.id, value ?? false),
        secondary: CircleAvatar(
          backgroundColor: _getSeverityColor(symptom.severity),
          child: Text(
            symptom.severity.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildSeverityAssessment() {
    final selectedSymptomObjects = _allSymptoms
        .where((s) => _selectedSymptoms.contains(s.id))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: selectedSymptomObjects.length,
      itemBuilder: (context, index) {
        final symptom = selectedSymptomObjects[index];
        return _buildSeverityCard(symptom);
      },
    );
  }

  Widget _buildSeverityCard(Symptom symptom) {
    final severity = _symptomSeverity[symptom.id] ?? 5;
    final details = _symptomDetails[symptom.id] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              symptom.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Rate the severity (1 = Very Mild, 10 = Severe)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('1'),
                Expanded(
                  child: Slider(
                    value: severity.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: severity.toString(),
                    onChanged: (value) => _onSeverityChanged(symptom.id, value.round()),
                  ),
                ),
                const Text('10'),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Additional details (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) => _onDetailsChanged(symptom.id, value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewAndSubmit() {
    final selectedSymptomObjects = _allSymptoms
        .where((s) => _selectedSymptoms.contains(s.id))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Your Symptoms',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ...selectedSymptomObjects.map((symptom) {
            final severity = _symptomSeverity[symptom.id] ?? 5;
            final details = _symptomDetails[symptom.id] ?? '';
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(symptom.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Severity: $severity/10'),
                    if (details.isNotEmpty) Text('Notes: $details'),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(severity),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getSeverityLabel(severity),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 32),
          Card(
            color: Colors.orange.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'This symptom checker is for informational purposes only and should not replace professional medical advice.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep == 2 ? _analyzeSymptoms : _nextStep,
              child: Text(_currentStep == 2 ? 'Analyze Symptoms' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(int severity) {
    if (severity <= 3) return Colors.green;
    if (severity <= 6) return Colors.orange;
    return Colors.red;
  }

  String _getSeverityLabel(int severity) {
    if (severity <= 3) return 'Mild';
    if (severity <= 6) return 'Moderate';
    return 'Severe';
  }
}
