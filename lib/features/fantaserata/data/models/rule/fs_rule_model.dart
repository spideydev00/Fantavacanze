import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:hive/hive.dart';

part 'fs_rule_model.g.dart';

@HiveType(typeId: 13)
class FsRuleModel extends FsRule {
  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  String get userId => super.userId;

  @HiveField(2)
  @override
  String get leagueId => super.leagueId;

  @HiveField(3)
  @override
  String get challengeId => super.challengeId;

  @HiveField(4)
  @override
  String get name => super.name;

  @HiveField(5)
  @override
  double get points => super.points;

  @HiveField(6)
  @override
  FsRuleType get type => super.type;

  @HiveField(7)
  @override
  double get position => super.position;

  @HiveField(8)
  @override
  bool get isCompleted => super.isCompleted;

  @HiveField(9)
  @override
  bool get isRefreshed => super.isRefreshed;

  @HiveField(10)
  @override
  bool get isUnlocked => super.isUnlocked;

  FsRuleModel({
    required super.id,
    required super.userId,
    required super.leagueId,
    required super.challengeId,
    required super.name,
    required super.points,
    required super.type,
    required super.position,
    required super.isCompleted,
    required super.isRefreshed,
    required super.isUnlocked,
  });

  factory FsRuleModel.fromJson(Map<String, dynamic> json) {
    return FsRuleModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      leagueId: json['league_id'] as String,
      challengeId: json['challenge_id'] as String,
      name: json['name'] as String,
      points: (json['points'] as num).toDouble(),
      type: _parseRuleType(json['type'] as String),
      position: (json['position'] as num).toDouble(),
      isCompleted: json['is_completed'] as bool? ?? false,
      isRefreshed: json['is_refreshed'] as bool? ?? false,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
    );
  }

  /// Helper method to parse rule type from string
  static FsRuleType _parseRuleType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'bonus':
        return FsRuleType.bonus;
      case 'malus':
        return FsRuleType.malus;
      default:
        throw ArgumentError('Unknown rule type: $typeString');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'league_id': leagueId,
      'challenge_id': challengeId,
      'name': name,
      'points': points,
      'type': type.name,
      'position': position,
      'is_completed': isCompleted,
      'is_refreshed': isRefreshed,
      'is_unlocked': isUnlocked,
    };
  }

  factory FsRuleModel.fromEntity(FsRule rule) {
    return FsRuleModel(
      id: rule.id,
      userId: rule.userId,
      leagueId: rule.leagueId,
      challengeId: rule.challengeId,
      name: rule.name,
      points: rule.points,
      type: rule.type,
      position: rule.position,
      isCompleted: rule.isCompleted,
      isRefreshed: rule.isRefreshed,
      isUnlocked: rule.isUnlocked,
    );
  }
}
