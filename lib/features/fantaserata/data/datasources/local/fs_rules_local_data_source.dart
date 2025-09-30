import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:hive/hive.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/rule/fs_rule_model.dart';

abstract interface class FsRulesLocalDataSource {
  Future<List<FsRuleModel>> getCachedRules(
    String leagueId,
  );

  Future<void> cacheRules(
    String leagueId,
    List<FsRuleModel> rules,
  );

  Future<void> updateSingleRule(
    String leagueId,
    FsRuleModel updatedRule,
  );

  Future<void> clearRulesCache();
}

class FsRulesLocalDataSourceImpl implements FsRulesLocalDataSource {
  final Box<FsRuleModel> fsRulesBox;
  final AppUserCubit appUserCubit;

  const FsRulesLocalDataSourceImpl({
    required this.fsRulesBox,
    required this.appUserCubit,
  });

  String _getCacheKey(String userId, String leagueId) => '${userId}_$leagueId';

  /// Gets the current user ID from cache or cubit
  String? _getCurrentUserId() {
    final state = appUserCubit.state;
    if (state is AppUserIsLoggedIn) {
      return state.user.id;
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

  @override
  Future<List<FsRuleModel>> getCachedRules(
    String leagueId,
  ) async {
    try {
      final userId = _checkAuthentication();

      final cacheKey = _getCacheKey(userId, leagueId);
      final rules = fsRulesBox.values
          .where((rule) => rule.name.startsWith(cacheKey))
          .toList();
      return rules;
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheRules(
    String leagueId,
    List<FsRuleModel> rules,
  ) async {
    try {
      final userId = _checkAuthentication();
      final cacheKey = _getCacheKey(userId, leagueId);

      // Clear existing rules for this user/league
      await _clearUserLeagueRules(cacheKey);

      // Cache new rules with unique keys
      for (int i = 0; i < rules.length; i++) {
        final uniqueKey = '${cacheKey}_$i';
        await fsRulesBox.put(uniqueKey, rules[i]);
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> clearRulesCache() async {
    try {
      await fsRulesBox.clear();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> updateSingleRule(
    String leagueId,
    FsRuleModel updatedRule,
  ) async {
    try {
      final userId = _checkAuthentication();
      final cacheKey = _getCacheKey(userId, leagueId);

      // Get all existing rules for this user/league
      final existingRules = await getCachedRules(leagueId);

      // Find and update the specific rule
      final updatedRules = existingRules.map((rule) {
        if (rule.id == updatedRule.id) {
          return updatedRule;
        }
        return rule;
      }).toList();

      // Clear existing rules for this user/league
      await _clearUserLeagueRules(cacheKey);

      // Cache updated rules with unique keys
      for (int i = 0; i < updatedRules.length; i++) {
        final uniqueKey = '${cacheKey}_$i';
        await fsRulesBox.put(uniqueKey, updatedRules[i]);
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> _clearUserLeagueRules(String cacheKey) async {
    try {
      final keysToDelete = fsRulesBox.keys
          .where((key) => key.toString().startsWith(cacheKey))
          .toList();

      for (final key in keysToDelete) {
        await fsRulesBox.delete(key);
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
