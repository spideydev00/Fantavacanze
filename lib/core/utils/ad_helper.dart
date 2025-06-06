import 'dart:io';
import 'dart:async';

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

  // Timer for periodic ads
  Timer? _adTimer;
  DateTime? _lastAdShown;
  final Duration _minAdInterval = const Duration(minutes: 2);

  // Current route for checking exclusions
  String _currentRoute = '/';

  // Set of route names that should be excluded from showing recurring ads
  final Set<String> _excludedRoutes = {
    '/drink_games_selection',
  };

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
    if (true) {
      // Change to a proper environment check later
      return testInterstitialAdUnitId;
    }

    if (Platform.isAndroid) {
      return AppSecrets.androidInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return AppSecrets.iosInterstitialAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform for AdMob');
    }
  }

  static String get rewardedAdUnitId {
    // During development, always use test IDs
    if (true) {
      // Change to a proper environment check later
      return testRewardedAdUnitId;
    }

    if (Platform.isAndroid) {
      return AppSecrets.androidRewardedAdUnitId;
    } else if (Platform.isIOS) {
      return AppSecrets.iosRewardedAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform for AdMob');
    }
  }

  // Load an interstitial ad
  Future<void> loadInterstitialAd() async {
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
              debugPrint('❌ Errore nel mostrare l\'ad: $error');
              _interstitialAd = null;
              ad.dispose();
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('❌ Errore nel mostrare l\'ad: $error');
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
              debugPrint('❌ Errore nel mostrare l\'ad: $error');
              _rewardedAd = null;
              ad.dispose();
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('❌ Errore nel mostrare l\'ad: $error');
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
    // Check if enough time has passed since last ad
    if (!ignoreTimeLimit && _lastAdShown != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAdShown!);
      if (timeSinceLastAd < _minAdInterval) {
        debugPrint('❌ Impossibile mostrare: Troppo presto dopo l\'ultimo ad');
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

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _lastAdShown = DateTime.now();
        _interstitialAd = null;
        ad.dispose();
        loadInterstitialAd();
        completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _interstitialAd = null;
        ad.dispose();
        loadInterstitialAd();
        completer.complete(false);
      },
    );

    await _interstitialAd!.show();
    return completer.future;
  }

  // Show rewarded ad and return true if user earned reward
  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      await loadRewardedAd();
      // Wait a moment for ad to load
      await Future.delayed(const Duration(seconds: 1));
      if (_rewardedAd == null) return false;
    }

    final completer = Completer<bool>();
    bool userEarnedReward = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _lastAdShown = DateTime.now();
        _rewardedAd = null;
        ad.dispose();
        loadRewardedAd();
        completer.complete(userEarnedReward);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _rewardedAd = null;
        ad.dispose();
        loadRewardedAd();
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

  // Update current route safely
  void updateCurrentRoute(String? routeName) {
    if (routeName != null && routeName.isNotEmpty) {
      _currentRoute = routeName;
      debugPrint('🧭 Route updated: $_currentRoute');
    }
  }

  // Check if current route is excluded
  bool get isCurrentRouteExcluded {
    return _excludedRoutes.contains(_currentRoute);
  }

  // Add a route to the exclusion list - works with null safety
  void excludeRouteFromAds(String? routeName) {
    if (routeName != null && routeName.isNotEmpty) {
      _excludedRoutes.add(routeName);
      debugPrint('🚫 Route excluded from ads: $routeName');
    }
  }

  // Remove a route from the exclusion list - null safe
  void includeRouteInAds(String? routeName) {
    if (routeName != null && routeName.isNotEmpty) {
      _excludedRoutes.remove(routeName);
    }
  }

  // Start timer for periodic interstitial ads
  void startAdTimer(BuildContext context) {
    _adTimer?.cancel();

    // Check every minute, but only show ad every 2 minutes
    _adTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      // Skip if keyboard is open or current route is excluded
      if (MediaQuery.of(context).viewInsets.bottom > 0 ||
          isCurrentRouteExcluded) {
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
    _adTimer?.cancel();
    _adTimer = null;
  }

  // Initialize ads
  Future<void> initialize() async {
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
    // Show first rewarded ad
    bool firstAdWatched = await showRewardedAd();

    if (!firstAdWatched) return false;

    // Small delay between ads
    await Future.delayed(const Duration(milliseconds: 500));

    // Show second rewarded ad
    bool secondAdWatched = await showRewardedAd();

    // Both must complete successfully
    return firstAdWatched && secondAdWatched;
  }
}
