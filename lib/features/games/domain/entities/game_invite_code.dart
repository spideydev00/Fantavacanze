final _wordBombInviteCode = RegExp(r'\bW[A-Z0-9]{5}B\b');
final _gameInviteCode = RegExp(r'\b[A-Z0-9]{7}\b');

String? normalizeGameInviteCode(String value) {
  final upper = value.trim().toUpperCase();
  return _wordBombInviteCode.firstMatch(upper)?.group(0) ??
      _gameInviteCode.firstMatch(upper)?.group(0);
}

bool isExactGameInviteCode(String value) {
  final upper = value.trim().toUpperCase();
  return normalizeGameInviteCode(upper) == upper;
}
