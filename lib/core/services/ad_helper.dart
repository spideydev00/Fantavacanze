import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/secrets/app_secrets.dart';

class AdHelper {
  static final AdHelper _instance = AdHelper._internal();
  factory AdHelper() => _instance;
  AdHelper._internal();

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;
  bool _isAnyAdShowing = false;

  Timer? _adTimer;
  final Duration _minAdInterval = const Duration(minutes: 2);
  DateTime? _lastAdShown;

  bool _isPremiumUser = false;
  StreamSubscription? _userSubscription;

  static const Duration _drinkGamesSessionDuration = Duration(minutes: 15);
  DateTime? _drinkGamesSessionExpiry;

  // Test Ad Unit IDs - Use these during development
  static String get testInterstitialAdUnitId {
    return 'ca-app-pub-3940256099942544/1033173712';
  }

  static String get testRewardedAdUnitId {
    return 'ca-app-pub-3940256099942544/5224354917';
  }

  // --- Ad Unit IDs ---
  static String get _interstitialUnitId {
    // if (true) {
    //   // Change to a proper environment check later
    //   return testInterstitialAdUnitId;
    // }
    if (Platform.isAndroid) return AppSecrets.androidInterstitialAdUnitId;
    if (Platform.isIOS) return AppSecrets.iosInterstitialAdUnitId;
    throw UnsupportedError('Unsupported platform');
  }

  static String get _rewardedUnitId {
    // if (true) {
    //   // Change to a proper environment check later
    //   return testRewardedAdUnitId;
    // }

    if (Platform.isAndroid) return AppSecrets.androidRewardedAdUnitId;
    if (Platform.isIOS) return AppSecrets.iosRewardedAdUnitId;
    throw UnsupportedError('Unsupported platform');
  }

  // --- Premium handling ---
  void connectToUserCubit(AppUserCubit cubit) {
    _userSubscription?.cancel();
    _updatePremium(cubit.state);
    _userSubscription = cubit.stream.listen(_updatePremium);
  }

  void _updatePremium(AppUserState state) {
    final isPremium = state is AppUserIsLoggedIn && state.user.isPremium;
    _isPremiumUser = isPremium;
    if (isPremium) stopAdTimer();
  }

  void disconnectFromUserCubit() {
    _userSubscription?.cancel();
  }

  // --- Initialization ---
  /// Da chiamare una sola volta, es. in main() o al login
  Future<void> initialize() async {
    if (_isPremiumUser) return;

    // 1) Inizializza AdMob
    await MobileAds.instance.initialize();

    // 2) Pre-carica entrambi gli annunci in parallelo
    await Future.wait([
      _loadInterstitialAd(),
      loadRewardedAd(),
    ]);
  }

  // --- Interstitial ---
  Future<void> _loadInterstitialAd() async {
    if (_isPremiumUser || _isInterstitialLoading || _interstitialAd != null) {
      return;
    }

    _isInterstitialLoading = true;
    await InterstitialAd.load(
      adUnitId: _interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (err) {
          debugPrint('Interstitial load failed: $err');
          _isInterstitialLoading = false;
          _interstitialAd!.dispose();
          _interstitialAd = null;
        },
      ),
    );
  }

  Future<void> showInterstitialAd({bool ignoreInterval = false}) async {
    if (_isPremiumUser || _isAnyAdShowing) return;
    if (!ignoreInterval && _lastAdShown != null) {
      if (DateTime.now().difference(_lastAdShown!) < _minAdInterval) return;
    }

    if (_interstitialAd == null) {
      await _loadInterstitialAd();
      if (_interstitialAd == null) return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _isAnyAdShowing = true,
      onAdDismissedFullScreenContent: (ad) {
        _isAnyAdShowing = false;
        _lastAdShown = DateTime.now();
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        _isAnyAdShowing = false;
        debugPrint('Interstitial show failed: $err');
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
      },
    );

    await _interstitialAd!.show();
  }

  // --- Rewarded ---
  /// Carica l’ad e restituisce `true` se il caricamento ha avuto successo
  Future<bool> loadRewardedAd() {
    if (_isPremiumUser || _isRewardedLoading || _rewardedAd != null) {
      return Future.value(_rewardedAd != null);
    }

    _isRewardedLoading = true;
    final completer = Completer<bool>();

    RewardedAd.load(
      adUnitId: _rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          completer.complete(true);
        },
        onAdFailedToLoad: (err) {
          debugPrint('Rewarded load failed: $err');
          _isRewardedLoading = false;
          _rewardedAd!.dispose();
          _rewardedAd = null;
          completer.complete(false);
        },
      ),
    );

    return completer.future;
  }

  /// Mostra l’ad solo dopo che `loadRewardedAd()` ha confermato la riuscita
  Future<bool> showRewardedAd(BuildContext ctx) async {
    if (_isAnyAdShowing) return false;

    final completer = Completer<bool>();

    bool earned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _isAnyAdShowing = true,
      onAdDismissedFullScreenContent: (ad) {
        _isAnyAdShowing = false;
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        completer.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        _isAnyAdShowing = false;
        debugPrint('Rewarded show failed: $err');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        completer.complete(true);
      },
    );

    await _rewardedAd!.show(onUserEarnedReward: (_, reward) {
      earned = true;
    });

    return completer.future;
  }

  // --- Periodic timer ---
  void startAdTimer(BuildContext ctx) {
    if (_isPremiumUser) return;
    _adTimer?.cancel();
    _adTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) {
        if (!_isPremiumUser && MediaQuery.of(ctx).viewInsets.bottom == 0) {
          showInterstitialAd();
        }
      },
    );
  }

  void stopAdTimer() {
    _adTimer?.cancel();
    _adTimer = null;
  }

  void dispose() {
    stopAdTimer();
    disconnectFromUserCubit();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }

  // --- Drink Games Session ---
  /// Chiama questo quando l’utente ottiene accesso con ads o premium
  void grantDrinkGamesAccess() {
    _drinkGamesSessionExpiry = DateTime.now().add(_drinkGamesSessionDuration);
  }

  /// Verifica se siamo ancora nella finestra di 15 minuti
  bool isDrinkGamesSessionActive() {
    return _drinkGamesSessionExpiry != null &&
        DateTime.now().isBefore(_drinkGamesSessionExpiry!);
  }
}
