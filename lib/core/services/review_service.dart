import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  final SharedPreferences _preferences;
  final InAppReview _inAppReview;
  bool _hasRequestedReviewThisSession = false;

  // Constructor that accepts dependencies
  ReviewService({
    required SharedPreferences preferences,
    InAppReview? inAppReview,
  })  : _preferences = preferences,
        _inAppReview = inAppReview ?? InAppReview.instance;

  Future<void> checkAndRequestReview(
    BuildContext context,
    AppUserCubit userCubit,
  ) async {
    try {
      // Skip if already requested this session
      if (_hasRequestedReviewThisSession) return;

      final userState = userCubit.state;

      if (userState is AppUserIsLoggedIn && !userState.user.hasLeftReview) {
        final lastRequestDate =
            _preferences.getInt('last_review_request_date') ?? 0;

        final now = DateTime.now().millisecondsSinceEpoch;

        // Only request once every 3 days at most
        if (now - lastRequestDate > 7 * 24 * 60 * 60 * 1000) {
          final isAvailable = await _inAppReview.isAvailable();

          if (isAvailable) {
            // Mark as requested for this session
            _hasRequestedReviewThisSession = true;

            // Save last request date
            await _preferences.setInt('last_review_request_date', now);

            // Mark user as having left review
            await userCubit.markReviewLeft();

            // Show review dialog
            await _inAppReview.requestReview();
          }
        }
      }
    } catch (e) {
      debugPrint('Error requesting app review: $e');
    }
  }

  // For testing purposes only
  void resetSessionFlag() {
    _hasRequestedReviewThisSession = false;
  }
}
