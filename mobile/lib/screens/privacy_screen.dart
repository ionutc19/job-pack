import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.privacyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(
            title: l.privacyDataProcessing,
            body: l.privacyDataProcessingBody,
          ),
          _Section(
            title: l.privacyAiUsage,
            body: l.privacyAiUsageBody,
          ),
          _Section(
            title: l.privacyDataStorage,
            body: l.privacyDataStorageBody,
          ),
          _Section(
            title: l.privacySubscriptions,
            body: l.privacySubscriptionsBody,
          ),
          _Section(
            title: l.privacyThirdParty,
            body: l.privacyThirdPartyBody,
          ),
          _Section(
            title: l.privacyContact,
            body: l.privacyContactBody,
          ),
          const SizedBox(height: 24),
          Text(
            l.privacyLastUpdated,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
