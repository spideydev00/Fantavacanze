import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/core/utils/sort_by_date.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/local/clear_local_cache.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/get_user_leagues.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_league_state.dart';

class AppLeagueCubit extends Cubit<AppLeagueState> {
  final GetUserLeagues _getUserLeagues;
  final SharedPreferences _prefs;
  final AppUserCubit _appUserCubit;
  final ClearLocalCache _clearLocalCache;

  // Key for storing selected league ID in shared preferences
  static const String _selectedLeagueKey = 'selected_league_id';

  AppLeagueCubit({
    required GetUserLeagues getUserLeagues,
    required SharedPreferences prefs,
    required AppUserCubit appUserCubit,
    required ClearLocalCache clearLocalCache,
  })  : _getUserLeagues = getUserLeagues,
        _prefs = prefs,
        _appUserCubit = appUserCubit,
        _clearLocalCache = clearLocalCache,
        super(AppLeagueInitial());

  // -----------------------------------------
  // F E T C H E S   U S E R   L E A G U E S
  // -----------------------------------------
  Future<void> getUserLeagues() async {
    // Check authentication state before trying to fetch leagues
    final userState = _appUserCubit.state;
    if (userState is! AppUserIsLoggedIn) {
      // User is not logged in or is in onboarding
      // Silently maintain the initial state without showing error
      return;
    }

    final res = await _getUserLeagues.call(NoParams());

    res.fold(
      (l) {
        debugPrint(
            "🧊 AppLeagueCubit - Errore nell'ottenimento delle leghe - ${l.message}");

        emit(AppLeagueInitial());
      },
      (leagues) {
        debugPrint("🧊 AppLeagueCubit - L'utente ha ${leagues.length} leghe");
        if (leagues.isEmpty) {
          emit(AppLeagueInitial());
        } else {
          _emitAppLeagueExists(leagues);
        }
      },
    );
  }

  // ----------------------------------
  // U P D A T E S   T H E   S T A T E
  // ----------------------------------
  void _emitAppLeagueExists(List<League> leagues) {
    if (leagues.isEmpty) {
      emit(AppLeagueInitial());
      return;
    }

    // Get saved league ID from preferences
    final savedLeagueId = _prefs.getString(_selectedLeagueKey);
    League selectedLeague;

    // If we have a saved league ID, try to find it in the current leagues list
    if (savedLeagueId != null) {
      final leagueIndex =
          leagues.indexWhere((league) => league.id == savedLeagueId);
      if (leagueIndex >= 0) {
        selectedLeague = leagues[leagueIndex];
      } else {
        selectedLeague = sortLeaguesByDate(leagues).first;
      }
    } else {
      selectedLeague = sortLeaguesByDate(leagues).first;
    }

    debugPrint(
        "🧊 AppLeagueCubit - Lega selezionata: ${selectedLeague.name} (ID: ${selectedLeague.id})");
    emit(AppLeagueExists(leagues: leagues, selectedLeague: selectedLeague));
  }

  // ---------------------------------
  // S E L E C T S   A   L E A G U E
  // ---------------------------------
  void selectLeague(League league) {
    final currentState = state;
    if (currentState is AppLeagueExists) {
      // Save selection to SharedPreferences
      _prefs.setString(_selectedLeagueKey, league.id);
      emit(currentState.copyWith(selectedLeague: league));

      debugPrint("✅ AppLeagueCubit - Nuova lega selezionata: ${league.name}");
    }
  }

  // ---------------------------------
  // S E L E C T S   A   L E A G U E
  // ---------------------------------
  void updateLeagues(League league) {
    if (state is AppLeagueExists) {
      // Create a new list with the updated league replacing the old one
      final currentState = state as AppLeagueExists;

      final updatedLeagues = currentState.leagues.map((existingLeague) {
        return existingLeague.id == league.id ? league : existingLeague;
      }).toList();

      // Call the existing implementation which should include persistence code
      emit(AppLeagueExists(leagues: updatedLeagues, selectedLeague: league));

      _prefs.setString(_selectedLeagueKey, league.id);

      debugPrint(
          '✅ AppLeagueCubit: Informazioni della lega ${league.name} aggiornate');
    }
  }

  // -----------------------------------------
  // C L E A R  S E L E C T E D   L E A G U E
  // -----------------------------------------
  void clearSelectedLeague() {
    final currentState = state;
    if (currentState is AppLeagueExists) {
      _prefs.remove(_selectedLeagueKey);
      emit(currentState.copyWith(selectedLeague: null));
    }
  }

  /// Clears all locally cached league data
  Future<void> clearCache() async {
    final res = await _clearLocalCache(NoParams());

    res.fold((failure) async {
      debugPrint(
          "❌ AppLeagueCubit - Errore nella pulizia della cache: ${failure.message}");

      await _prefs.remove(_selectedLeagueKey);

      emit(AppLeagueInitial());
      debugPrint(
          "🧊 AppLeagueCubit - Lega selezionata (SharedPreferences) resettata nonostante errore cache Hive.");
    }, (_) async {
      await _prefs.remove(_selectedLeagueKey);

      // Reset to initial state
      emit(AppLeagueInitial());
    });
  }
}
