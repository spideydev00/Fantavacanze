/// Identificatori delle sezioni gate-able.
const String kFeatureGames = 'games';
const String kFeatureGlobalRanking = 'global_ranking';

/// Tiene traccia degli accessi sbloccati: a tempo oppure per apertura app.
class FeatureAccessSession {
  FeatureAccessSession({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final Map<String, DateTime> _timed = {};
  final Set<String> _launchUnlocked = {};

  void grantTimed(String feature, Duration duration) {
    _timed[feature] = _now().add(duration);
  }

  void grantForLaunch(String feature) {
    _launchUnlocked.add(feature);
  }

  bool isActive(String feature) {
    if (_launchUnlocked.contains(feature)) return true;
    final expiry = _timed[feature];
    return expiry != null && _now().isBefore(expiry);
  }
}
