import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final String leagueId;

  const Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.leagueId,
  });

  // Add copyWith method to create a new instance with updated fields
  Notification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    String? leagueId,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      leagueId: leagueId ?? this.leagueId,
    );
  }

  @override
  List<Object?> get props => [id, title, message, createdAt, leagueId];
}
