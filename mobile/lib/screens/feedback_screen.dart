import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
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
        final l = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? l.feedbackSubmitted : l.feedbackOffline),
          ),
        );
        if (success) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).error}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.sendFeedback)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.feedbackInstructions,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 20),
              Text(l.category, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'bug', label: Text(l.bug), icon: const Icon(Icons.bug_report)),
                  ButtonSegment(value: 'feature', label: Text(l.feature), icon: const Icon(Icons.lightbulb)),
                  ButtonSegment(value: 'feedback', label: Text(l.feedback), icon: const Icon(Icons.chat)),
                ],
                selected: {_category},
                onSelectionChanged: (v) => setState(() => _category = v.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l.title,
                  hintText: l.titleHint,
                ),
                validator: (v) => (v == null || v.length < 3) ? l.titleMinChars : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l.description,
                  hintText: l.descriptionHint,
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.length < 10) ? l.descriptionMinChars : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l.emailOptional,
                  hintText: l.emailHint,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              LoadingButton(
                label: l.submitFeedback,
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
