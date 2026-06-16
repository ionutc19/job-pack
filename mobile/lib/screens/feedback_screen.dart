import 'package:flutter/material.dart';
import '../services/service_locator.dart';
import '../widgets/loading_button.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  String _category = 'feedback';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final locator = ServiceLocator();
      bool success;

      if (locator.useMocks) {
        success = await locator.mock.submitFeedback(
          category: _category,
          title: _titleController.text,
          description: _descriptionController.text,
          email: _emailController.text,
        );
      } else {
        success = await locator.api.submitFeedback(
          category: _category,
          title: _titleController.text,
          description: _descriptionController.text,
          email: _emailController.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Thank you! Your feedback has been submitted.'
                : 'Feedback received (offline mode).'),
          ),
        );
        if (success) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help us improve Job Pack. Report bugs, request features, or share feedback.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 20),
              Text('Category', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'bug', label: Text('Bug'), icon: Icon(Icons.bug_report)),
                  ButtonSegment(
                      value: 'feature', label: Text('Feature'), icon: Icon(Icons.lightbulb)),
                  ButtonSegment(
                      value: 'feedback', label: Text('Feedback'), icon: Icon(Icons.chat)),
                ],
                selected: {_category},
                onSelectionChanged: (v) => setState(() => _category = v.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Brief summary...',
                ),
                validator: (v) =>
                    (v == null || v.length < 3) ? 'Title must be at least 3 characters' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the issue or suggestion in detail...',
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.length < 10)
                    ? 'Please provide at least 10 characters'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  hintText: 'For follow-up if needed',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              LoadingButton(
                label: 'Submit Feedback',
                icon: Icons.send,
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
