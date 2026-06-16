import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    if (_headlineController.text.isEmpty &&
        _aboutController.text.isEmpty &&
        _experienceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in at least one field')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final locator = ServiceLocator();
      if (locator.useMocks) {
        _result = await locator.mock.generateProfileBoost(
          headline: _headlineController.text,
          about: _aboutController.text,
          experience: _experienceController.text,
        );
      } else {
        _result = await locator.api.generateProfileBoost(
          headline: _headlineController.text,
          about: _aboutController.text,
          experience: _experienceController.text,
        );
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

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Boost')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paste your current LinkedIn sections to get AI-powered improvements.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _headlineController,
              decoration: const InputDecoration(
                labelText: 'Current Headline',
                hintText: 'e.g. Software Engineer at TechCo',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _aboutController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Current About Section',
                hintText: 'Paste your LinkedIn About section...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _experienceController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Current Experience',
                hintText: 'Paste your latest experience entry...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            LoadingButton(
              label: 'Boost My Profile',
              icon: Icons.auto_awesome,
              isLoading: _isLoading,
              onPressed: _generate,
            ),
            if (_result != null) ...[
              const SizedBox(height: 24),
              _ResultSection(
                title: 'Improved Headline',
                icon: Icons.title,
                content: _result!.improvedHeadline,
                onCopy: () => _copyToClipboard(_result!.improvedHeadline, 'Headline'),
              ),
              _ResultSection(
                title: 'Improved About',
                icon: Icons.person,
                content: _result!.improvedAbout,
                onCopy: () => _copyToClipboard(_result!.improvedAbout, 'About'),
              ),
              _ResultSection(
                title: 'Improved Experience',
                icon: Icons.work,
                content: _result!.improvedExperience,
                onCopy: () => _copyToClipboard(_result!.improvedExperience, 'Experience'),
              ),
              SectionCard(
                title: 'Tips',
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
  final VoidCallback onCopy;

  const _ResultSection({
    required this.title,
    required this.icon,
    required this.content,
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
              label: const Text('Copy'),
            ),
          ),
        ],
      ),
    );
  }
}
