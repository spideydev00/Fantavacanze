import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge.dart';
import 'package:hive/hive.dart';

part 'daily_challenge_model.g.dart';

@HiveType(typeId: 1)
class DailyChallengeModel extends DailyChallenge {
  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  String get name => super.name;

  @HiveField(2)
  @override
  double get points => super.points;

  @HiveField(3)
  @override
  bool get isCompleted => super.isCompleted;

  @HiveField(4)
  @override
  DateTime? get completedAt => super.completedAt;

  @HiveField(5)
  @override
  bool get isRefreshed => super.isRefreshed;

  @HiveField(6)
  @override
  DateTime get refreshedAt => super.refreshedAt;

  @HiveField(7)
  @override
  int get position => super.position;

  @HiveField(8)
  @override
  String get userId => super.userId;

  @HiveField(9)
  @override
  String get leagueId => super.leagueId;

  @HiveField(10)
  @override
  String get tableChallengeId => super.tableChallengeId;

  @HiveField(11)
  @override
  DateTime get createdAt => super.createdAt;

  const DailyChallengeModel({
    required super.id,
    required super.userId,
    required super.leagueId,
    required super.tableChallengeId,
    required super.name,
    required super.points,
    required super.isCompleted,
    super.completedAt,
    required super.isRefreshed,
    required super.refreshedAt,
    required super.createdAt,
    required super.position,
  });

  factory DailyChallengeModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      leagueId: json['league_id'] as String,
      tableChallengeId: json['table_challenge_id'] as String,
      name: json['name'] as String,
      points: json['points'] is int
          ? (json['points'] as int).toDouble()
          : (json['points'] as num).toDouble(),
      isCompleted: json['is_completed'] as bool? ?? false,
      isRefreshed: json['is_refreshed'] as bool? ?? false,
      refreshedAt: json['refreshed_at'] != null
          ? DateTime.parse(json['refreshed_at'] as String)
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(), // Default to now if not provided
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      position: json['position'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'league_id': leagueId,
      'table_challenge_id': tableChallengeId,
      'name': name,
      'points': points,
      'is_completed': isCompleted,
      'is_refreshed': isRefreshed,
      'refreshed_at': refreshedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'position': position,
    };
  }

  DailyChallengeModel copyWith({
    String? id,
    String? userId,
    String? leagueId,
    String? tableChallengeId,
    String? name,
    double? points,
    bool? isCompleted,
    bool? isRefreshed,
    DateTime? refreshedAt,
    DateTime? createdAt,
    DateTime? completedAt,
    int? position,
  }) {
    return DailyChallengeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      leagueId: leagueId ?? this.leagueId,
      tableChallengeId: tableChallengeId ?? this.tableChallengeId,
      name: name ?? this.name,
      points: points ?? this.points,
      isCompleted: isCompleted ?? this.isCompleted,
      isRefreshed: isRefreshed ?? this.isRefreshed,
      refreshedAt: refreshedAt ?? this.refreshedAt,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      position: position ?? this.position,
    );
  }
}
