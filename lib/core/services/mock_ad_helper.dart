import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/services/ad_helper.dart';
import 'package:flutter/material.dart';

class MockAdHelper implements AdHelper {
  final bool shouldThrowError;
  DateTime? _expiry;

  MockAdHelper({this.shouldThrowError = false});

  @override
  Future<bool> showRewardedAd(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1));
    if (shouldThrowError) throw Exception('Mock ad failure');
    return true;
  }

  @override
  bool isDrinkGamesSessionActive() {
    // per test, di default non è attiva
    return _expiry != null && DateTime.now().isBefore(_expiry!);
  }

  @override
  void grantDrinkGamesAccess() {
    // simuliamo i 15 minuti
    _expiry = DateTime.now().add(const Duration(minutes: 15));
  }

  @override
  void connectToUserCubit(AppUserCubit cubit) {}

  @override
  void disconnectFromUserCubit() {}

  @override
  Future<void> initialize() async => Future.value();

  @override
  Future<void> showInterstitialAd({bool ignoreInterval = false}) async {}

  @override
  void startAdTimer(BuildContext ctx) {}

  @override
  void stopAdTimer() {}

  @override
  void dispose() {}

  @override
  Future<bool> loadRewardedAd({int retryCount = 0}) {
    return Future.value(true);
  }
}
