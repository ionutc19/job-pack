import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/service_locator.dart';
import '../widgets/loading_button.dart';
import '../widgets/section_card.dart';

class CoverLetterScreen extends StatefulWidget {
  const CoverLetterScreen({super.key});

  @override
  State<CoverLetterScreen> createState() => _CoverLetterScreenState();
}

class _CoverLetterScreenState extends State<CoverLetterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cvController = TextEditingController();
  final _jdController = TextEditingController();
  String _tone = 'professional';
  bool _isLoading = false;
  String? _coverLetter;

  @override
  void dispose() {
    _cvController.dispose();
    _jdController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final locator = ServiceLocator();
      if (locator.useMocks) {
        final result = await locator.mock.generateCoverLetter(
          cvText: _cvController.text,
          jobDescription: _jdController.text,
          tone: _tone,
        );
        _coverLetter = result.coverLetter;
      } else {
        final result = await locator.api.generateCoverLetter(
          cvText: _cvController.text,
          jobDescription: _jdController.text,
          tone: _tone,
        );
        _coverLetter = result.coverLetter;
      }
      setState(() {});
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
      appBar: AppBar(title: const Text('Cover Letter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generate a personalized cover letter based on your CV and the job posting.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cvController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'CV / Resume Text',
                  hintText: 'Paste your CV content...',
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    (v == null || v.length < 10) ? 'Please enter at least 10 characters' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _jdController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Job Description',
                  hintText: 'Paste the job posting...',
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    (v == null || v.length < 10) ? 'Please enter at least 10 characters' : null,
              ),
              const SizedBox(height: 16),
              Text('Tone', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'professional', label: Text('Professional')),
                  ButtonSegment(value: 'casual', label: Text('Casual')),
                  ButtonSegment(value: 'enthusiastic', label: Text('Enthusiastic')),
                ],
                selected: {_tone},
                onSelectionChanged: (v) => setState(() => _tone = v.first),
              ),
              const SizedBox(height: 24),
              LoadingButton(
                label: 'Generate Letter',
                icon: Icons.description,
                isLoading: _isLoading,
                onPressed: _generate,
              ),
              if (_coverLetter != null) ...[
                const SizedBox(height: 24),
                SectionCard(
                  title: 'Your Cover Letter',
                  icon: Icons.description_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(_coverLetter!),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _coverLetter!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cover letter copied to clipboard')),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copy'),
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
}
