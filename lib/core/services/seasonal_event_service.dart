import 'package:fantavacanze_official/core/entities/fs_league/fs_night_type.dart';

class SeasonalEventService {
  FsNightType? _cachedNightType;
  DateTime? _lastCacheUpdate;
  DateTime? _manualTestDate; // For testing purposes

  /// Get current night type with daily cache
  FsNightType getCurrentNightType() {
    final now = _getItalianTime();

    // Check if cache is valid (same day)
    if (_cachedNightType != null &&
        _lastCacheUpdate != null &&
        _isSameDay(now, _lastCacheUpdate!)) {
      return _cachedNightType!;
    }

    // Calculate current night type
    _cachedNightType = _calculateCurrentNightType(now);
    _lastCacheUpdate = now;

    return _cachedNightType!;
  }

  /// Set manual test date for testing seasonal functionality
  void setTestDate(DateTime testDate) {
    _manualTestDate = testDate;
    // Clear cache to force recalculation
    clearCache();
  }

  /// Clear manual test date and return to real date
  void clearTestDate() {
    _manualTestDate = null;
    clearCache();
  }

  /// Check if we're in test mode
  bool get isInTestMode => _manualTestDate != null;

  /// Get the current test date if set
  DateTime? get currentTestDate => _manualTestDate;

  /// Check if it's Halloween (October 31st only)
  bool isHalloween() {
    final now = _getItalianTime();
    return now.month == 10 && now.day == 31;
  }

  /// Check if it's Christmas Eve (December 24th only)
  bool isChristmasEve() {
    final now = _getItalianTime();
    return now.month == 12 && now.day == 24;
  }

  /// Check if it's Carnival
  /// TODO: Set specific carnival date when available
  bool isCarnival() {
    final now = _getItalianTime();

    return now.year == 2026 && now.month == 2 && now.day == 16;
  }

  /// Check if it's New Year's Eve (December 31st only)
  bool isNewYearEve() {
    final now = _getItalianTime();
    return now.month == 12 && now.day == 31;
  }

  /// Check if it's Après Ski season (December 1st - March 31st)
  bool isApresSki() {
    final now = _getItalianTime();
    return (now.month == 12 || now.month == 1);
  }

  /// Clear cache (useful for testing or manual refresh)
  void clearCache() {
    _cachedNightType = null;
    _lastCacheUpdate = null;
  }

  // Private methods

  DateTime _getItalianTime() {
    // If in test mode, use the manual date
    if (_manualTestDate != null) {
      return _manualTestDate!;
    }

    final utcNow = DateTime.now().toUtc();
    final isDST = _isDaylightSavingTime(utcNow);
    final offset = isDST ? 2 : 1;
    return utcNow.add(Duration(hours: offset));
  }

  bool _isDaylightSavingTime(DateTime utcDate) {
    // DST in Italy: last Sunday in March to last Sunday in October
    final year = utcDate.year;
    final dstStart = _getLastSunday(year, 3);
    final dstEnd = _getLastSunday(year, 10);

    return utcDate.isAfter(dstStart) && utcDate.isBefore(dstEnd);
  }

  DateTime _getLastSunday(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0);
    final daysUntilSunday = (lastDay.weekday % 7);
    return DateTime(year, month, lastDay.day - daysUntilSunday);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  FsNightType _calculateCurrentNightType(DateTime now) {
    // Priority order for specific days/seasons
    if (isNewYearEve()) return FsNightType.newYearsEve;
    if (isHalloween()) return FsNightType.halloween;
    if (isChristmasEve()) return FsNightType.christmas;
    if (isCarnival()) return FsNightType.carnival;
    if (isApresSki()) return FsNightType.apresSki;

    return FsNightType.def;
  }

  // /// Calculate Easter date using the algorithm
  // DateTime _calculateEaster(int year) {
  //   final a = year % 19;
  //   final b = year ~/ 100;
  //   final c = year % 100;
  //   final d = b ~/ 4;
  //   final e = b % 4;
  //   final f = (b + 8) ~/ 25;
  //   final g = (b - f + 1) ~/ 3;
  //   final h = (19 * a + b - d - g + 15) % 30;
  //   final i = c ~/ 4;
  //   final k = c % 4;
  //   final l = (32 + 2 * e + 2 * i - h - k) % 7;
  //   final m = (a + 11 * h + 22 * l) ~/ 451;
  //   final month = (h + l - 7 * m + 114) ~/ 31;
  //   final day = ((h + l - 7 * m + 114) % 31) + 1;

  //   return DateTime(year, month, day);
  // }
}
