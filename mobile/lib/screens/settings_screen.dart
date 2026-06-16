import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/service_locator.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _backendReachable = false;
  bool _checking = false;

  Future<void> _checkBackend() async {
    setState(() => _checking = true);
    final reachable = await ServiceLocator().api.checkHealth();
    if (mounted) {
      setState(() {
        _backendReachable = reachable;
        _checking = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reachable ? 'Backend is reachable' : 'Backend is not reachable'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'App Info'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: Text(AppConfig.appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.science_outlined),
            title: const Text('Mock Services'),
            subtitle: Text(AppConfig.useMockServices ? 'Enabled' : 'Disabled'),
            trailing: Icon(
              AppConfig.useMockServices ? Icons.check_circle : Icons.cloud,
              color: AppConfig.useMockServices ? Colors.orange : Colors.green,
            ),
          ),
          const _SectionHeader(title: 'Backend'),
          ListTile(
            leading: const Icon(Icons.dns_outlined),
            title: const Text('Base URL'),
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
            title: const Text('Connection Status'),
            subtitle: Text(_backendReachable ? 'Connected' : 'Not checked'),
            trailing: TextButton(
              onPressed: _checking ? null : _checkBackend,
              child: const Text('Test'),
            ),
          ),
          const _SectionHeader(title: 'Support'),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Send Feedback'),
            onTap: () => Navigator.pushNamed(context, '/feedback'),
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
