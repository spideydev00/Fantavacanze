import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/entities/fs_league/fs_night_type.dart';
import 'package:fantavacanze_official/core/services/seasonal_event_service.dart';
import 'package:flutter/services.dart';

part 'seasonal_event_state.dart';

class SeasonalEventCubit extends Cubit<SeasonalEventState> {
  final SeasonalEventService _seasonalEventService;
  Timer? _midnightTimer;

  SeasonalEventCubit(this._seasonalEventService)
      : super(SeasonalEventState(FsNightType.def)) {
    _initializeSeasonalEvent();
    _setupMidnightRefresh();
    _setupAppLifecycleListener();
  }

  /// Initialize with current seasonal event
  void _initializeSeasonalEvent() {
    try {
      final currentNightType = _seasonalEventService.getCurrentNightType();
      emit(SeasonalEventState(currentNightType));
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing seasonal event: $e');
      }
      emit(SeasonalEventState(FsNightType.def));
    }
  }

  /// Setup timer to refresh at midnight
  void _setupMidnightRefresh() {
    _cancelMidnightTimer();

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now);

    _midnightTimer = Timer(durationUntilMidnight, () {
      refreshSeasonalEvent();
      _setupMidnightRefresh();
    });
  }

  /// Setup app lifecycle listener for when app resumes
  void _setupAppLifecycleListener() {
    SystemChannels.lifecycle.setMessageHandler((message) async {
      if (message == AppLifecycleState.resumed.toString()) {
        refreshSeasonalEvent();
      }
      return null;
    });
  }

  /// Manually refresh the seasonal event
  void refreshSeasonalEvent() {
    try {
      _seasonalEventService.clearCache();
      final currentNightType = _seasonalEventService.getCurrentNightType();

      if (state.activeNightType != currentNightType) {
        emit(SeasonalEventState(currentNightType));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing seasonal event: $e');
      }
      // Don't change state on error, keep current
    }
  }

  /// Force set a specific night type (useful for testing)
  void setNightType(FsNightType nightType) {
    emit(SeasonalEventState(nightType));
  }

  /// Check if a specific night type is currently active
  bool isNightTypeActive(FsNightType nightType) {
    return state.activeNightType == nightType;
  }

  /// Get current active night type
  FsNightType get currentNightType => state.activeNightType;

  void _cancelMidnightTimer() {
    _midnightTimer?.cancel();
    _midnightTimer = null;
  }

  @override
  Future<void> close() {
    _cancelMidnightTimer();
    return super.close();
  }
}
