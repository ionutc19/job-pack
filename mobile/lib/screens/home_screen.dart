import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Pack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What would you like to do?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 20),
            _HomeCard(
              icon: Icons.analytics_outlined,
              title: 'Job Fit Analysis',
              description: 'Upload your CV and a job description to see how well you match',
              color: const Color(0xFF2563EB),
              onTap: () => Navigator.pushNamed(context, '/job-fit'),
            ),
            _HomeCard(
              icon: Icons.person_outline,
              title: 'Profile Boost',
              description: 'Improve your LinkedIn headline, about, and experience sections',
              color: const Color(0xFF7C3AED),
              onTap: () => Navigator.pushNamed(context, '/profile-boost'),
            ),
            _HomeCard(
              icon: Icons.description_outlined,
              title: 'Cover Letter',
              description: 'Generate a personalized cover letter for any job posting',
              color: const Color(0xFF059669),
              onTap: () => Navigator.pushNamed(context, '/cover-letter'),
            ),
            const Spacer(),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/feedback'),
                icon: const Icon(Icons.feedback_outlined, size: 18),
                label: const Text('Send Feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
