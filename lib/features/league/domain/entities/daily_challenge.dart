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
  final DateTime createdAt; // Added new field for creation time
  final DateTime? completedAt;
  final int position;

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
    required this.createdAt, // Added parameter
    required this.completedAt,
    required this.position,
  });
}
