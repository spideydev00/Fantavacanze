import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule_completion.dart';
import 'package:hive/hive.dart';

part 'fs_rule_completion_model.g.dart';

@HiveType(typeId: 21)
class FsRuleCompletionModel extends FsRuleCompletion {
  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  String get userId => super.userId;

  @HiveField(2)
  @override
  String? get userName => super.userName;

  @HiveField(3)
  @override
  String get leagueId => super.leagueId;

  @HiveField(4)
  @override
  String get challengeId => super.challengeId;

  @HiveField(5)
  @override
  String get name => super.name;

  @HiveField(6)
  @override
  double get points => super.points;

  @HiveField(7)
  @override
  FsRuleType get type => super.type;

  @HiveField(8)
  @override
  int? get position => super.position;

  @HiveField(9)
  @override
  bool get isDynamic => super.isDynamic;

  @HiveField(10)
  @override
  DateTime get completedAt => super.completedAt;

  const FsRuleCompletionModel({
    required super.id,
    required super.userId,
    super.userName,
    required super.leagueId,
    required super.challengeId,
    required super.name,
    required super.points,
    required super.type,
    super.position,
    super.isDynamic = false,
    required super.completedAt,
  });

  factory FsRuleCompletionModel.fromJson(Map<String, dynamic> json) {
    return FsRuleCompletionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String?,
      leagueId: json['league_id'] as String,
      challengeId: json['challenge_id'] as String,
      name: json['name'] as String,
      points: (json['points'] as num).toDouble(),
      type: (json['type'] as String).toLowerCase() == 'bonus'
          ? FsRuleType.bonus
          : FsRuleType.malus,
      position: json['position'] as int?,
      isDynamic: json['is_dynamic'] as bool? ?? false,
      completedAt: DateTime.parse(json['completed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'league_id': leagueId,
      'challenge_id': challengeId,
      'name': name,
      'points': points,
      'type': type.name,
      'position': position,
      'is_dynamic': isDynamic,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}
