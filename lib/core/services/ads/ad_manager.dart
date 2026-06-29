import 'dart:async';

import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/services/ads/app_open_ad_manager.dart';
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
  final AppOpenAdManager _appOpen = AppOpenAdManager();
  final FeatureAccessSession session = FeatureAccessSession();

  StreamSubscription? _userSub;
  bool _isPremium = false;
  bool get isPremium => _isPremium;

  Future<void> initialize() async {
    if (_isPremium) return;
    await MobileAds.instance.initialize();
    await Future.wait([
      _interstitial.load(),
      _rewarded.load(),
      _appOpen.load(),
    ]);
  }

  void connectToUserCubit(AppUserCubit cubit) {
    _userSub?.cancel();
    _applyPremium(cubit.state);
    _userSub = cubit.stream.listen(_applyPremium);
  }

  void _applyPremium(AppUserState state) {
    final premium = state is AppUserIsLoggedIn && state.user.isPremium;
    _isPremium = premium;
    _interstitial.isPremium = premium;
    _rewarded.isPremium = premium;
    _appOpen.isPremium = premium;
    if (premium) _interstitial.stopTimer();
  }

  Future<void> showInterstitialAd({bool ignoreInterval = false}) {
    return _interstitial.show(ignoreInterval: ignoreInterval);
  }

  void startInterstitialTimer(BuildContext context) {
    _interstitial.startTimer(context);
  }

  void stopInterstitialTimer() {
    _interstitial.stopTimer();
  }

  Future<bool> showRewardedAd(BuildContext context) {
    return _rewarded.show(context);
  }

  Future<bool> loadRewardedAd() {
    return _rewarded.load();
  }

  Future<void> onAppResumed() {
    return _appOpen.showIfAvailable();
  }

  void dispose() {
    _userSub?.cancel();
    _interstitial.dispose();
    _rewarded.dispose();
    _appOpen.dispose();
  }
}
