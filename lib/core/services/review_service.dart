import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/daily_challenges_bloc/daily_challenges_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/daily_challenges_bloc/daily_challenges_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/daily_challenges_bloc/daily_challenges_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fantavacanze_official/core/widgets/dialogs/app_review_dialog.dart';

class ReviewService {
  final SharedPreferences _preferences;
  final InAppReview _inAppReview;
  bool _hasRequestedReviewThisSession = false;

  // Key for storing last review request date
  static const String _lastReviewRequestDateKey = 'last_review_request_date';
  // Show review dialog every 3 days (in milliseconds)
  static const int _reviewInterval = 3 * 24 * 60 * 60 * 1000;

  // Constructor that accepts dependencies
  ReviewService({
    required SharedPreferences preferences,
    InAppReview? inAppReview,
  })  : _preferences = preferences,
        _inAppReview = inAppReview ?? InAppReview.instance;

  Future<void> checkAndRequestReview(
    BuildContext context,
    AppUserCubit userCubit,
    AppLeagueCubit leagueCubit,
  ) async {
    try {
      // Skip if already requested this session
      if (_hasRequestedReviewThisSession) return;

      final userState = userCubit.state;
      final leagueState = leagueCubit.state;

      if (userState is AppUserIsLoggedIn && leagueState is AppLeagueExists) {
        // Skip if user has already left a review
        if (userState.user.hasLeftReview) return;

        final lastRequestDate =
            _preferences.getInt(_lastReviewRequestDateKey) ?? 0;

        final now = DateTime.now().millisecondsSinceEpoch;

        // Only request once every 3 days at most
        //for testing simply put if(true)
        if (now - lastRequestDate > _reviewInterval) {
          final isAvailable = await _inAppReview.isAvailable();

          if (isAvailable) {
            // Mark as requested for this session
            _hasRequestedReviewThisSession = true;

            // Save last request date
            await _preferences.setInt(_lastReviewRequestDateKey, now);

            late dynamic result;

            if (context.mounted) {
              // Show custom review dialog
              result = await showDialog<bool>(
                context: context,
                builder: (_) => const AppReviewDialog(),
              );
            }

            // If user agreed to review
            if (result == true) {
              // Request the review
              await _inAppReview.requestReview();

              // Unlock the daily challenge in position 3
              Future.delayed(
                const Duration(seconds: 10),
                () {
                  if (context.mounted) {
                    _unlockDailyChallenge(
                      context,
                      userState.user.id,
                      leagueCubit,
                    );
                  }
                },
              );

              // Update the user's review status
              await userCubit.setHasLeftReview(true);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error requesting app review: $e');
    }
  }

  // Unlock the premium daily challenge
  void _unlockDailyChallenge(
    BuildContext context,
    String userId,
    AppLeagueCubit leagueCubit,
  ) {
    try {
      final leagueState = leagueCubit.state;

      if (leagueState is AppLeagueExists) {
        final String leagueId = leagueState.selectedLeague.id;

        // Get the challenges bloc
        final dailyChallengesBloc = context.read<DailyChallengesBloc>();
        final dailyChallengesState = dailyChallengesBloc.state;

        if (dailyChallengesState is DailyChallengesLoaded) {
          // Find the challenge in position 3
          final position3Challenge = dailyChallengesState.challenges
              .where((challenge) => challenge.position == 3)
              .firstOrNull;

          if (position3Challenge != null) {
            // Use the found challenge to unlock
            dailyChallengesBloc.add(
              UnlockDailyChallengeEvent(
                challenge: position3Challenge,
                leagueId: leagueId,
                userId: userId,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error unlocking daily challenge: $e');
    }
  }
}
