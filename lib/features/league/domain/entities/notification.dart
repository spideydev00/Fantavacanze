import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String type;
  final String leagueId;

  const Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.type,
    required this.leagueId,
  });

  @override
  List<Object?> get props =>
      [id, title, message, createdAt, isRead, type, leagueId];
}
