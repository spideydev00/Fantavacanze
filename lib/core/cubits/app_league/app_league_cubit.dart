import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/core/utils/sort_leagues_by_date.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/get_user_leagues.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_league_state.dart';

class AppLeagueCubit extends Cubit<AppLeagueState> {
  final GetUserLeagues _getUserLeagues;
  final SharedPreferences _prefs;

  // Key for storing selected league ID in shared preferences
  static const String _selectedLeagueKey = 'selected_league_id';

  AppLeagueCubit({
    required GetUserLeagues getUserLeagues,
    required SharedPreferences prefs,
  })  : _getUserLeagues = getUserLeagues,
        _prefs = prefs,
        super(AppLeagueInitial());

  // -----------------------------------------
  // F E T C H E S   U S E R   L E A G U E S
  // -----------------------------------------
  Future<void> getUserLeagues() async {
    final res = await _getUserLeagues.call(NoParams());

    res.fold(
      (l) {
        debugPrint("🧊AppLeagueCubit - Error fetching leagues - ${l.message}");
        emit(AppLeagueInitial());
      },
      (leagues) {
        debugPrint("🧊AppLeagueCubit - Got ${leagues.length} leagues");
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
        "🧊AppLeagueCubit: Selected league: ${selectedLeague.name} (ID: ${selectedLeague.id})");
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
}
