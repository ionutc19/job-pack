import 'package:flutter/material.dart';
import '../models/job_fit.dart';
import '../services/service_locator.dart';
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
      late final JobFitResult result;

      if (locator.useMocks) {
        result = await locator.mock.analyzeJobFit(
          cvText: _cvController.text,
          jobDescription: _jdController.text,
        );
      } else {
        result = await locator.api.analyzeJobFit(
          cvText: _cvController.text,
          jobDescription: _jdController.text,
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
      appBar: AppBar(title: const Text('Job Fit Analysis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paste your CV and the job description to see how well you match.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _cvController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'CV / Resume Text',
                  hintText: 'Paste your CV content here...',
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    (v == null || v.length < 10) ? 'Please enter at least 10 characters' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jdController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Job Description',
                  hintText: 'Paste the job posting here...',
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    (v == null || v.length < 10) ? 'Please enter at least 10 characters' : null,
              ),
              const SizedBox(height: 24),
              LoadingButton(
                label: 'Analyze Match',
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
