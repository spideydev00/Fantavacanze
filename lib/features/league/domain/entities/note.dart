import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String participantId;
  final String participantName;
  final String content;
  final DateTime createdAt;
  final String leagueId;

  const Note({
    required this.id,
    required this.participantId,
    required this.participantName,
    required this.content,
    required this.createdAt,
    required this.leagueId,
  });

  @override
  List<Object?> get props => [
        id,
        participantId,
        participantName,
        content,
        createdAt,
        leagueId,
      ];
}
