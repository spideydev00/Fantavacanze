import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_fs_league/app_fs_league_cubit.dart';
import 'package:fantavacanze_official/features/fantaserata/data/datasources/remote/fs_remote_data_source.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/rule_completion/fs_rule_completion_model.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/rule/fs_rule_model.dart';

abstract interface class FsRulesRemoteDataSource {
  Future<FsRuleModel> refreshRule({
    required String leagueId,
    required String challengeId,
  });

  Future<FsRuleModel> unlockRule({
    required String leagueId,
    required String challengeId,
  });

  Future<Map<String, dynamic>> setRuleAsCompleted({
    required FsRuleModel rule,
  });

  Future<FsRuleModel> setRuleAsUncompleted({
    required FsRuleModel rule,
    String? completionId,
  });

  Future<List<FsRuleModel>> getUserRules({
    required String leagueId,
  });

  Future<List<FsRuleModel>> getLeagueRules({
    required String leagueId,
  });

  Future<List<FsRuleModel>> insertRulesForLeagueFromExisting({
    required String leagueId,
    required String name,
    required num points,
    required String typeText,
  });

  Future<FsRuleModel> lockRule({
    required String leagueId,
    required String challengeId,
  });

  Future<List<FsRuleCompletionModel>> getRuleCompletions({
    required String leagueId,
  });
}

class FsRulesRemoteDataSourceImpl implements FsRulesRemoteDataSource {
  final SupabaseClient supabaseClient;
  final AppUserCubit appUserCubit;
  final AppFsLeagueCubit appFsLeagueCubit;
  final FsRemoteDataSource fsRemoteDataSource;

  const FsRulesRemoteDataSourceImpl({
    required this.supabaseClient,
    required this.appUserCubit,
    required this.appFsLeagueCubit,
    required this.fsRemoteDataSource,
  });

  /// Extracts a clean error message from various exception types
  String _extractErrorMessage(Object e) {
    if (e is ServerException) return e.message;
    if (e is PostgrestException) return e.message;
    return e.toString();
  }

  /// Gets the current user ID from cache or cubit
  String? _getCurrentUserId() {
    final state = appUserCubit.state;
    if (state is AppUserIsLoggedIn) {
      return state.user.id;
    }
    return null;
  }

  /// Gets the current user ID from cache or cubit
  String? _getCurrentUserName() {
    final state = appUserCubit.state;
    if (state is AppUserIsLoggedIn) {
      return state.user.name;
    }
    return null;
  }

