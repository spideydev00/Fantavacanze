import 'package:fantavacanze_official/features/league/domain/entities/daily_challenge.dart';

class DailyChallengeModel extends DailyChallenge {
  const DailyChallengeModel({
    required super.id,
    required super.name,
    required super.points,
    super.isCompleted,
    super.isRefreshed,
    required super.refreshedAt,
    super.completedAt,
    required super.position, // Add to constructor
  });

  factory DailyChallengeModel.fromJson(Map<String, dynamic> json) {
    return DailyChallengeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      points: json['points'] is int
          ? (json['points'] as int).toDouble()
          : (json['points'] as num).toDouble(),
      isCompleted: json['is_completed'] as bool? ?? false,
      isRefreshed: json['is_refreshed'] as bool? ?? false,
      refreshedAt: json['refreshed_at'] != null
          ? DateTime.parse(json['refreshed_at'] as String)
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      position: json['position'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points,
      'is_completed': isCompleted,
      'is_refreshed': isRefreshed,
      'refreshed_at': refreshedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'position': position,
    };
  }

  DailyChallengeModel copyWith({
    String? id,
    String? name,
    double? points,
    bool? isCompleted,
    bool? isRefreshed,
    DateTime? refreshedAt,
    DateTime? completedAt,
    int? position,
  }) {
    return DailyChallengeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      points: points ?? this.points,
      isCompleted: isCompleted ?? this.isCompleted,
      isRefreshed: isRefreshed ?? this.isRefreshed,
      refreshedAt: refreshedAt ?? this.refreshedAt,
      completedAt: completedAt ?? this.completedAt,
      position: position ?? this.position,
    );
  }
}
