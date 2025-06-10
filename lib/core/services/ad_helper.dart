import 'dart:io';
import 'dart:async';

import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:fantavacanze_official/core/secrets/app_secrets.dart';

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

  // Test Ad Unit IDs - Use these during development
  static String get testInterstitialAdUnitId {
    return 'ca-app-pub-3940256099942544/1033173712';
  }

  static String get testRewardedAdUnitId {
    return 'ca-app-pub-3940256099942544/5224354917';
  }

  // Production Ad Unit IDs - Use these for release
  static String get interstitialAdUnitId {
    // During development, always use test IDs
    // if (true) {
    //   // Change to a proper environment check later
    //   return testInterstitialAdUnitId;
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
    // // During development, always use test IDs
    // if (true) {
    //   // Change to a proper environment check later
    //   return testRewardedAdUnitId;
    // }

    if (Platform.isAndroid) {
      return AppSecrets.androidRewardedAdUnitId;
    } else if (Platform.isIOS) {
      return AppSecrets.iosRewardedAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform for AdMob');
    }
  }

  // Imposta lo stato premium dell'utente
  void setPremiumStatus(bool isPremium) {
    _isPremiumUser = isPremium;
    // Se l'utente è premium, ferma il timer degli annunci
    if (isPremium) {
      stopAdTimer();
    }
  }

  // Collega l'AdHelper al cubit dell'utente per monitorare i cambiamenti di stato premium
  void connectToUserCubit(AppUserCubit userCubit) {
    // Disattiva eventuali sottoscrizioni precedenti
    _userStatusSubscription?.cancel();

    _userCubit = userCubit;

    // Controlla immediatamente lo stato premium
    _updatePremiumStatus();

    // Ascolta i cambiamenti futuri
    _userStatusSubscription = userCubit.stream.listen((_) {
      _updatePremiumStatus();
    });
  }

  // Aggiorna lo stato premium in base al cubit dell'utente
  void _updatePremiumStatus() {
    if (_userCubit == null) return;

    final state = _userCubit!.state;
    if (state is AppUserIsLoggedIn) {
      setPremiumStatus(state.user.isPremium);
    } else {
      // Se l'utente non è loggato, consideriamo non premium
      setPremiumStatus(false);
    }
  }

  // Disattiva il collegamento al cubit quando non necessario
  void disconnectFromUserCubit() {
    _userStatusSubscription?.cancel();
    _userStatusSubscription = null;
    _userCubit = null;
  }

  // Load an interstitial ad
  Future<void> loadInterstitialAd() async {
    // Skip for premium users
    if (_isPremiumUser) return;

    if (_isInterstitialLoading || _interstitialAd != null) return;

    _isInterstitialLoading = true;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;

          // Setup full screen content callback
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _interstitialAd = null;
              ad.dispose();
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _interstitialAd = null;
              ad.dispose();
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isInterstitialLoading = false;
          // Retry after a delay
          Future.delayed(const Duration(minutes: 1), loadInterstitialAd);
        },
      ),
    );
  }

  // Load a rewarded ad
  Future<void> loadRewardedAd() async {
    if (_isRewardedLoading || _rewardedAd != null) return;

    _isRewardedLoading = true;

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;

          // Setup full screen content callback
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _rewardedAd = null;
              ad.dispose();
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _rewardedAd = null;
              ad.dispose();
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isRewardedLoading = false;
          // Retry after a delay
          Future.delayed(
            const Duration(minutes: 1),
            loadRewardedAd,
          );
        },
      ),
    );
  }

  // Show interstitial ad if available and enough time has passed
  Future<bool> showInterstitialAd({bool ignoreTimeLimit = true}) async {
    // Skip for premium users
    if (_isPremiumUser) return false;

    // Skip if another ad is currently showing
    if (_isAnyAdShowing) {
      return false;
    }

    // Check if enough time has passed since last ad
    if (!ignoreTimeLimit && _lastAdShown != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAdShown!);
      if (timeSinceLastAd < _minAdInterval) {
        return false;
      }
    }

    // Load ad if not available
    if (_interstitialAd == null) {
      await loadInterstitialAd();
      // Wait a moment for ad to load
      await Future.delayed(const Duration(seconds: 1));
      if (_interstitialAd == null) return false;
    }

    final completer = Completer<bool>();

    // Mark that an ad is now showing
    _isAnyAdShowing = true;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _lastAdShown = DateTime.now();
        _interstitialAd = null;
        ad.dispose();
        // Load a new ad immediately
        loadInterstitialAd();
        // Mark that no ad is showing anymore
        _isAnyAdShowing = false;
        completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _interstitialAd = null;
        ad.dispose();
        // Load a new ad immediately
        loadInterstitialAd();
        // Mark that no ad is showing anymore
        _isAnyAdShowing = false;
        completer.complete(false);
      },
    );

    await _interstitialAd!.show();
    return completer.future;
  }

  // Show rewarded ad and return true if user earned reward
  Future<bool> showRewardedAd() async {
    // Non skippiamo per gli utenti premium qui

    // Skip if another ad is currently showing
    if (_isAnyAdShowing) {
      return false;
    }

    if (_rewardedAd == null) {
      await loadRewardedAd();
      // Wait a moment for ad to load
      await Future.delayed(const Duration(seconds: 1));
      if (_rewardedAd == null) {
        return false;
      }
    }

    final completer = Completer<bool>();
    bool userEarnedReward = false;

    // Mark that an ad is now showing
    _isAnyAdShowing = true;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _lastAdShown = DateTime.now();
        _rewardedAd = null;
        ad.dispose();
        // Load a new ad immediately
        loadRewardedAd();
        // Mark that no ad is showing anymore
        _isAnyAdShowing = false;
        completer.complete(userEarnedReward);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _rewardedAd = null;
        ad.dispose();
        // Load a new ad immediately
        loadRewardedAd();
        // Mark that no ad is showing anymore
        _isAnyAdShowing = false;
        completer.complete(false);
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (_, reward) {
        userEarnedReward = true;
      },
    );

    return completer.future;
  }

  // Start timer for periodic interstitial ads
  void startAdTimer(BuildContext context) {
    // Skip for premium users
    if (_isPremiumUser) return;

    _adTimer?.cancel();

    // Check every minute, but only show ad every 2 minutes
    _adTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      // Skip if user became premium
      if (_isPremiumUser) {
        stopAdTimer();
        return;
      }

      // Skip if keyboard is open or current route is excluded
      if (MediaQuery.of(context).viewInsets.bottom > 0) {
        return;
      }

      if (_lastAdShown != null) {
        final timeSinceLastAd = DateTime.now().difference(_lastAdShown!);
        if (timeSinceLastAd >= _minAdInterval) {
          showInterstitialAd();
        }
      } else {
        // First time showing ad through the timer
        showInterstitialAd();
      }
    });
  }

  void stopAdTimer() {
    if (_adTimer != null) {
      _adTimer?.cancel();
      _adTimer = null;
    }
  }

  // Initialize ads
  Future<void> initialize() async {
    // Skip loading for premium users
    if (_isPremiumUser) return;

    // Load both types of ads immediately
    await loadInterstitialAd();
    await loadRewardedAd();
  }

  // Show both ads in sequence for premium content
  Future<bool> showSequentialAds() async {
    // First show interstitial
    bool interstitialShown = await showInterstitialAd();

    // Small delay between ads
    await Future.delayed(const Duration(milliseconds: 500));

    // Then show rewarded
    bool rewardEarned = await showRewardedAd();

    // Both must complete successfully
    return interstitialShown && rewardEarned;
  }

  // Show two rewarded ads in sequence for premium content
  Future<bool> showSequentialRewardedAds() async {
    debugPrint('🔄 Inizio sequenza rewarded ads');

    // Show first rewarded ad
    bool firstAdWatched = await showRewardedAd();

    if (!firstAdWatched) {
      return false;
    }

    // Wait for the second ad to load with timeout
    bool secondAdLoaded = false;
    int retryCount = 0;
    const maxRetries = 10;

    while (!secondAdLoaded && retryCount < maxRetries) {
      // Check if we have a rewarded ad ready
      if (_rewardedAd != null) {
        secondAdLoaded = true;
        break;
      }

      // Wait a bit before checking again
      await Future.delayed(const Duration(milliseconds: 500));
      retryCount++;
    }

    if (!secondAdLoaded) {
      return false;
    }

    // Now show the second rewarded ad
    bool secondAdWatched = await showRewardedAd();

    // Both must complete successfully
    final result = firstAdWatched && secondAdWatched;
    if (result) {
      debugPrint('✅ Sequenza completata');
    }

    return result;
  }

  // Clean up resources
  void dispose() {
    stopAdTimer();
    disconnectFromUserCubit();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
