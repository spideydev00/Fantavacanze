import 'dart:io';

import 'package:fantavacanze_official/core/secrets/app_secrets.dart';

/// Configurazione centralizzata degli ads: ad unit id, intervalli e cap.
class AdConfig {
  AdConfig._();

  // FIXME: mettere a false prima del deploy.
  static bool get useTestAds => true;

  static const String _testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static String get _testAppOpen => Platform.isIOS
      ? 'ca-app-pub-3940256099942544/5575463023'
      : 'ca-app-pub-3940256099942544/9257395921';

  static String get interstitialUnitId {
    if (useTestAds) return _testInterstitial;
    if (Platform.isAndroid) return AppSecrets.androidInterstitialAdUnitId;
    if (Platform.isIOS) return AppSecrets.iosInterstitialAdUnitId;
    throw UnsupportedError('Piattaforma non supportata');
  }

  static String get rewardedUnitId {
    if (useTestAds) return _testRewarded;
    if (Platform.isAndroid) return AppSecrets.androidRewardedAdUnitId;
    if (Platform.isIOS) return AppSecrets.iosRewardedAdUnitId;
    throw UnsupportedError('Piattaforma non supportata');
  }

  static String get appOpenUnitId {
    if (useTestAds) return _testAppOpen;
    if (Platform.isAndroid) return AppSecrets.androidAppOpenAdUnitId;
    if (Platform.isIOS) return AppSecrets.iosAppOpenAdUnitId;
    throw UnsupportedError('Piattaforma non supportata');
  }

  static const Duration interstitialMinInterval = Duration(minutes: 2);
  static const int interstitialMaxPerSession = 5;
  static const Duration appOpenMinInterval = Duration(minutes: 4);
  static const Duration appOpenMaxAge = Duration(hours: 4);
  static const Duration gamesSessionDuration = Duration(minutes: 15);

  static const int adLoadMaxRetries = 3;
  static const Duration adLoadBaseBackoff = Duration(seconds: 2);
}
