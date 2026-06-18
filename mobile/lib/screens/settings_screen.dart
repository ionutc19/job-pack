import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../l10n/app_localizations.dart';
import '../l10n/language_provider.dart';
import '../services/service_locator.dart';
import '../services/user_identity.dart';
import '../widgets/language_dropdown.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _backendReachable = false;
  bool _checking = false;
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

  Future<void> _checkBackend() async {
    setState(() => _checking = true);
    final reachable = await ServiceLocator().api.checkHealth();
    if (mounted) {
      final l = AppLocalizations.of(context);
      setState(() {
        _backendReachable = reachable;
        _checking = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reachable ? l.backendReachable : l.backendNotReachable),
        ),
      );
    }
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
    final langProvider = Provider.of<LanguageProvider>(context);
    final userId = UserIdentity().userId;

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        children: [
          _SectionHeader(title: l.appInfo),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.version),
            subtitle: Text(AppConfig.appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l.language),
            subtitle: Text(langProvider.locale.languageCode == 'ro' ? l.romanian : l.english),
            trailing: const LanguageDropdown(),
          ),
          if (kDebugMode)
            ListTile(
              leading: const Icon(Icons.science_outlined),
              title: Text(l.mockServices),
              subtitle: Text(AppConfig.useMockServices ? l.enabled : l.disabled),
              trailing: Icon(
                AppConfig.useMockServices ? Icons.check_circle : Icons.cloud,
                color: AppConfig.useMockServices ? Colors.orange : Colors.green,
              ),
            ),
          _SectionHeader(title: l.account),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: Text(l.plans),
            subtitle: Text(_tierLabel(l)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/plans'),
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: Text(l.userId),
            subtitle: Text(
              userId.length > 8 ? '${userId.substring(0, 8)}...' : userId,
              style: TextStyle(
                fontFamily: 'monospace',
                color: Colors.grey.shade600,
              ),
            ),
          ),
          if (kDebugMode) ...[
            _SectionHeader(title: l.backend),
            ListTile(
              leading: const Icon(Icons.dns_outlined),
              title: Text(l.baseUrl),
              subtitle: Text(AppConfig.baseUrl),
            ),
            ListTile(
              leading: _checking
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _backendReachable ? Icons.check_circle : Icons.error_outline,
                      color: _backendReachable ? Colors.green : Colors.grey,
                    ),
              title: Text(l.connectionStatus),
              subtitle: Text(_backendReachable ? l.connected : l.notChecked),
              trailing: TextButton(
                onPressed: _checking ? null : _checkBackend,
                child: Text(l.test),
              ),
            ),
          ],
          _SectionHeader(title: l.support),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: Text(l.sendFeedback),
            onTap: () => Navigator.pushNamed(context, '/feedback'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l.privacyTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/privacy'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
