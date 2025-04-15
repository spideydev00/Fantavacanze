import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/get_user_leagues.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_league_state.dart';

class AppLeagueCubit extends Cubit<AppLeagueState> {
  static const String _selectedLeagueIdKey = 'selected_league_id';
  final GetUserLeagues _getUserLeagues;
  final SharedPreferences _prefs;
  final AppUserCubit _appUserCubit;

  AppLeagueCubit({
    required GetUserLeagues getUserLeagues,
    required SharedPreferences prefs,
    required AppUserCubit appUserCubit,
  })  : _getUserLeagues = getUserLeagues,
        _prefs = prefs,
        _appUserCubit = appUserCubit,
        super(AppLeagueInitial());

  Future<void> getUserLeagues() async {
    final res = await _getUserLeagues.call(NoParams());

    res.fold(
      (l) {
        debugPrint("🧊AppLeagueCubit: Error fetching leagues - ${l.message}");
        emit(AppLeagueInitial());
      },
      (leagues) {
        debugPrint("🧊AppLeagueCubit: Got ${leagues.length} leagues");
        if (leagues.isEmpty) {
          emit(AppLeagueInitial());
        } else {
          loadSelectedLeague(leagues);
        }
      },
    );
  }

  void loadSelectedLeague(List<League> leagues) {
    if (leagues.isEmpty) {
      emit(AppLeagueInitial());
      return;
    }

    // Sort leagues by creation date (newest first)
    final sortedLeagues = List<League>.from(leagues)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final savedLeagueId = _prefs.getString(_selectedLeagueIdKey);

    League? selectedLeague;
    if (savedLeagueId != null) {
      final foundLeague = leagues
          .where(
            (league) => league.id == savedLeagueId,
          )
          .firstOrNull;

      selectedLeague = foundLeague ?? sortedLeagues.first;
    } else {
      selectedLeague = sortedLeagues.first;
    }

    emit(AppLeagueExists(leagues: leagues, selectedLeague: selectedLeague));
    _saveSelectedLeagueId(selectedLeague.id);
  }

  void selectLeague(League league) {
    final currentState = state;
    if (currentState is AppLeagueExists) {
      emit(currentState.copyWith(selectedLeague: league));
      _saveSelectedLeagueId(league.id);
    }
  }

  void clearSelectedLeague() {
    final currentState = state;
    if (currentState is AppLeagueExists) {
      emit(currentState.copyWith(selectedLeague: null));
      _prefs.remove(_selectedLeagueIdKey);
    }
  }

  void _saveSelectedLeagueId(String leagueId) {
    _prefs.setString(_selectedLeagueIdKey, leagueId);
  }

  /// Checks if the current user is an admin of the given league
  /// Returns true if the user is an admin, false otherwise
  bool isAdmin({String? leagueId}) {
    // Get current user ID
    final userState = _appUserCubit.state;
    if (userState is! AppUserIsLoggedIn) {
      return false;
    }

    final String userId = userState.user.id;

    // If no leagueId provided, check the currently selected league
    if (leagueId == null) {
      final currentState = state;
      if (currentState is AppLeagueExists &&
          currentState.selectedLeague != null) {
        return currentState.selectedLeague!.admins.contains(userId);
      }
      return false;
    }

    // If leagueId is provided, find that specific league
    final currentState = state;
    if (currentState is AppLeagueExists) {
      final league = currentState.leagues.firstWhere(
        (l) => l.id == leagueId,
        orElse: () => throw Exception('League not found'),
      );

      return league.admins.contains(userId);
    }

    return false;
  }
}
