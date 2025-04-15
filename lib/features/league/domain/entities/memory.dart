import 'package:flutter/foundation.dart';

@immutable
class Memory {
  final String id;
  final String imageUrl;
  final String text;
  final String? relatedEventId; // This field is already present and correct
  final DateTime createdAt;
  final String userId;

  const Memory({
    required this.id,
    required this.imageUrl,
    required this.text,
    required this.createdAt,
    required this.userId,
    this.relatedEventId, // It's also included in the constructor correctly
  });
}
