import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/services/ad_helper.dart';
import 'package:flutter/material.dart';

// Change from extends to implements
class MockAdHelper implements AdHelper {
  final bool shouldThrowError;

  MockAdHelper({this.shouldThrowError = false});

  @override
  Future<bool> showRewardedAd(BuildContext context) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (shouldThrowError) {
      throw Exception('Mock ad failure');
    }

    return true;
  }

  @override
  void connectToUserCubit(AppUserCubit userCubit) {
    // TODO: implement connectToUserCubit
  }

  @override
  void disconnectFromUserCubit() {
    // TODO: implement disconnectFromUserCubit
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  Future<void> initialize() {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  Future<void> loadInterstitialAd() {
    // TODO: implement loadInterstitialAd
    throw UnimplementedError();
  }

  @override
  Future<void> loadRewardedAd() {
    // TODO: implement loadRewardedAd
    throw UnimplementedError();
  }

  @override
  void setPremiumStatus(bool isPremium) {
    // TODO: implement setPremiumStatus
  }

  @override
  Future<void> showInterstitialAd({bool ignoreTimeLimit = false}) {
    // TODO: implement showInterstitialAd
    throw UnimplementedError();
  }

  @override
  void startAdTimer(BuildContext context) {
    // TODO: implement startAdTimer
  }

  @override
  void stopAdTimer() {
    // TODO: implement stopAdTimer
  }
}
