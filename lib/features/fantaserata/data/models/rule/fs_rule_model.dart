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

  @HiveField(11)
  @override
  DateTime get createdAt => super.createdAt;

  @HiveField(12)
  @override
  DateTime? get completedAt => super.completedAt;

  @HiveField(13)
  @override
  DateTime? get refreshedAt => super.refreshedAt;

  @HiveField(14)
  @override
  String? get userName => super.userName;

  @HiveField(15)
  @override
  String? get completionId => super.completionId;

  FsRuleModel({
    required super.id,
    required super.userId,
    super.userName,
    super.completionId,
    required super.leagueId,
    required super.challengeId,
    required super.name,
    required super.points,
    required super.type,
    required super.position,
    required super.isCompleted,
    required super.isRefreshed,
    required super.isUnlocked,
    required super.createdAt,
    super.completedAt,
    super.refreshedAt,
  });

  factory FsRuleModel.fromJson(Map<String, dynamic> json) {
    final userProfile = json['user_profile'] as Map<String, dynamic>?;

    return FsRuleModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: userProfile?['name'] as String?,
      leagueId: json['league_id'] as String,
      challengeId: json['challenge_id'] as String,
      name: json['name'] as String,
      points: (json['points'] as num).toDouble(),
      type: _parseRuleType(json['type'] as String),
      position: (json['position'] as num).toDouble(),
      isCompleted: json['is_completed'] as bool? ?? false,
      isRefreshed: json['is_refreshed'] as bool? ?? false,
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      refreshedAt: json['refreshed_at'] != null
          ? DateTime.parse(json['refreshed_at'] as String)
          : null,
      completionId: json['completion_id'] as String?,
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
      'user_name': userName,
      'league_id': leagueId,
      'challenge_id': challengeId,
      'name': name,
      'points': points,
      'type': type.name,
      'position': position,
      'is_completed': isCompleted,
      'is_refreshed': isRefreshed,
      'is_unlocked': isUnlocked,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'refreshed_at': refreshedAt?.toIso8601String(),
      'completion_id': completionId,
    };
  }

  factory FsRuleModel.fromEntity(FsRule rule) {
    return FsRuleModel(
      id: rule.id,
      userId: rule.userId,
      userName: rule.userName,
      leagueId: rule.leagueId,
      challengeId: rule.challengeId,
      name: rule.name,
      points: rule.points,
      type: rule.type,
      position: rule.position,
      isCompleted: rule.isCompleted,
      isRefreshed: rule.isRefreshed,
      isUnlocked: rule.isUnlocked,
      createdAt: rule.createdAt,
      completedAt: rule.completedAt,
      refreshedAt: rule.refreshedAt,
      completionId: rule.completionId,
    );
  }

  FsRuleModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? completionId,
    String? leagueId,
    String? challengeId,
    String? name,
    double? points,
    FsRuleType? type,
    double? position,
    bool? isCompleted,
    bool? isRefreshed,
    bool? isUnlocked,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? refreshedAt,
  }) {
    return FsRuleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      leagueId: leagueId ?? this.leagueId,
      challengeId: challengeId ?? this.challengeId,
      name: name ?? this.name,
      points: points ?? this.points,
      type: type ?? this.type,
      position: position ?? this.position,
      isCompleted: isCompleted ?? this.isCompleted,
      isRefreshed: isRefreshed ?? this.isRefreshed,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      refreshedAt: refreshedAt ?? this.refreshedAt,
      completionId: completionId ?? this.completionId,
    );
  }
}
