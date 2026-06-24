import 'dart:io';

const int _bytesInMb = 1024 * 1024;

enum MediaSizeType {
  avatar(1),
  memoryPhoto(3),
  memoryVideo(50);

  const MediaSizeType(this.maxMegabytes);

  final int maxMegabytes;

  int get maxBytes => maxMegabytes * _bytesInMb;
}

String mediaSizeErrorMessage(MediaSizeType type) {
  return 'Il file selezionato è troppo grande (max ${type.maxMegabytes} MB).';
}

Future<bool> guardMediaSize({
  required File file,
  required MediaSizeType type,
  void Function(String message)? onTooLarge,
}) async {
  if (await file.length() <= type.maxBytes) return true;

  onTooLarge?.call(mediaSizeErrorMessage(type));
  return false;
}
