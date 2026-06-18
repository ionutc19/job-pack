import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/job_fit.dart';
import '../services/service_locator.dart';
import '../widgets/file_upload_button.dart';
import '../widgets/loading_button.dart';
import 'job_fit_results_screen.dart';

class JobFitScreen extends StatefulWidget {
  const JobFitScreen({super.key});

  @override
  State<JobFitScreen> createState() => _JobFitScreenState();
}

class _JobFitScreenState extends State<JobFitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cvController = TextEditingController();
  final _jdController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _cvController.dispose();
    _jdController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final locator = ServiceLocator();
      final lang = AppLocalizations.of(context).languageCode;
      late final JobFitResult result;

      if (locator.useMocks) {
        result = await locator.mock.analyzeJobFit(
          cvText: _cvController.text,
          jobDescription: _jdController.text,
          language: lang,
        );
      } else {
        result = await locator.api.analyzeJobFit(
          cvText: _cvController.text,
          jobDescription: _jdController.text,
          language: lang,
        );
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JobFitResultsScreen(result: result)),
        );
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
      appBar: AppBar(title: Text(l.jobFitAnalysis)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.jobFitInstructions,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(l.cvResumeText, style: Theme.of(context).textTheme.titleSmall),
                  const Spacer(),
                  FileUploadButton(
                    label: l.uploadCv,
                    targetController: _cvController,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cvController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: l.cvHint,
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.length < 10) ? l.minCharsError : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(l.jobDescription, style: Theme.of(context).textTheme.titleSmall),
                  const Spacer(),
                  FileUploadButton(
                    label: l.uploadJd,
                    targetController: _jdController,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _jdController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: l.jobDescriptionHint,
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.length < 10) ? l.minCharsError : null,
              ),
              const SizedBox(height: 24),
              LoadingButton(
                label: l.analyzeMatch,
                icon: Icons.analytics,
                isLoading: _isLoading,
                onPressed: _analyze,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
