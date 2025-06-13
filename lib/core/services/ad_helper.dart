import 'dart:async';
import 'dart:io';

import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/secrets/app_secrets.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  // Ad instances
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // Loading state tracking
  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;

  // Track if any ad is currently being displayed
  bool _isAnyAdShowing = false;

  // Timer for periodic ads
  Timer? _adTimer;
  DateTime? _lastAdShown;
  final Duration _minAdInterval = const Duration(minutes: 2);

  // Premium status handling
  bool _isPremiumUser = false;
  AppUserCubit? _userCubit;
  StreamSubscription? _userStatusSubscription;

  // Ad Unit IDs
  static String get interstitialAdUnitId {
    // Usa ID di test in modalità debug, altrimenti quelli di produzione.
    // if (kDebugMode) {
    //   return 'ca-app-pub-3940256099942544/1033173712';
    // }
    if (Platform.isAndroid) {
      return AppSecrets.androidInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return AppSecrets.iosInterstitialAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform for AdMob');
    }
  }

  static String get rewardedAdUnitId {
    // Usa ID di test in modalità debug, altrimenti quelli di produzione.
    // if (kDebugMode) {
    //   return 'ca-app-pub-3940256099942544/5224354917';
    // }
    if (Platform.isAndroid) {
      return AppSecrets.androidRewardedAdUnitId;
    } else if (Platform.isIOS) {
      return AppSecrets.iosRewardedAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform for AdMob');
    }
  }

  // --- Gestione Stato Premium ---
  void setPremiumStatus(bool isPremium) {
    _isPremiumUser = isPremium;
    if (isPremium) {
      stopAdTimer();
    }
  }

  void connectToUserCubit(AppUserCubit userCubit) {
    _userStatusSubscription?.cancel();
    _userCubit = userCubit;
    _updatePremiumStatus();
    _userStatusSubscription = userCubit.stream.listen((_) {
      _updatePremiumStatus();
    });
  }

  void _updatePremiumStatus() {
    if (_userCubit == null) return;
    final state = _userCubit!.state;
    if (state is AppUserIsLoggedIn) {
      setPremiumStatus(state.user.isPremium);
    } else {
      setPremiumStatus(false);
    }
  }

  void disconnectFromUserCubit() {
    _userStatusSubscription?.cancel();
    _userStatusSubscription = null;
    _userCubit = null;
  }

  // --- Caricamento Annunci ---

  // Load an interstitial ad
  Future<void> loadInterstitialAd() async {
    if (_isPremiumUser || _isInterstitialLoading || _interstitialAd != null) {
      return;
    }
    _isInterstitialLoading = true;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          // CORREZIONE: Log specifico per interstitial e reset corretto
          debugPrint('InterstitialAd failed to load: $error');
          _isInterstitialLoading = false;
          _interstitialAd?.dispose();
          _interstitialAd = null;
        },
      ),
    );
  }

  // Load a rewarded ad
  Future<void> loadRewardedAd() async {
    if (_isPremiumUser || _isRewardedLoading || _rewardedAd != null) return;
    _isRewardedLoading = true;

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          // CORREZIONE: Log e reset corretto
          debugPrint('RewardedAd failed to load: $error');
          _isRewardedLoading = false;
          _rewardedAd?.dispose();
          _rewardedAd = null;
        },
      ),
    );
  }

  // --- Mostra Annunci (Logica Corretta con Gestione Errori User-Friendly) ---
  // Show interstitial ad if available
  Future<void> showInterstitialAd({bool ignoreTimeLimit = false}) async {
    if (_isPremiumUser || _isAnyAdShowing) return;

    if (!ignoreTimeLimit && _lastAdShown != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAdShown!);
      if (timeSinceLastAd < _minAdInterval) {
        return;
      }
    }

    if (_interstitialAd == null) {
      await loadInterstitialAd();
      if (_interstitialAd == null) return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => _isAnyAdShowing = true,
      onAdDismissedFullScreenContent: (ad) {
        _isAnyAdShowing = false;
        _lastAdShown = DateTime.now();
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isAnyAdShowing = false;
        debugPrint('InterstitialAd failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
      },
    );

    await _interstitialAd!.show();
  }

  /// Mostra un annuncio con ricompensa.
  /// Se l'annuncio non è pronto, informa l'utente in modo non invasivo.
  /// Restituisce `true` solo se l'utente ha guadagnato la ricompensa.
  Future<bool> showRewardedAd(BuildContext context) async {
    if (_isAnyAdShowing) return false;

    if (_rewardedAd == null) {
      await loadRewardedAd();
      if (_rewardedAd == null) {
        // Mostra un messaggio gentile e non un errore bloccante.
        Fluttertoast.showToast(
          msg: "Nessun video disponibile, riprova più tardi",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: ColorPalette.info,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return false;
      }
    }

    final completer = Completer<bool>();
    bool userEarnedReward = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => _isAnyAdShowing = true,
      onAdDismissedFullScreenContent: (ad) {
        _isAnyAdShowing = false;
        _lastAdShown = DateTime.now();
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        if (!completer.isCompleted) completer.complete(userEarnedReward);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isAnyAdShowing = false;
        debugPrint('RewardedAd failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (_, reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        userEarnedReward = true;
      },
    );

    return completer.future;
  }

  // --- Funzioni di Inizializzazione e Timer (Logica migliorata) ---
  void startAdTimer(BuildContext context) {
    if (_isPremiumUser) return;
    _adTimer?.cancel();
    _adTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_isPremiumUser) {
        stopAdTimer();
        return;
      }
      if (MediaQuery.of(context).viewInsets.bottom > 0) return;
      showInterstitialAd();
    });
  }

  void stopAdTimer() {
    _adTimer?.cancel();
    _adTimer = null;
  }

  // Initialize ads
  Future<void> initialize() async {
    if (_isPremiumUser) return;
    await Future.wait([
      loadInterstitialAd(),
      loadRewardedAd(),
    ]);
  }

  // Clean up resources
  void dispose() {
    stopAdTimer();
    disconnectFromUserCubit();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
