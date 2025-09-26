import 'package:hive/hive.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/fantaserata/data/models/rule/fs_rule_model.dart';

abstract interface class FsDynamicRulesLocalDataSource {
  Future<List<FsRuleModel>> getCachedDynamicRules(
    String userId,
    String leagueId,
  );

  Future<void> cacheDynamicRules(
    String userId,
    String leagueId,
    List<FsRuleModel> rules,
  );

  Future<void> updateSingleRule(
    String userId,
    String leagueId,
    FsRuleModel updatedRule,
  );

  Future<void> clearDynamicRulesCache();
}

class FsDynamicRulesLocalDataSourceImpl
    implements FsDynamicRulesLocalDataSource {
  final Box<FsRuleModel> fsDynamicRulesBox;

  const FsDynamicRulesLocalDataSourceImpl({required this.fsDynamicRulesBox});

  String _getCacheKey(String userId, String leagueId) => '${userId}_$leagueId';

  @override
  Future<List<FsRuleModel>> getCachedDynamicRules(
      String userId, String leagueId) async {
    try {
      final cacheKey = _getCacheKey(userId, leagueId);
      final rules = fsDynamicRulesBox.values
          .where((rule) => rule.name.startsWith(cacheKey))
          .toList();
      return rules;
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheDynamicRules(
    String userId,
    String leagueId,
    List<FsRuleModel> rules,
  ) async {
    try {
      final cacheKey = _getCacheKey(userId, leagueId);

      // Clear existing rules for this user/league
      await _clearUserLeagueRules(cacheKey);

      // Cache new rules with unique keys
      for (int i = 0; i < rules.length; i++) {
        final uniqueKey = '${cacheKey}_$i';
        await fsDynamicRulesBox.put(uniqueKey, rules[i]);
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> clearDynamicRulesCache() async {
    try {
      await fsDynamicRulesBox.clear();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> updateSingleRule(
    String userId,
    String leagueId,
    FsRuleModel updatedRule,
  ) async {
    try {
      final cacheKey = _getCacheKey(userId, leagueId);

      // Get all existing rules for this user/league
      final existingRules = await getCachedDynamicRules(userId, leagueId);

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
        await fsDynamicRulesBox.put(uniqueKey, updatedRules[i]);
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Future<void> _clearUserLeagueRules(String cacheKey) async {
    try {
      final keysToDelete = fsDynamicRulesBox.keys
          .where((key) => key.toString().startsWith(cacheKey))
          .toList();

      for (final key in keysToDelete) {
        await fsDynamicRulesBox.delete(key);
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