  /// Checks authentication and returns user ID or throws exception
  String _checkAuthentication() {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) {
      throw ServerException('Utente non autenticato');
    }
    return currentUserId;
  }

  /// Wraps database operations to handle exceptions uniformly
  Future<T> _tryDatabaseOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      debugPrint('❌ Errore nella comunicazione col database FS: $e');
      throw ServerException(_extractErrorMessage(e));
    }
  }

  @override
  Future<FsRuleModel> refreshRule({
    required String leagueId,
    required String challengeId,
  }) async {
    return _tryDatabaseOperation(() async {
      final userId = _checkAuthentication();

      final response = await supabaseClient.rpc('refresh_fs_rule', params: {
        'p_user_id': userId,
        'p_league_id': leagueId,
        'p_challenge_id': challengeId,
      }).single();

      return FsRuleModel.fromJson(response);
    });
  }

  @override
  Future<FsRuleModel> unlockRule({
    required String leagueId,
    required String challengeId,
  }) async {
    return _tryDatabaseOperation(() async {
      final userId = _checkAuthentication();

      final response = await supabaseClient
          .from('user_fs_rules')
          .update({'is_unlocked': true})
          .eq('user_id', userId)
          .eq('league_id', leagueId)
          .eq('challenge_id', challengeId)
          .select()
          .single();

      return FsRuleModel.fromJson(response);
    });
  }

  @override
  Future<Map<String, dynamic>> setRuleAsCompleted({
    required FsRuleModel rule,
  }) async {
    return _tryDatabaseOperation(() async {
      final userId = _checkAuthentication();
      final userName = _getCurrentUserName();

      final shouldMarkCompleted = rule.position <= 3;
      final completedAt = DateTime.now().toIso8601String();

      final isDynamic = rule.position >= 1 && rule.position <= 3;

      // Update rule completion
      final response = await supabaseClient
          .from('user_fs_rules')
          .update({
            'is_completed': shouldMarkCompleted,
            // Manteniamo sempre il timestamp di completamento per lo storico eventi,
            // ma lasciamo is_completed=false per le posizioni >=4 (ripetibili).
            'completed_at': completedAt,
          })
          .eq('user_id', userId)
          .eq('league_id', rule.leagueId)
          .eq('challenge_id', rule.challengeId)
          .select()
          .single();

      // Calculate points and bonus/malus based on rule type
      double pointsToAdd = rule.points;
      double bonusToAdd = 0;
      double malusToAdd = 0;

      final type = rule.type.name;

      if (type.toLowerCase() == 'bonus') {
        bonusToAdd = rule.points;
      } else if (type.toLowerCase() == 'malus') {
        malusToAdd = rule.points;
        pointsToAdd = -rule.points;
      }

      final Map<String, dynamic> completionResponse = await supabaseClient
          .from('user_fs_rule_completions')
          .insert({
            'user_id': userId,
            'user_name': userName,
            'league_id': rule.leagueId,
            'challenge_id': rule.challengeId,
            'name': rule.name,
            'type': type.toLowerCase(),
            'points': rule.points,
            'position': rule.position.toInt(),
            'is_dynamic': isDynamic,
            'completed_at': completedAt,
          })
          .select()
          .single();

      final completion = FsRuleCompletionModel.fromJson(completionResponse);

      // Update participant points in fs_leagues table
      await fsRemoteDataSource.updateParticipantPoints(
        leagueId: rule.leagueId,
        userId: userId,
        pointsToAdd: pointsToAdd,
        bonusToAdd: bonusToAdd,
        malusToAdd: malusToAdd,
      );

      final fsRule = FsRuleModel.fromJson(response).copyWith(
        userName: userName,
        completionId: completion.id,
      );

      return {
        'fsRule': fsRule,
        'completion': completion,
      };
    });
  }

  @override
  Future<FsRuleModel> setRuleAsUncompleted({
    required FsRuleModel rule,
    String? completionId,
  }) async {
    return _tryDatabaseOperation(() async {
      // Authentication is still required, but the completion belongs to the rule.owner
      _checkAuthentication();
      final targetUserId = rule.userId;

      // Update rule to uncompleted state
      final response = await supabaseClient
          .from('user_fs_rules')
          .update({
            'is_completed': false,
            'completed_at': null,
          })
          .eq('user_id', targetUserId)
          .eq('league_id', rule.leagueId)
          .eq('challenge_id', rule.challengeId)
          .select()
          .single();

      // Calculate points to subtract (opposite of what was added)
      double pointsToSubtract = -rule.points;
      double bonusToSubtract = 0;
      double malusToSubtract = 0;

      if (rule.type == FsRuleType.bonus) {
        bonusToSubtract = -rule.points;
      } else if (rule.type == FsRuleType.malus) {
        malusToSubtract = -rule.points;
        pointsToSubtract = rule.points;
      }

      // Update participant points in fs_leagues table
      await fsRemoteDataSource.updateParticipantPoints(
        leagueId: rule.leagueId,
        userId: targetUserId,
        pointsToAdd: pointsToSubtract,
        bonusToAdd: bonusToSubtract,
        malusToAdd: malusToSubtract,
      );

      // Delete the specific completion record from user_fs_rule_completions
      if (completionId != null) {
        await supabaseClient
            .from('user_fs_rule_completions')
            .delete()
            .eq('id', completionId);
      } else {
        await supabaseClient
            .from('user_fs_rule_completions')
            .delete()
            .eq('user_id', targetUserId)
            .eq('league_id', rule.leagueId)
            .eq('challenge_id', rule.challengeId);
      }

      return FsRuleModel.fromJson(response).copyWith(
        completionId: null,
        completedAt: null,
        isCompleted: false,
      );
    });
  }

  @override
  Future<List<FsRuleModel>> getUserRules({
    required String leagueId,
  }) async {
    return _tryDatabaseOperation(() async {
      final userId = _checkAuthentication();

      final response = await supabaseClient
          .from('user_fs_rules')
          .select('*, user_profile:profiles!user_fs_rules_user_id_fkey(name)')
          .eq('user_id', userId)
          .eq('league_id', leagueId)
          .order('position');

      final rules = (response as List<dynamic>)
          .map((rule) => FsRuleModel.fromJson(rule))
          .toList();

      return rules;
    });
  }

  @override
  Future<List<FsRuleModel>> getLeagueRules({
    required String leagueId,
  }) async {
    return _tryDatabaseOperation(() async {
      // Get ALL rules for the league, not filtered by user
      final response = await supabaseClient
          .from('user_fs_rules')
          .select('*, user_profile:profiles!user_fs_rules_user_id_fkey(name)')
          .eq('league_id', leagueId)
          .order('user_id')
          .order('position');

      final rules = (response as List<dynamic>)
          .map((rule) => FsRuleModel.fromJson(rule))
          .toList();

      debugPrint('✅ Fetched ${rules.length} rules for league $leagueId');

      return rules;
    });
  }

  @override
  Future<List<FsRuleModel>> insertRulesForLeagueFromExisting({
    required String leagueId,
    required String name,
    required num points,
    required String typeText,
  }) async {
    return _tryDatabaseOperation(() async {
      final response = await supabaseClient
          .rpc<List<dynamic>>('insert_rules_for_league_from_existing', params: {
        'p_league_id': leagueId,
        'p_name': name,
        'p_points': points,
        'p_type_text': typeText,
      }).select('*, user_profile:profiles!user_fs_rules_user_id_fkey(name)');

      final List<Map<String, dynamic>> rulesData =
          List<Map<String, dynamic>>.from(response);

      return rulesData.map((ruleMap) => FsRuleModel.fromJson(ruleMap)).toList();
    });
  }

  @override
  Future<FsRuleModel> lockRule({
    required String leagueId,
    required String challengeId,
  }) async {
    return _tryDatabaseOperation(() async {
      final userId = _checkAuthentication();

      final response = await supabaseClient
          .from('user_fs_rules')
          .update({'is_unlocked': false})
          .eq('user_id', userId)
          .eq('league_id', leagueId)
          .eq('challenge_id', challengeId)
          .select()
          .single();

      return FsRuleModel.fromJson(response);
    });
  }

  @override
  Future<List<FsRuleCompletionModel>> getRuleCompletions({
    required String leagueId,
  }) async {
    return _tryDatabaseOperation(() async {
      final response = await supabaseClient
          .from('user_fs_rule_completions')
          .select()
          .eq('league_id', leagueId)
          .order('completed_at', ascending: false);

      return (response as List<dynamic>)
          .map((item) =>
              FsRuleCompletionModel.fromJson(item as Map<String, dynamic>))
          .toList();
    });
  }
}
