import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/core/utils/dates-and-numbers/sort_by_date.dart';
import 'package:fantavacanze_official/features/league/domain/entities/individual_participant.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/member_profile.dart';
import 'package:fantavacanze_official/features/league/domain/entities/team_participant.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/local/clear_local_cache.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/league/get_profile_images.dart';
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
  final GetProfileImages _getProfileImages;

  // Key for storing selected league ID in shared preferences
  static const String _selectedLeagueKey = 'selected_league_id';

  AppLeagueCubit({
    required GetUserLeagues getUserLeagues,
    required SharedPreferences prefs,
    required AppUserCubit appUserCubit,
    required ClearLocalCache clearLocalCache,
    required GetProfileImages getProfileImages,
  })  : _getUserLeagues = getUserLeagues,
        _prefs = prefs,
        _appUserCubit = appUserCubit,
        _clearLocalCache = clearLocalCache,
        _getProfileImages = getProfileImages,
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
      emit(AppLeagueInitial());
      return;
    }

    final res = await _getUserLeagues.call(NoParams());

    await res.fold(
      (l) async {
        debugPrint(
            "🧊 AppLeagueCubit - Errore nell'ottenimento delle leghe - ${l.message}");

        emit(AppLeagueInitial());
      },
      (leagues) async {
        debugPrint("🧊 AppLeagueCubit - L'utente ha ${leagues.length} leghe");
        if (leagues.isEmpty) {
          emit(AppLeagueInitial());
        } else {
          await _emitAppLeagueExists(leagues);
        }
      },
    );
  }

  // ----------------------------------
  // U P D A T E S   T H E   S T A T E
  // ----------------------------------
  Future<void> _emitAppLeagueExists(List<League> leagues) async {
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

    await _emitLeagueExistsWithProfileImages(
      leagues: leagues,
      selectedLeague: selectedLeague,
    );
  }

  // ---------------------------------
  // S E L E C T S   A   L E A G U E
  // ---------------------------------
  Future<void> selectLeague(League league) async {
    final currentState = state;
    if (currentState is AppLeagueExists) {
      // Save selection to SharedPreferences
      _prefs.setString(_selectedLeagueKey, league.id);
      await _emitLeagueExistsWithProfileImages(
        leagues: currentState.leagues,
        selectedLeague: league,
      );

      debugPrint("✅ AppLeagueCubit - Nuova lega selezionata: ${league.name}");
    }
  }

  // ---------------------------------
  // S E L E C T S   A   L E A G U E
  // ---------------------------------
  Future<void> updateLeagues(League league) async {
    if (state is AppLeagueExists) {
      // Create a new list with the updated league replacing the old one
      final currentState = state as AppLeagueExists;

      final updatedLeagues = currentState.leagues.map((existingLeague) {
        return existingLeague.id == league.id ? league : existingLeague;
      }).toList();

      // Call the existing implementation which should include persistence code
      await _emitLeagueExistsWithProfileImages(
        leagues: updatedLeagues,
        selectedLeague: league,
      );

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
      emit(AppLeagueInitial());
    }
  }

  /// Removes a league by ID and selects the most recent remaining one (if any)
  Future<void> removeLeagueById(String leagueId) async {
    final currentState = state;
    if (currentState is! AppLeagueExists) {
      return;
    }

    final remainingLeagues =
        currentState.leagues.where((league) => league.id != leagueId).toList();

    if (remainingLeagues.isEmpty) {
      _prefs.remove(_selectedLeagueKey);
      emit(AppLeagueInitial());
      return;
    }

    final sorted = sortLeaguesByDate(remainingLeagues);
    final selected = sorted.first;

    _prefs.setString(_selectedLeagueKey, selected.id);

    await _emitLeagueExistsWithProfileImages(
      leagues: remainingLeagues,
      selectedLeague: selected,
    );
  }

  String? getProfileImageFor(String userId) {
    final currentState = state;
    if (currentState is! AppLeagueExists) return null;
    return currentState.memberProfiles[userId]?.profileImageUrl;
  }

  void updateOwnProfileImage(String userId, String? newUrl) {
    final currentState = state;
    if (currentState is! AppLeagueExists) return;

    final updatedMemberProfiles = Map<String, MemberProfile>.from(
      currentState.memberProfiles,
    );

    updatedMemberProfiles[userId] = MemberProfile(
      userId: userId,
      profileImageUrl: newUrl != null && newUrl.isNotEmpty ? newUrl : null,
    );

    emit(currentState.copyWith(memberProfiles: updatedMemberProfiles));
  }

  Future<void> _emitLeagueExistsWithProfileImages({
    required List<League> leagues,
    required League selectedLeague,
  }) async {
    final userIds = _extractParticipantUserIds(selectedLeague);

    final result = await _getProfileImages(
      GetProfileImagesParams(userIds: userIds),
    );

    result.fold(
      (_) {
        emit(AppLeagueExists(
          leagues: leagues,
          selectedLeague: selectedLeague,
        ));
      },
      (memberProfiles) {
        emit(
          AppLeagueExists(
            leagues: leagues,
            selectedLeague: selectedLeague,
            memberProfiles: {
              for (final profile in memberProfiles) profile.userId: profile,
            },
          ),
        );
      },
    );
  }

  List<String> _extractParticipantUserIds(League league) {
    final userIds = <String>{};

    for (final participant in league.participants) {
      if (participant is IndividualParticipant) {
        userIds.add(participant.userId);
      } else if (participant is TeamParticipant) {
        userIds.addAll(participant.members.map((member) => member.userId));
      }
    }

    return userIds.toList();
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
