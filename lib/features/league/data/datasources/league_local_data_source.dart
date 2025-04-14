import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/features/league/data/models/league_model.dart';
import 'package:fantavacanze_official/features/league/data/models/rule_model.dart';
import 'package:hive/hive.dart';

abstract interface class LeagueLocalDataSource {
  Future<void> cacheLeagues(List<LeagueModel> leagues);
  Future<List<LeagueModel>> getCachedLeagues();

  Future<void> cacheLeague(LeagueModel league);
  Future<LeagueModel?> getCachedLeague(String leagueId);

  Future<void> cacheRules(List<RuleModel> rules, String mode);
  Future<List<RuleModel>> getCachedRules(String mode);
}

class LeagueLocalDataSourceImpl implements LeagueLocalDataSource {
  final Box<Map<dynamic, dynamic>> leaguesBox;
  final Box<Map<dynamic, dynamic>> rulesBox;

  LeagueLocalDataSourceImpl({
    required this.leaguesBox,
    required this.rulesBox,
  });

  @override
  Future<void> cacheLeagues(List<LeagueModel> leagues) async {
    try {
      final Map<String, dynamic> leaguesMap = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': leagues.map((league) => league.toJson()).toList(),
      };

      leaguesBox.write(() {
        leaguesBox.put('user_leagues', leaguesMap);
      });
    } catch (e) {
      throw CacheException(
          'Errore nel salvare le leghe in cache: ${e.toString()}');
    }
  }

  @override
  Future<List<LeagueModel>> getCachedLeagues() async {
    try {
      List<LeagueModel> leagues = [];

      leaguesBox.read(() {
        final leaguesData = leaguesBox.get('user_leagues');
        if (leaguesData != null) {
          final List<dynamic> leaguesList = leaguesData['data'] as List;
          leagues = leaguesList
              .map((league) =>
                  LeagueModel.fromJson(Map<String, dynamic>.from(league)))
              .toList();
        }
      });

      return leagues;
    } catch (e) {
      throw CacheException(
          'Errore nel recuperare le leghe dalla cache: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheLeague(LeagueModel league) async {
    try {
      final leagueData = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': league.toJson(),
      };

      leaguesBox.write(() {
        leaguesBox.put(league.id, leagueData);
      });
    } catch (e) {
      throw CacheException(
          'Errore nel salvare la lega in cache: ${e.toString()}');
    }
  }

  @override
  Future<LeagueModel?> getCachedLeague(String leagueId) async {
    try {
      LeagueModel? league;

      leaguesBox.read(() {
        final leagueData = leaguesBox.get(leagueId);
        if (leagueData != null) {
          league = LeagueModel.fromJson(
            Map<String, dynamic>.from(leagueData['data']),
          );
        }
      });

      return league;
    } catch (e) {
      throw CacheException(
          'Errore nel recuperare la lega dalla cache: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheRules(List<RuleModel> rules, String mode) async {
    try {
      final rulesData = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': rules.map((rule) => rule.toJson()).toList(),
      };

      rulesBox.write(() {
        rulesBox.put('rules_$mode', rulesData);
      });
    } catch (e) {
      throw CacheException(
          'Errore nel salvare le regole in cache: ${e.toString()}');
    }
  }

  @override
  Future<List<RuleModel>> getCachedRules(String mode) async {
    try {
      List<RuleModel> rules = [];

      rulesBox.read(() {
        final rulesData = rulesBox.get('rules_$mode');
        if (rulesData != null) {
          final List<dynamic> rulesList = rulesData['data'] as List;
          rules = rulesList
              .map(
                  (rule) => RuleModel.fromJson(Map<String, dynamic>.from(rule)))
              .toList();
        }
      });

      return rules;
    } catch (e) {
      throw CacheException(
          'Errore nel recuperare le regole dalla cache: ${e.toString()}');
    }
  }
}
