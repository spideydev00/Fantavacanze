import 'package:flutter/foundation.dart';
import 'package:fantavacanze_official/core/utils/media/media_utils.dart';

@immutable
class FsMemory {
  final String id;
  final String imageUrl;
  final String description;
  final DateTime createdAt;
  final String userId;
  final String participantName;
  final String? relatedEventId;
  final String? eventName;

  const FsMemory({
    required this.id,
    required this.imageUrl,
    required this.description,
    required this.createdAt,
    required this.userId,
    required this.participantName,
    this.relatedEventId,
    this.eventName,
  });

  // Helper getters
  bool get isVideo => MediaUtils.isVideoUrl(imageUrl);
  bool get isImage => MediaUtils.isImageUrl(imageUrl);

  String get mediaUrl => imageUrl;
}
