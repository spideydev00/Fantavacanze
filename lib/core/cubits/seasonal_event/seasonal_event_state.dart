part of 'seasonal_event_cubit.dart';

class SeasonalEventState {
  final FsNightType activeNightType;

  const SeasonalEventState(this.activeNightType);

  /// Check if any seasonal event is active (not default)
  bool get hasActiveEvent => activeNightType != FsNightType.def;

  /// Get Italian display name for current night type
  String get displayName {
    switch (activeNightType) {
      case FsNightType.halloween:
        return 'Halloween';
      case FsNightType.christmas:
        return 'Natale';
      case FsNightType.carnival:
        return 'Carnevale';
      case FsNightType.newYearsEve:
        return 'Capodanno';
      case FsNightType.apresSki:
        return 'Après Ski';
      default:
        return 'Normale';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeasonalEventState &&
        other.activeNightType == activeNightType;
  }

  @override
  int get hashCode => activeNightType.hashCode;

  @override
  String toString() => 'SeasonalEventState(activeNightType: $activeNightType)';
}
