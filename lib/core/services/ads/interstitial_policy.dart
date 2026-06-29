/// Decide se un interstitial può essere mostrato rispettando intervallo e cap.
class InterstitialPolicy {
  InterstitialPolicy({
    DateTime Function()? now,
    required this.minInterval,
    required this.maxPerSession,
  }) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final Duration minInterval;
  final int maxPerSession;

  DateTime? _lastShown;
  int _shownThisSession = 0;

  bool canShow() {
    if (_shownThisSession >= maxPerSession) return false;
    final last = _lastShown;
    if (last != null && _now().difference(last) < minInterval) return false;
    return true;
  }

  void markShown() {
    _lastShown = _now();
    _shownThisSession++;
  }
}
