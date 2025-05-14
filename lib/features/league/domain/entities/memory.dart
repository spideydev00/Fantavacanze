import 'package:flutter/foundation.dart';

@immutable
class Memory {
  final String id;
  final String imageUrl;
  final String text;
  final String? relatedEventId;
  final DateTime createdAt;
  final String userId;
  final String participantName;
  final String? eventName;

  const Memory({
    required this.id,
    required this.imageUrl,
    required this.text,
    required this.createdAt,
    required this.userId,
    required this.participantName,
    this.relatedEventId,
    this.eventName,
  });
}
