class MediaUtils {
  static bool isVideoUrl(String url) {
    final lowercaseUrl = url.toLowerCase();
    return lowercaseUrl.contains('.mp4') ||
        lowercaseUrl.contains('.mov') ||
        lowercaseUrl.contains('.avi') ||
        lowercaseUrl.contains('.mkv') ||
        lowercaseUrl.contains('.webm') ||
        lowercaseUrl.contains('video');
  }

  static bool isImageUrl(String url) {
    final lowercaseUrl = url.toLowerCase();
    return lowercaseUrl.contains('.jpg') ||
        lowercaseUrl.contains('.jpeg') ||
        lowercaseUrl.contains('.png') ||
        lowercaseUrl.contains('.gif') ||
        lowercaseUrl.contains('image');
  }
}
