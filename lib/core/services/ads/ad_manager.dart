import 'dart:async';

import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/secrets/app_secrets.dart';
// APP_OPEN_DISABLED 2026-07-10: riattivare scommentando questo import.
// import 'package:fantavacanze_official/core/services/ads/app_open_ad_manager.dart';
import 'package:fantavacanze_official/core/services/ads/feature_access_session.dart';
import 'package:fantavacanze_official/core/services/ads/interstitial_ad_manager.dart';
import 'package:fantavacanze_official/core/services/ads/rewarded_ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Facade unica per gli ads: coordina manager, premium e sessione feature.
class AdManager {
  AdManager._internal();
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;

  final InterstitialAdManager _interstitial = InterstitialAdManager();
  final RewardedAdManager _rewarded = RewardedAdManager();
  // APP_OPEN_DISABLED 2026-07-10: riattivare scommentando questo campo e tutti
  // i riferimenti `_appOpen` marcati sotto.
  // final AppOpenAdManager _appOpen = AppOpenAdManager();
  final FeatureAccessSession session = FeatureAccessSession();

  StreamSubscription? _userSub;
  bool _isLoggedIn = false;
  bool _isPremium = false;

  bool get canShowAds => _isLoggedIn && !_isPremium;
  bool get isPremium => _isPremium;

  Future<void> initialize() async {
    if (!canShowAds) return;
    await MobileAds.instance.initialize();

    // Test device: solo iPhone (IDFA in AppSecrets). Su iOS la GMA SDK accetta
    // l'IDFA in testDeviceIds → quel telefono vede test ads anche con gli ad
    // unit reali (evita invalid traffic). Su Android si resta sui test ad unit.
    // I placeholder (es. "YOUR_IDFA") vengono ignorati.
    final testDeviceIds = [
      AppSecrets.iosTestDevice,
    ].where((id) => id.isNotEmpty && !id.startsWith('YOUR')).toList();
    if (testDeviceIds.isNotEmpty) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: testDeviceIds),
      );
    }

    await Future.wait([
      _interstitial.load(),
      _rewarded.load(),
      // APP_OPEN_DISABLED 2026-07-10: riattivare aggiungendo `_appOpen.load(),`.
    ]);
  }

  void connectToUserCubit(AppUserCubit cubit) {
    _userSub?.cancel();
    _applyPremium(cubit.state);
    _userSub = cubit.stream.listen(_applyPremium);
  }

  void _applyPremium(AppUserState state) {
    final loggedIn = state is AppUserIsLoggedIn;
    final premium = loggedIn && state.user.isPremium;
    final adsBlocked = !loggedIn || premium;
    _isLoggedIn = loggedIn;
    _isPremium = premium;
    _interstitial.isPremium = adsBlocked;
    _rewarded.isPremium = adsBlocked;
    // APP_OPEN_DISABLED 2026-07-10: riattivare scommentando la riga sotto.
    // _appOpen.isPremium = adsBlocked;
    if (!canShowAds) _interstitial.stopTimer();
  }

  Future<void> showInterstitialAd({bool ignoreInterval = false}) {
    if (!canShowAds) return Future.value();
    return _interstitial.show(ignoreInterval: ignoreInterval);
  }

  void startInterstitialTimer(BuildContext context) {
    if (!canShowAds) return;
    _interstitial.startTimer(context);
  }

  void stopInterstitialTimer() {
    _interstitial.stopTimer();
  }

  Future<bool> showRewardedAd(BuildContext context) {
    if (!canShowAds) return Future.value(false);
    return _rewarded.show(context);
  }

  Future<bool> loadRewardedAd() {
    if (!canShowAds) return Future.value(false);
    return _rewarded.load();
  }

  // APP_OPEN_DISABLED 2026-07-10: no-op. Ancora chiamato da main.dart al resume,
  // ma non mostra più nulla. Per riattivare, ripristinare il corpo originale:
  //   if (!canShowAds) return Future.value();
  //   return _appOpen.showIfAvailable();
  Future<void> onAppResumed() => Future.value();

  void dispose() {
    _userSub?.cancel();
    _interstitial.dispose();
    _rewarded.dispose();
    // APP_OPEN_DISABLED 2026-07-10: riattivare scommentando la riga sotto.
    // _appOpen.dispose();
  }
}
