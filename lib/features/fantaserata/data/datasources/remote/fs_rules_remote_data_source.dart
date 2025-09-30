import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_fs_league/app_fs_league_cubit.dart';
import 'package:fantavacanze_official/features/fantaserata/data/datasources/remote/fs_remote_data_source.dart';
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

  Future<FsRuleModel> setRuleAsCompleted({
    required String leagueId,
    required String challengeId,
    required String ruleName,
    required double points,
    required String type,
  });

  Future<FsRuleModel> setRuleAsUncompleted({
    required String leagueId,
    required String userId,
    required String challengeId,
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
  Future<FsRuleModel> setRuleAsCompleted({
    required String leagueId,
    required String challengeId,
    required String ruleName,
    required double points,
    required String type,
  }) async {
    return _tryDatabaseOperation(() async {
      final userId = _checkAuthentication();
      final userName = _getCurrentUserName();

      // Update rule completion
      final response = await supabaseClient
          .from('user_fs_rules')
          .update({
            'is_completed': true,
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('league_id', leagueId)
          .eq('challenge_id', challengeId)
          .select()
          .single();

      // Calculate points and bonus/malus based on rule type
      double pointsToAdd = points;
      double bonusToAdd = 0;
      double malusToAdd = 0;

      if (type.toLowerCase() == 'bonus') {
        bonusToAdd = points;
      } else if (type.toLowerCase() == 'malus') {
        malusToAdd = points;
        pointsToAdd = -points;
      }

      // Update participant points in fs_leagues table
      await fsRemoteDataSource.updateParticipantPoints(
        leagueId: leagueId,
        userId: userId,
        pointsToAdd: pointsToAdd,
        bonusToAdd: bonusToAdd,
        malusToAdd: malusToAdd,
      );

      return FsRuleModel.fromJson(response).copyWith(
        userName: userName,
      );
    });
  }

  @override
  Future<FsRuleModel> setRuleAsUncompleted({
    required String leagueId,
    required String userId,
    required String challengeId,
  }) async {
    return _tryDatabaseOperation(() async {
      // First, get the current rule to know how many points to subtract
      final currentRuleResponse = await supabaseClient
          .from('user_fs_rules')
          .select()
          .eq('user_id', userId)
          .eq('league_id', leagueId)
          .eq('challenge_id', challengeId)
          .single();

      final currentRule = FsRuleModel.fromJson(currentRuleResponse);

      // Update rule to uncompleted state
      final response = await supabaseClient
          .from('user_fs_rules')
          .update({
            'is_completed': false,
            'completed_at': null,
          })
          .eq('user_id', userId)
          .eq('league_id', leagueId)
          .eq('challenge_id', challengeId)
          .select()
          .single();

      // Calculate points to subtract (opposite of what was added)
      double pointsToSubtract = -currentRule.points;
      double bonusToSubtract = 0;
      double malusToSubtract = 0;

      if (currentRule.type == FsRuleType.bonus) {
        bonusToSubtract = -currentRule.points;
      } else if (currentRule.type == FsRuleType.malus) {
        malusToSubtract = -currentRule.points;
        pointsToSubtract = currentRule.points;
      }

      // Update participant points in fs_leagues table
      await fsRemoteDataSource.updateParticipantPoints(
        leagueId: leagueId,
        userId: userId,
        pointsToAdd: pointsToSubtract,
        bonusToAdd: bonusToSubtract,
        malusToAdd: malusToSubtract,
      );

      return FsRuleModel.fromJson(response);
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
}
