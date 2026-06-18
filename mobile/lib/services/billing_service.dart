import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'service_locator.dart';

const _kPremiumId = 'jobcoach_premium_monthly';
const _kProId = 'jobcoach_pro_monthly';
const _kProductIds = {_kPremiumId, _kProId};

enum BillingState { idle, loading, purchasing, restoring, unavailable }

class BillingService extends ChangeNotifier {
  static final BillingService _instance = BillingService._();
  factory BillingService() => _instance;
  BillingService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  BillingState _state = BillingState.idle;
  BillingState get state => _state;

  bool _available = false;
  bool get available => _available;

  final Map<String, ProductDetails> _products = {};
  Map<String, ProductDetails> get products => Map.unmodifiable(_products);

  String? _error;
  String? get error => _error;

  String? _lastPurchasedTier;
  String? get lastPurchasedTier => _lastPurchasedTier;

  Future<void> initialize() async {
    _available = await _iap.isAvailable();
    if (!_available) {
      _state = BillingState.unavailable;
      notifyListeners();
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (error) {
        debugPrint('BillingService: purchase stream error: $error');
      },
    );

    await loadProducts();
  }

  Future<void> loadProducts() async {
    if (!_available) return;

    _state = BillingState.loading;
    _error = null;
    notifyListeners();

    final response = await _iap.queryProductDetails(_kProductIds);
    _products.clear();
    for (final product in response.productDetails) {
      _products[product.id] = product;
    }

    _state = BillingState.idle;
    notifyListeners();
  }

  Future<bool> purchase(String productId) async {
    final product = _products[productId];
    if (product == null) {
      _error = 'Product not found';
      notifyListeners();
      return false;
    }

    _state = BillingState.purchasing;
    _error = null;
    _lastPurchasedTier = null;
    notifyListeners();

    final param = PurchaseParam(productDetails: product);
    try {
      return await _iap.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      _state = BillingState.idle;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> restorePurchases() async {
    if (!_available) return;

    _state = BillingState.restoring;
    _error = null;
    notifyListeners();

    try {
      await _iap.restorePurchases();
    } catch (e) {
      _state = BillingState.idle;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyAndDeliver(purchase);
          break;
        case PurchaseStatus.error:
          _state = BillingState.idle;
          _error = purchase.error?.message ?? 'Purchase failed';
          notifyListeners();
          break;
        case PurchaseStatus.canceled:
          _state = BillingState.idle;
          _error = null;
          notifyListeners();
          break;
        case PurchaseStatus.pending:
          break;
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _verifyAndDeliver(PurchaseDetails purchase) async {
    try {
      final api = ServiceLocator().api;
      final result = await api.verifyPurchase(
        productId: purchase.productID,
        purchaseToken: purchase.verificationData.serverVerificationData,
      );

      _lastPurchasedTier = result['tier'] as String?;
      _state = BillingState.idle;
      _error = result['valid'] == true ? null : (result['message'] as String? ?? '');
      notifyListeners();
    } catch (e) {
      _state = BillingState.idle;
      _error = 'Verification failed: $e';
      notifyListeners();
    }
  }

  String? priceFor(String productId) {
    return _products[productId]?.price;
  }

  static String productIdForTier(String tier) {
    switch (tier) {
      case 'premium':
        return _kPremiumId;
      case 'pro':
        return _kProId;
      default:
        return '';
    }
  }

  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
