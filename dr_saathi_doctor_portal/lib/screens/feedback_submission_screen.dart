import 'package:flutter/material.dart';
import '../services/feedback_submission_service.dart';

class FeedbackSubmissionScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String userType; // 'doctor' or 'patient'
  final String? userEmail;
  final String? userPhone;

  const FeedbackSubmissionScreen({
    Key? key,
    required this.userId,
    required this.userName,
    required this.userType,
    this.userEmail,
    this.userPhone,
  }) : super(key: key);

  @override
  State<FeedbackSubmissionScreen> createState() => _FeedbackSubmissionScreenState();
}

class _FeedbackSubmissionScreenState extends State<FeedbackSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final FeedbackSubmissionService _feedbackService = FeedbackSubmissionService();

  String _selectedCategory = 'suggestion';
  int _selectedRating = 5;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _categories = [
    {'value': 'bug', 'label': 'Bug Report', 'icon': Icons.bug_report, 'color': Colors.red},
    {'value': 'feature', 'label': 'Feature Request', 'icon': Icons.lightbulb, 'color': Colors.blue},
    {'value': 'complaint', 'label': 'Complaint', 'icon': Icons.report_problem, 'color': Colors.orange},
    {'value': 'suggestion', 'label': 'Suggestion', 'icon': Icons.tips_and_updates, 'color': Colors.green},
    {'value': 'other', 'label': 'Other', 'icon': Icons.chat_bubble_outline, 'color': Colors.grey},
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final success = await _feedbackService.submitFeedback(
        userId: widget.userId,
        userName: widget.userName,
        userType: widget.userType,
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
        category: _selectedCategory,
        rating: _selectedRating,
        userEmail: widget.userEmail,
        userPhone: widget.userPhone,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Feedback submitted successfully! Thank you.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit feedback. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Feedback'),
        backgroundColor: Colors.indigo[700],
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Card(
              color: Colors.indigo[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.feedback, size: 48, color: Colors.indigo[700]),
                    const SizedBox(height: 12),
                    Text(
                      'We Value Your Feedback!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Help us improve Dr. Saathi by sharing your thoughts, suggestions, or reporting issues.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Rating
            const Text(
              'Rate Your Experience',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final rating = index + 1;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedRating = rating),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          rating <= _selectedRating ? Icons.star : Icons.star_border,
                          size: 40,
                          color: rating <= _selectedRating ? Colors.amber : Colors.grey,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Category
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category['value'];
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : category['color'] as Color,
                      ),
                      const SizedBox(width: 4),
                      Text(category['label'] as String),
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: category['color'] as Color,
                  backgroundColor: (category['color'] as Color).withOpacity(0.1),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() => _selectedCategory = category['value'] as String);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Subject
            const Text(
              'Subject',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _subjectController,
              decoration: InputDecoration(
                hintText: 'Brief title of your feedback',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a subject';
                }
                if (value.trim().length < 5) {
                  return 'Subject must be at least 5 characters';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 24),

            // Message
            const Text(
              'Message',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _messageController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Describe your feedback in detail...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your message';
                }
                if (value.trim().length < 20) {
                  return 'Message must be at least 20 characters';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitFeedback,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  _isSubmitting ? 'Submitting...' : 'Submit Feedback',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info text
            Text(
              'Your feedback will be reviewed by our admin team. We typically respond within 24-48 hours.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
