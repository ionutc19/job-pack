import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../l10n/app_localizations.dart';
import '../services/service_locator.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/language_dropdown.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentTier = 'free';

  @override
  void initState() {
    super.initState();
    if (!AppConfig.useMockServices) {
      _fetchTier();
    }
  }

  Future<void> _fetchTier() async {
    try {
      final data = await ServiceLocator().api.getEntitlements();
      if (mounted) {
        setState(() {
          _currentTier = data['tier'] as String? ?? 'free';
        });
      }
    } catch (_) {}
  }

  String _tierLabel(AppLocalizations l) {
    switch (_currentTier) {
      case 'premium':
        return l.planPremium;
      case 'pro':
        return l.planPro;
      default:
        return l.planFree;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.appName),
        actions: [
          const LanguageDropdown(),
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
              l.whatToDo,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 20),
            _HomeCard(
              icon: Icons.analytics_outlined,
              title: l.jobFitAnalysis,
              description: l.jobFitDescription,
              color: const Color(0xFF2563EB),
              onTap: () => Navigator.pushNamed(context, '/job-fit'),
            ),
            _HomeCard(
              icon: Icons.person_outline,
              title: l.profileBoost,
              description: l.profileBoostDescription,
              color: const Color(0xFF7C3AED),
              onTap: () => Navigator.pushNamed(context, '/profile-boost'),
            ),
            _HomeCard(
              icon: Icons.description_outlined,
              title: l.coverLetter,
              description: l.coverLetterDescription,
              color: const Color(0xFF059669),
              onTap: () => Navigator.pushNamed(context, '/cover-letter'),
            ),
            const Spacer(),
            if (_currentTier == 'free') ...[
              const Center(child: BannerAdWidget()),
              const SizedBox(height: 8),
            ],
            _PlanBanner(
              tierLabel: _tierLabel(l),
              isFree: _currentTier == 'free',
              onTap: () => Navigator.pushNamed(context, '/plans'),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/feedback'),
                icon: const Icon(Icons.feedback_outlined, size: 18),
                label: Text(l.sendFeedback),
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

class _PlanBanner extends StatelessWidget {
  final String tierLabel;
  final bool isFree;
  final VoidCallback onTap;

  const _PlanBanner({
    required this.tierLabel,
    required this.isFree,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    const color = Color(0xFF7C3AED);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.workspace_premium_outlined,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l.plans} • $tierLabel',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (isFree) ...[
                      const SizedBox(height: 2),
                      Text(
                        l.planUpgradeCta,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: color,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
