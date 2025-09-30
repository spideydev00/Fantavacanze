import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_league/get_fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_league/clear_fs_cache.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';

part 'app_fs_league_state.dart';

class AppFsLeagueCubit extends Cubit<AppFsLeagueState> {
  final GetFsLeague _getFsLeague;
  final ClearFsCache _clearFsCache;
  final AppUserCubit _appUserCubit;

  AppFsLeagueCubit({
    required GetFsLeague getFsLeague,
    required ClearFsCache clearFsCache,
    required AppUserCubit appUserCubit,
  })  : _getFsLeague = getFsLeague,
        _clearFsCache = clearFsCache,
        _appUserCubit = appUserCubit,
        super(AppFsLeagueInitial());

  /// Check if user has a Fantaserata league
  Future<void> checkFsLeague() async {
    final userState = _appUserCubit.state;

    if (userState is! AppUserIsLoggedIn) {
      emit(AppFsLeagueInitial());
      return;
    }

    try {
      final result = await _getFsLeague(NoParams());

      result.fold(
        (failure) {
          // On failure, assume no league exists
          emit(AppFsLeagueNotExists());
        },
        (league) {
          if (league == null) {
            emit(AppFsLeagueNotExists());
          } else {
            // User has a Fantaserata league
            emit(AppFsLeagueExists(league));
          }
        },
      );
    } catch (e) {
      // On error, assume no league exists
      emit(AppFsLeagueNotExists());
    }
  }

  /// Set league exists state
  void setFsLeagueExists(FsLeague league) {
    emit(AppFsLeagueExists(league));
  }

  /// Set league not exists state
  void setFsLeagueNotExists() {
    emit(AppFsLeagueNotExists());
  }

  /// Check if user currently has a Fantaserata league
  bool hasFsLeague() {
    return state is AppFsLeagueExists;
  }

  /// Get current league if exists
  FsLeague? getCurrentFsLeague() {
    final currentState = state;
    if (currentState is AppFsLeagueExists) {
      return currentState.league;
    }
    return null;
  }

  /// Clear cached Fantaserata league data
  Future<void> clearCache() async {
    final result = await _clearFsCache(NoParams());

    result.fold(
      (failure) {
        // On failure, still reset to initial state
        emit(AppFsLeagueNotExists());
      },
      (_) {
        // On success, reset to initial state
        emit(AppFsLeagueNotExists());
      },
    );
  }
}
