import 'package:equatable/equatable.dart';

class DailyChallenge extends Equatable {
  final String id;
  final String name;
  final double points;
  final bool isCompleted;
  final bool isRefreshed;
  final DateTime refreshedAt;
  final DateTime? completedAt;
  final int position; // New field for position

  const DailyChallenge({
    required this.id,
    required this.name,
    required this.points,
    this.isCompleted = false,
    this.isRefreshed = false,
    required this.refreshedAt,
    this.completedAt,
    required this.position, // Make it required
  });

  @override
  List<Object?> get props => [
        id,
        name,
        points,
        isCompleted,
        isRefreshed,
        refreshedAt,
        completedAt,
        position, // Add to props
      ];
}
