import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/rule/fs_rule_model.dart';

abstract interface class FsDynamicRulesRemoteDataSource {
  Future<FsRuleModel> refreshRule({
    required String userId,
    required String leagueId,
    required String challengeId,
  });

  Future<FsRuleModel> unlockRule({
    required String userId,
    required String leagueId,
    required String challengeId,
  });

  Future<FsRuleModel> setRuleAsCompleted({
    required String userId,
    required String leagueId,
    required String challengeId,
    required String ruleName,
    required double points,
    required String type,
  });

  Future<List<FsRuleModel>> getUserDynamicRules({
    required String userId,
    required String leagueId,
  });
}

class FsDynamicRulesRemoteDataSourceImpl
    implements FsDynamicRulesRemoteDataSource {
  final SupabaseClient supabaseClient;

  const FsDynamicRulesRemoteDataSourceImpl({
    required this.supabaseClient,
  });

  @override
  Future<FsRuleModel> refreshRule({
    required String userId,
    required String leagueId,
    required String challengeId,
  }) async {
    return _tryDatabaseOperation(() async {
      final response = await supabaseClient
          .from('user_fs_dynamic_rules')
          .update({
            'is_refreshed': true,
            'refreshed_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('league_id', leagueId)
          .eq('challenge_id', challengeId)
          .select()
          .single();

      return FsRuleModel.fromJson(response);
    });
  }

  @override
  Future<FsRuleModel> unlockRule({
    required String userId,
    required String leagueId,
    required String challengeId,
  }) async {
    return _tryDatabaseOperation(() async {
      final response = await supabaseClient
          .from('user_fs_dynamic_rules')
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
    required String userId,
    required String leagueId,
    required String challengeId,
    required String ruleName,
    required double points,
    required String type,
  }) async {
    return _tryDatabaseOperation(() async {
      // Update rule completion
      final response = await supabaseClient
          .from('user_fs_dynamic_rules')
          .update({
            'is_completed': true,
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('league_id', leagueId)
          .eq('challenge_id', challengeId)
          .select()
          .single();

      return FsRuleModel.fromJson(response);
    });
  }

  @override
  Future<List<FsRuleModel>> getUserDynamicRules({
    required String userId,
    required String leagueId,
  }) async {
    return _tryDatabaseOperation(() async {
      final response = await supabaseClient
          .from('user_fs_dynamic_rules')
          .select('*')
          .eq('user_id', userId)
          .eq('league_id', leagueId)
          .order('position');

      final rules = (response as List<dynamic>)
          .map((rule) => FsRuleModel.fromJson(rule))
          .toList();

      return rules;
    });
  }

  /// Database operation wrapper with consistent error handling
  Future<T> _tryDatabaseOperation<T>(
    Future<T> Function() operation,
  ) async {
    try {
      return await operation();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
