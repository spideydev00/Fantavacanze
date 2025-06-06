class DailyChallenge {
  final String id;
  final String userId;
  final String leagueId;
  final String tableChallengeId;
  final String name;
  final double points;
  final bool isCompleted;
  final bool isRefreshed;
  final DateTime refreshedAt;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int position;
  final bool isUnlocked;

  const DailyChallenge({
    required this.id,
    required this.name,
    required this.points,
    required this.userId,
    required this.leagueId,
    required this.tableChallengeId,
    required this.isCompleted,
    required this.isRefreshed,
    required this.refreshedAt,
    required this.createdAt,
    required this.completedAt,
    required this.position,
    required this.isUnlocked,
  });

  DailyChallenge copyWith({
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
    bool? isUnlocked,
  }) {
    return DailyChallenge(
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
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
