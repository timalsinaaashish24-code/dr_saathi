import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/feedback.dart' as app_feedback;
import '../services/feedback_service.dart';

class AdminFeedbackScreen extends StatefulWidget {
  const AdminFeedbackScreen({Key? key}) : super(key: key);

  @override
  State<AdminFeedbackScreen> createState() => _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends State<AdminFeedbackScreen> with SingleTickerProviderStateMixin {
  final FeedbackService _feedbackService = FeedbackService();
  List<app_feedback.Feedback> _allFeedback = [];
  List<app_feedback.Feedback> _filteredFeedback = [];
  String _selectedFilter = 'doctors'; // doctors, patients
  String _searchQuery = '';
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFeedback();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFeedback() async {
    setState(() => _isLoading = true);
    try {
      final feedback = await _feedbackService.getAllFeedback();
      setState(() {
        _allFeedback = feedback;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading feedback: $e')),
        );
      }
    }
  }

  void _applyFilter() {
    List<app_feedback.Feedback> filtered = List.from(_allFeedback);

    // Apply user type filter
    if (_selectedFilter == 'doctors') {
      filtered = filtered.where((f) => f.userType == 'doctor').toList();
    } else if (_selectedFilter == 'patients') {
      filtered = filtered.where((f) => f.userType == 'patient').toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((f) =>
          f.subject.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.message.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.userName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    setState(() {
      _filteredFeedback = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Management'),
        backgroundColor: Colors.indigo[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFeedback,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Doctors'),
            Tab(text: 'Patients'),
          ],
          onTap: (index) {
            setState(() {
              _selectedFilter = ['doctors', 'patients'][index];
              _applyFilter();
            });
          },
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search feedback...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilter();
                });
              },
            ),
          ),

          // Statistics cards
          _buildStatisticsCards(),

          // Feedback list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFeedback.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.feedback_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No feedback found',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadFeedback,
                        child: ListView.builder(
                          itemCount: _filteredFeedback.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            return _buildFeedbackCard(_filteredFeedback[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final doctorCount = _allFeedback.where((f) => f.userType == 'doctor').length;
    final patientCount = _allFeedback.where((f) => f.userType == 'patient').length;
    final avgRating = _allFeedback.isEmpty
        ? 0.0
        : _allFeedback.map((f) => f.rating).reduce((a, b) => a + b) / _allFeedback.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Doctors',
              doctorCount.toString(),
              Icons.medical_services,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Patients',
              patientCount.toString(),
              Icons.person,
              Colors.purple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Avg Rating',
              avgRating.toStringAsFixed(1),
              Icons.star,
              Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(app_feedback.Feedback feedback) {
    final isNew = feedback.status == 'new';
    final categoryColor = _getCategoryColor(feedback.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isNew ? Colors.orange.withOpacity(0.5) : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _showFeedbackDetails(feedback),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: feedback.userType == 'doctor'
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.purple.withOpacity(0.2),
                    child: Icon(
                      feedback.userType == 'doctor' ? Icons.medical_services : Icons.person,
                      color: feedback.userType == 'doctor' ? Colors.blue : Colors.purple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feedback.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${feedback.userType.toUpperCase()} • ${DateFormat('MMM dd, yyyy').format(feedback.createdAt)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  // Rating
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          feedback.rating.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Category and Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      feedback.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(feedback.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      feedback.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(feedback.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Subject
              Text(
                feedback.subject,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Message preview
              Text(
                feedback.message,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              // Response indicator
              if (feedback.response != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Responded by ${feedback.respondedBy}',
                          style: const TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'bug':
        return Colors.red;
      case 'feature':
        return Colors.blue;
      case 'complaint':
        return Colors.orange;
      case 'suggestion':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'new':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _showFeedbackDetails(app_feedback.Feedback feedback) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FeedbackDetailsSheet(
        feedback: feedback,
        onRespond: (response) async {
          await _feedbackService.respondToFeedback(
            id: feedback.id,
            response: response,
            respondedBy: 'Admin',
          );
          _loadFeedback();
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Response sent successfully')),
            );
          }
        },
        onStatusChange: (status) async {
          await _feedbackService.updateFeedbackStatus(feedback.id, status);
          _loadFeedback();
          if (mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

class FeedbackDetailsSheet extends StatefulWidget {
  final app_feedback.Feedback feedback;
  final Function(String) onRespond;
  final Function(String) onStatusChange;

  const FeedbackDetailsSheet({
    Key? key,
    required this.feedback,
    required this.onRespond,
    required this.onStatusChange,
  }) : super(key: key);

  @override
  State<FeedbackDetailsSheet> createState() => _FeedbackDetailsSheetState();
}

class _FeedbackDetailsSheetState extends State<FeedbackDetailsSheet> {
  final TextEditingController _responseController = TextEditingController();

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Feedback Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User info
                      _buildInfoRow('User', widget.feedback.userName),
                      _buildInfoRow('Type', widget.feedback.userType.toUpperCase()),
                      if (widget.feedback.userEmail != null)
                        _buildInfoRow('Email', widget.feedback.userEmail!),
                      if (widget.feedback.userPhone != null)
                        _buildInfoRow('Phone', widget.feedback.userPhone!),
                      _buildInfoRow('Category', widget.feedback.category.toUpperCase()),
                      _buildInfoRow('Rating', '${widget.feedback.rating} ⭐'),
                      _buildInfoRow(
                        'Date',
                        DateFormat('MMM dd, yyyy HH:mm').format(widget.feedback.createdAt),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'Subject',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.feedback.subject,
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'Message',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.feedback.message,
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ),

                      // Existing response
                      if (widget.feedback.response != null) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Admin Response',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.feedback.response!,
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'By ${widget.feedback.respondedBy} • ${DateFormat('MMM dd, yyyy').format(widget.feedback.respondedAt!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Response form (if not responded)
                      if (widget.feedback.response == null) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Send Response',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _responseController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Type your response here...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (_responseController.text.isNotEmpty) {
                                widget.onRespond(_responseController.text);
                              }
                            },
                            icon: const Icon(Icons.send),
                            label: const Text('Send Response'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo[700],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Status actions
                      const SizedBox(height: 24),
                      const Text(
                        'Update Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildStatusChip('new', 'New', Colors.orange),
                          _buildStatusChip('in_progress', 'In Progress', Colors.blue),
                          _buildStatusChip('resolved', 'Resolved', Colors.green),
                          _buildStatusChip('closed', 'Closed', Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, String label, Color color) {
    final isSelected = widget.feedback.status == status;
    return ActionChip(
      label: Text(label),
      backgroundColor: isSelected ? color : Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onPressed: () => widget.onStatusChange(status),
    );
  }
}
