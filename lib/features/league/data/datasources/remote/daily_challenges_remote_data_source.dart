import 'dart:async';

import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/league/data/datasources/remote/league_remote_data_source.dart';
import 'package:fantavacanze_official/features/league/data/datasources/remote/notification_remote_data_source.dart';
import 'package:fantavacanze_official/features/league/data/models/daily_challenge_model/daily_challenge_model.dart';
import 'package:fantavacanze_official/features/league/data/models/league_model/league_model.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

abstract class DailyChallengesRemoteDataSource {
  Future<List<DailyChallengeModel>> getDailyChallenges({
    required String userId,
    required String leagueId,
  });

  Future<void> unlockDailyChallenge({
    required String challengeId,
    required bool isUnlocked,
    required String leagueId,
    int primaryPosition = 2,
  });

  Future<void> sendChallengeNotification({
    required LeagueModel league,
    required DailyChallengeModel challenge,
    required String userId,
  });

  Future<void> markChallengeAsCompleted({
    required DailyChallengeModel challenge,
    required LeagueModel league,
    required String userId,
  });

  Future<void> approveDailyChallenge(String notificationId);

  Future<void> rejectDailyChallenge(
    String notificationId,
    String challengeId,
  );

  Future<void> updateChallengeRefreshStatus({
    required String challengeId,
    required String userId,
    required bool isRefreshed,
  });
}

class DailyChallengesRemoteDataSourceImpl
    implements DailyChallengesRemoteDataSource {
  final SupabaseClient supabaseClient;
  final AppUserCubit appUserCubit;
  final LeagueRemoteDataSource leagueRemoteDataSource;
  final NotificationRemoteDataSource notificationRemoteDataSource;
  final Uuid uuid = const Uuid();

  DailyChallengesRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.appUserCubit,
    required this.leagueRemoteDataSource,
    required this.notificationRemoteDataSource,
  });

  // =====================================================================
  // HELPER METHODS - USER AUTHENTICATION & ERROR HANDLING
  // =====================================================================

  /// Extracts a clean error message from various exception types
  String _extractErrorMessage(Object e) {
    if (e is ServerException) return e.message;
    if (e is PostgrestException) return e.message;
    if (e is TimeoutException) return e.message ?? 'Operazione scaduta';
    return e.toString();
  }

  /// Gets the current user name from cache or cubit, never returns null
  String _getCurrentUserName() {
    // Try to get username from AppUserCubit
    final state = appUserCubit.state;
    if (state is AppUserIsLoggedIn) {
      return state.user.name;
    }

    return "Utente";
  }

  /// Wraps database operations to handle exceptions uniformly
  Future<T> _tryDatabaseOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      debugPrint('❌ Errore nella comunicazione col database: $e');
      throw ServerException(_extractErrorMessage(e));
    }
  }

  @override
  Future<List<DailyChallengeModel>> getDailyChallenges({
    required String userId,
    required String leagueId,
  }) async {
    return _tryDatabaseOperation(() async {
      // Call the RPC function to get challenges efficiently
      final response = await supabaseClient.rpc(
        'get_user_daily_challenges',
        params: {
          'p_user_id': userId,
          'p_league_id': leagueId,
        },
      );

      if (response == null) {
        throw ServerException('Impossibile recuperare le sfide giornaliere');
      }

      // Convert to models
      final List<dynamic> challengesJson = response as List<dynamic>;

      final result = challengesJson
          .map((json) => DailyChallengeModel.fromJson(json))
          .toList();

      return result;
    });
  }

  @override
  Future<void> unlockDailyChallenge({
    required String challengeId,
    required bool isUnlocked,
    required String leagueId,
    int primaryPosition = 2,
  }) async {
    return _tryDatabaseOperation(() async {
      // Calculate the substitute position (primary position + 3)
      final substitutePosition = primaryPosition + 3;

      // Use a new RPC function to unlock both challenges at once
      await supabaseClient.rpc(
        'unlock_daily_challenges',
        params: {
          'p_league_id': leagueId,
          'p_primary_position': primaryPosition,
          'p_substitute_position': substitutePosition,
          'p_is_unlocked': isUnlocked,
        },
      );
    });
  }

  @override
  Future<void> sendChallengeNotification({
    required LeagueModel league,
    required DailyChallengeModel challenge,
    required String userId,
  }) async {
    return _tryDatabaseOperation(() async {
      final now = DateTime.now();
      final userName = _getCurrentUserName();

      // Create notification data
      final notificationData = {
        'id': uuid.v4(),
        'title': 'Nuova sfida completata',
        'message': '$userName ha completato la sfida "${challenge.name}"',
        'created_at': now.toIso8601String(),
        'is_read': false,
        'type': 'daily_challenge',
        'user_id': userId,
        'league_id': league.id,
        'challenge_id': challenge.id,
        'challenge_name': challenge.name,
        'challenge_points': challenge.points,
        'target_user_ids': league.admins,
      };

      // Insert notification
      await supabaseClient
          .from('daily_challenges_notifications')
          .insert(notificationData);
    });
  }

  @override
  Future<void> markChallengeAsCompleted({
    required DailyChallengeModel challenge,
    required LeagueModel league,
    required String userId,
  }) async {
    return _tryDatabaseOperation(() async {
      // 1) Check if the user is an admin
      final isAdmin = league.admins.contains(userId);

      if (isAdmin) {
        // Admin completes challenge directly - Add event and update challenge status
        await leagueRemoteDataSource.addEvent(
          league: league,
          name: challenge.name,
          points: challenge.points,
          creatorId: userId,
          targetUser: userId,
          type: RuleType.bonus,
          isTeamMember: league.isTeamBased,
        );

        // Also update the challenge record to mark it as completed
        await supabaseClient.from('user_daily_challenges').update({
          'is_completed': true,
          'completed_at': DateTime.now().toIso8601String(),
        }).eq('id', challenge.id);
      } else {
        // Non-admin - send notification to admins for approval
        await sendChallengeNotification(
          league: league,
          challenge: challenge,
          userId: userId,
        );

        // Update challenge as pending approval
        await supabaseClient.from('user_daily_challenges').update({
          'is_pending_approval': true,
        }).eq('id', challenge.id);
      }
    });
  }

  @override
  Future<void> approveDailyChallenge(String notificationId) async {
    return _tryDatabaseOperation(() async {
      final eventId = uuid.v4();

      // Call the RPC function with just the notification ID and necessary parameters
      await supabaseClient.rpc(
        'approve_daily_challenge',
        params: {
          'p_notification_id': notificationId,
          'p_created_at': DateTime.now().toIso8601String(),
          'p_event_id': eventId,
        },
      );
    });
  }

  @override
  Future<void> rejectDailyChallenge(
      String notificationId, String challengeId) async {
    return _tryDatabaseOperation(() async {
      // 1. If we have a challenge ID, update its pending status
      await supabaseClient.from('user_daily_challenges').update({
        'is_pending_approval': false,
      }).eq('id', challengeId);

      // 3. Delete the notification
      await notificationRemoteDataSource.deleteNotification(notificationId);
    });
  }

  @override
  Future<void> updateChallengeRefreshStatus({
    required String challengeId,
    required String userId,
    required bool isRefreshed,
  }) async {
    return _tryDatabaseOperation(
      () async {
        // Update the challenge refresh status in the database
        await supabaseClient
            .from('user_daily_challenges')
            .update({
              'is_refreshed': isRefreshed,
              'refreshed_at': DateTime.now().toIso8601String(),
            })
            .eq('id', challengeId)
            .select();
      },
    );
  }
}
