import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
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
      final lang = AppLocalizations.of(context).languageCode;
      if (locator.useMocks) {
        final result = await locator.mock.generateCoverLetter(
          cvText: _cvController.text,
          jobDescription: _jdController.text,
          tone: _tone,
          language: lang,
        );
        _coverLetter = result.coverLetter;
      } else {
        final result = await locator.api.generateCoverLetter(
          cvText: _cvController.text,
          jobDescription: _jdController.text,
          tone: _tone,
          language: lang,
        );
        _coverLetter = result.coverLetter;
      }
      setState(() {});
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
      appBar: AppBar(title: Text(l.coverLetter)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.coverLetterInstructions,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cvController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l.cvResumeText,
                  hintText: l.cvHint,
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.length < 10) ? l.minCharsError : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _jdController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: l.jobDescription,
                  hintText: l.jobDescriptionHint,
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.length < 10) ? l.minCharsError : null,
              ),
              const SizedBox(height: 16),
              Text(l.tone, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'professional', label: Text(l.toneProfessional)),
                  ButtonSegment(value: 'casual', label: Text(l.toneCasual)),
                  ButtonSegment(value: 'enthusiastic', label: Text(l.toneEnthusiastic)),
                ],
                selected: {_tone},
                onSelectionChanged: (v) => setState(() => _tone = v.first),
              ),
              const SizedBox(height: 24),
              LoadingButton(
                label: l.generateLetter,
                icon: Icons.description,
                isLoading: _isLoading,
                onPressed: _generate,
              ),
              if (_coverLetter != null) ...[
                const SizedBox(height: 24),
                SectionCard(
                  title: l.yourCoverLetter,
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
                              SnackBar(content: Text(l.coverLetterCopied)),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 16),
                          label: Text(l.copy),
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
