import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../models/profile_boost.dart';
import '../services/service_locator.dart';
import '../widgets/loading_button.dart';
import '../widgets/section_card.dart';

class ProfileBoostScreen extends StatefulWidget {
  const ProfileBoostScreen({super.key});

  @override
  State<ProfileBoostScreen> createState() => _ProfileBoostScreenState();
}

class _ProfileBoostScreenState extends State<ProfileBoostScreen> {
  final _headlineController = TextEditingController();
  final _aboutController = TextEditingController();
  final _experienceController = TextEditingController();
  bool _isLoading = false;
  ProfileBoostResult? _result;

  @override
  void dispose() {
    _headlineController.dispose();
    _aboutController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final l = AppLocalizations.of(context);
    if (_headlineController.text.isEmpty &&
        _aboutController.text.isEmpty &&
        _experienceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.fillOneField)),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final locator = ServiceLocator();
      final lang = l.languageCode;
      if (locator.useMocks) {
        _result = await locator.mock.generateProfileBoost(
          headline: _headlineController.text,
          about: _aboutController.text,
          experience: _experienceController.text,
          language: lang,
        );
      } else {
        _result = await locator.api.generateProfileBoost(
          headline: _headlineController.text,
          about: _aboutController.text,
          experience: _experienceController.text,
          language: lang,
        );
      }
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l.error}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label ${l.copiedToClipboard}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.profileBoost)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.profileBoostInstructions,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _headlineController,
              decoration: InputDecoration(
                labelText: l.currentHeadline,
                hintText: l.headlineHint,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _aboutController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l.currentAbout,
                hintText: l.aboutHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _experienceController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l.currentExperience,
                hintText: l.experienceHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            LoadingButton(
              label: l.boostMyProfile,
              icon: Icons.auto_awesome,
              isLoading: _isLoading,
              onPressed: _generate,
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              _ResultSection(
                title: l.improvedHeadline,
                icon: Icons.title,
                content: _result!.improvedHeadline,
                copyLabel: l.copy,
                onCopy: () => _copyToClipboard(_result!.improvedHeadline, l.improvedHeadline),
              ),
              _ResultSection(
                title: l.improvedAbout,
                icon: Icons.person,
                content: _result!.improvedAbout,
                copyLabel: l.copy,
                onCopy: () => _copyToClipboard(_result!.improvedAbout, l.improvedAbout),
              ),
              _ResultSection(
                title: l.improvedExperience,
                icon: Icons.work,
                content: _result!.improvedExperience,
                copyLabel: l.copy,
                onCopy: () => _copyToClipboard(_result!.improvedExperience, l.improvedExperience),
              ),
              SectionCard(
                title: l.tips,
                icon: Icons.tips_and_updates,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _result!.tips
                      .map((tip) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                                Expanded(child: Text(tip)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;
  final String copyLabel;
  final VoidCallback onCopy;

  const _ResultSection({
    required this.title,
    required this.icon,
    required this.content,
    required this.copyLabel,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      icon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onCopy,
              icon: const Icon(Icons.copy, size: 16),
              label: Text(copyLabel),
            ),
          ),
        ],
      ),
    );
  }
}
