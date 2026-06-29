/// Decide se mostrare un app-open rispettando freshness, intervallo e guardie.
class AppOpenPolicy {
  AppOpenPolicy({
    DateTime Function()? now,
    required this.minInterval,
    required this.maxAge,
  }) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final Duration minInterval;
  final Duration maxAge;

  DateTime? _loadedAt;
  DateTime? _lastShown;

  void markLoaded() => _loadedAt = _now();
  void markShown() => _lastShown = _now();
  void clear() => _loadedAt = null;

  bool canShow({required bool isPremium, required bool otherAdShowing}) {
    if (isPremium || otherAdShowing) return false;
    final loaded = _loadedAt;
    if (loaded == null) return false;
    if (_now().difference(loaded) > maxAge) return false;
    final last = _lastShown;
    if (last != null && _now().difference(last) < minInterval) return false;
    return true;
  }
}
