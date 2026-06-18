import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../l10n/app_localizations.dart';
import '../services/billing_service.dart';
import '../services/service_locator.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  String _currentTier = 'free';
  bool _loading = false;
  final _billing = BillingService();

  @override
  void initState() {
    super.initState();
    _billing.addListener(_onBillingUpdate);
    if (!AppConfig.useMockServices) {
      _fetchTier();
    }
  }

  @override
  void dispose() {
    _billing.removeListener(_onBillingUpdate);
    super.dispose();
  }

  void _onBillingUpdate() {
    if (!mounted) return;
    setState(() {});

    if (_billing.error != null && _billing.error!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_billing.error!)),
      );
    }

    if (_billing.lastPurchasedTier != null) {
      _fetchTier();
    }
  }

  Future<void> _fetchTier() async {
    setState(() => _loading = true);
    try {
      final data = await ServiceLocator().api.getEntitlements();
      if (mounted) {
        setState(() {
          _currentTier = data['tier'] as String? ?? 'free';
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onUpgrade(String tier) {
    if (!_billing.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).billingUnavailable),
        ),
      );
      return;
    }

    final productId = BillingService.productIdForTier(tier);
    _billing.purchase(productId);
  }

  void _onRestore() {
    _billing.restorePurchases();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final purchasing = _billing.state == BillingState.purchasing;
    final restoring = _billing.state == BillingState.restoring;

    return Scaffold(
      appBar: AppBar(title: Text(l.plans)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l.choosePlan,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l.plansSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 24),
          _PlanCard(
            title: l.planFree,
            price: l.planFreePrice,
            color: Colors.grey.shade700,
            features: [
              _Feature(l.planFreeAds, false),
              _Feature(l.planFreeRequests, true),
              _Feature(l.planFreeModules, true),
            ],
            isCurrent: _currentTier == 'free',
            currentLabel: l.currentPlan,
            loading: _loading,
          ),
          const SizedBox(height: 16),
          _PlanCard(
            title: l.planPremium,
            price: _billing.priceFor('jobcoach_premium_monthly') ?? l.planPremiumPrice,
            color: const Color(0xFF2563EB),
            features: [
              _Feature(l.planPremiumNoAds, true),
              _Feature(l.planPremiumRequests, true),
              _Feature(l.planPremiumModules, true),
            ],
            isCurrent: _currentTier == 'premium',
            currentLabel: l.currentPlan,
            actionLabel: _currentTier == 'premium' ? null : l.upgradeTo(l.planPremium),
            actionBusy: purchasing,
            onAction: () => _onUpgrade('premium'),
            loading: _loading,
          ),
          const SizedBox(height: 16),
          _PlanCard(
            title: l.planPro,
            price: _billing.priceFor('jobcoach_pro_monthly') ?? l.planProPrice,
            color: const Color(0xFF7C3AED),
            features: [
              _Feature(l.planProNoAds, true),
              _Feature(l.planProRequests, true),
              _Feature(l.planProModules, true),
              _Feature(l.planProFairUse, true),
            ],
            isCurrent: _currentTier == 'pro',
            currentLabel: l.currentPlan,
            actionLabel: _currentTier == 'pro' ? null : l.upgradeTo(l.planPro),
            actionBusy: purchasing,
            onAction: () => _onUpgrade('pro'),
            loading: _loading,
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: restoring ? null : _onRestore,
              child: Text(
                restoring ? l.restoringPurchases : l.restorePurchases,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Feature {
  final String text;
  final bool included;
  const _Feature(this.text, this.included);
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final Color color;
  final List<_Feature> features;
  final bool isCurrent;
  final String? currentLabel;
  final String? actionLabel;
  final bool actionBusy;
  final VoidCallback? onAction;
  final bool loading;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.color,
    required this.features,
    required this.isCurrent,
    this.currentLabel,
    this.actionLabel,
    this.actionBusy = false,
    this.onAction,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCurrent
            ? BorderSide(color: color, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                const Spacer(),
                if (isCurrent && currentLabel != null && !loading)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currentLabel!,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            ...features.map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        f.included ? Icons.check_circle : Icons.cancel,
                        size: 20,
                        color: f.included ? Colors.green : Colors.red.shade300,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          f.text,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
            if (!isCurrent && actionLabel != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: actionBusy ? null : onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                  child: actionBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
