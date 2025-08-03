int getReadingTime(String content) {
  final wordsCount = content.split(RegExp(r'\s+')).length;

  final double readingTime = wordsCount / 225;
  return readingTime.ceil();
}
