import 'package:fantavacanze_official/core/services/ads/feature_access_session.dart';
import 'package:flutter/material.dart';

/// Versione no-op di AdManager per i widget test.
class MockAdManager {
  final FeatureAccessSession session = FeatureAccessSession();

  Future<void> initialize() async {}

  void startInterstitialTimer(BuildContext context) {}

  void stopInterstitialTimer() {}

  Future<void> showInterstitialAd({bool ignoreInterval = false}) async {}

  Future<bool> showRewardedAd(BuildContext context) async => true;

  Future<bool> loadRewardedAd() async => true;

  Future<void> onAppResumed() async {}

  void dispose() {}
}
