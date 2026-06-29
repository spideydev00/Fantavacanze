import 'dart:async';

import 'package:fantavacanze_official/core/services/ads/ad_config.dart';
import 'package:fantavacanze_official/core/services/ads/interstitial_policy.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Gestisce gli interstitial: load con retry, show con policy e timer.
class InterstitialAdManager {
  InterstitialAdManager({InterstitialPolicy? policy})
      : _policy = policy ??
            InterstitialPolicy(
              minInterval: AdConfig.interstitialMinInterval,
              maxPerSession: AdConfig.interstitialMaxPerSession,
            );

  final InterstitialPolicy _policy;
  InterstitialAd? _ad;
  bool _loading = false;
  bool isPremium = false;
  bool isAnyAdShowing = false;
  Timer? _timer;

  Future<void> load({int attempt = 0}) async {
    if (isPremium || _loading || _ad != null) return;
    _loading = true;
    await InterstitialAd.load(
      adUnitId: AdConfig.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
        },
        onAdFailedToLoad: (err) {
          debugPrint('Interstitial load fallito (tentativo $attempt): $err');
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

  Future<void> show({bool ignoreInterval = false}) async {
    if (isPremium || isAnyAdShowing) return;
    if (!ignoreInterval && !_policy.canShow()) return;

    if (_ad == null) {
      await load();
      if (_ad == null) return;
    }

    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        isAnyAdShowing = true;
        _policy.markShown();
      },
      onAdDismissedFullScreenContent: (ad) {
        isAnyAdShowing = false;
        ad.dispose();
        _ad = null;
        load();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        isAnyAdShowing = false;
        debugPrint('Interstitial show fallito: $err');
        ad.dispose();
        _ad = null;
        load();
      },
    );

    await _ad!.show();
  }

  void startTimer(BuildContext context) {
    if (isPremium) return;
    _timer?.cancel();
    _timer = Timer.periodic(AdConfig.interstitialMinInterval, (_) {
      if (!isPremium && MediaQuery.of(context).viewInsets.bottom == 0) {
        show();
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    stopTimer();
    _ad?.dispose();
    _ad = null;
  }
}
