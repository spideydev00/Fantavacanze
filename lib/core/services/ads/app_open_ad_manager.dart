import 'package:fantavacanze_official/core/services/ads/ad_config.dart';
import 'package:fantavacanze_official/core/services/ads/app_open_policy.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Gestisce gli app-open ad: load con retry e show solo se consentito.
class AppOpenAdManager {
  AppOpenAdManager({AppOpenPolicy? policy})
      : _policy = policy ??
            AppOpenPolicy(
              minInterval: AdConfig.appOpenMinInterval,
              maxAge: AdConfig.appOpenMaxAge,
            );

  final AppOpenPolicy _policy;
  AppOpenAd? _ad;
  bool _loading = false;
  bool isPremium = false;
  bool isAnyAdShowing = false;

  Future<void> load({int attempt = 0}) async {
    if (isPremium || _loading || _ad != null) return;
    _loading = true;
    await AppOpenAd.load(
      adUnitId: AdConfig.appOpenUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
          _policy.markLoaded();
        },
        onAdFailedToLoad: (err) {
          debugPrint('AppOpen load fallito (tentativo $attempt): $err');
          _loading = false;
          if (attempt + 1 < AdConfig.adLoadMaxRetries) {
            Future.delayed(AdConfig.adLoadBaseBackoff * (1 << attempt), () {
              load(attempt: attempt + 1);
            });
          }
        },
      ),
    );
  }

  Future<void> showIfAvailable() async {
    if (!_policy.canShow(
        isPremium: isPremium, otherAdShowing: isAnyAdShowing)) {
      if (_ad == null) load();
      return;
    }

    final ad = _ad;
    if (ad == null) {
      load();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        isAnyAdShowing = true;
        _policy.markShown();
      },
      onAdDismissedFullScreenContent: (ad) {
        isAnyAdShowing = false;
        ad.dispose();
        _ad = null;
        _policy.clear();
        load();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        isAnyAdShowing = false;
        debugPrint('AppOpen show fallito: $err');
        ad.dispose();
        _ad = null;
        _policy.clear();
        load();
      },
    );

    await ad.show();
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}
