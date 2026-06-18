import 'package:flutter/foundation.dart';

class AdConfig {
  static const String _admobAppId = String.fromEnvironment(
    'ADMOB_APP_ID',
    defaultValue: '',
  );

  static const String _bannerAdUnitId = String.fromEnvironment(
    'ADMOB_BANNER_ID',
    defaultValue: '',
  );

  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  static bool get adsEnabled {
    if (kDebugMode) return true;
    return _admobAppId.isNotEmpty && _bannerAdUnitId.isNotEmpty;
  }

  static String get bannerAdUnitId {
    if (kDebugMode) {
      return _bannerAdUnitId.isNotEmpty
          ? _bannerAdUnitId
          : _testBannerAdUnitId;
    }
    return _bannerAdUnitId;
  }

  static String get appId => _admobAppId;
}
