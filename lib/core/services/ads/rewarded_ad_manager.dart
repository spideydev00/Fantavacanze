import 'dart:async';

import 'package:fantavacanze_official/core/services/ads/ad_config.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Gestisce il caricamento e la visualizzazione dei rewarded ad.
class RewardedAdManager {
  RewardedAd? _ad;
  bool _loading = false;
  bool isPremium = false;
  bool isAnyAdShowing = false;

  bool get isReady => _ad != null;

  Future<bool> load({int attempt = 0}) async {
    if (isPremium || _loading || _ad != null) return _ad != null;
    _loading = true;
    final completer = Completer<bool>();

    RewardedAd.load(
      adUnitId: AdConfig.rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
          completer.complete(true);
        },
        onAdFailedToLoad: (err) {
          debugPrint('Rewarded load fallito (tentativo $attempt): $err');
          _loading = false;
          if (attempt + 1 < AdConfig.adLoadMaxRetries) {
            Future.delayed(AdConfig.adLoadBaseBackoff * (1 << attempt), () {
              load(attempt: attempt + 1);
            });
          }
          completer.complete(false);
        },
      ),
    );

    return completer.future;
  }

  Future<bool> show(BuildContext context) async {
    if (isAnyAdShowing) return false;
    if (_ad == null) {
      await load();
      if (_ad == null) return false;
    }

    final completer = Completer<bool>();
    var earned = false;

    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => isAnyAdShowing = true,
      onAdDismissedFullScreenContent: (ad) {
        isAnyAdShowing = false;
        ad.dispose();
        _ad = null;
        load();
        completer.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        isAnyAdShowing = false;
        debugPrint('Rewarded show fallito: $err');
        ad.dispose();
        _ad = null;
        load();
        completer.complete(false);
      },
    );

    await _ad!.show(onUserEarnedReward: (_, __) => earned = true);
    return completer.future;
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}
