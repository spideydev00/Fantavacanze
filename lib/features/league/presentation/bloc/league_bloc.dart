import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/add_event.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/add_memory.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/create_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/exit_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/get_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/get_rules.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/get_users_details.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/join_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remove_memory.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remove_team_participants.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/update_team_name.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/update_rule.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/delete_rule.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/add_rule.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/search_league.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeagueBloc extends Bloc<LeagueEvent, LeagueState> {
  final CreateLeague createLeague;
  final GetLeague getLeague;
  final JoinLeague joinLeague;
  final ExitLeague exitLeague;
  final UpdateTeamName updateTeamName;
  final AddEvent addEvent;
  final AddMemory addMemory;
  final RemoveMemory removeMemory;
  final RemoveTeamParticipants removeTeamParticipants;
  final GetRules getRules;
  final UpdateRule updateRule;
  final DeleteRule deleteRule;
  final AddRule addRule;
  final GetUsersDetails getUsersDetails;
  final SearchLeague searchLeague;
  final AppUserCubit appUserCubit;
  final AppLeagueCubit appLeagueCubit;

  LeagueBloc({
    required this.createLeague,
    required this.getLeague,
    required this.joinLeague,
    required this.exitLeague,
    required this.updateTeamName,
    required this.addEvent,
    required this.addMemory,
    required this.removeMemory,
    required this.getRules,
    required this.updateRule,
    required this.deleteRule,
    required this.addRule,
    required this.getUsersDetails,
    required this.searchLeague,
    required this.appUserCubit,
    required this.appLeagueCubit,
    required this.removeTeamParticipants,
  }) : super(LeagueInitial()) {
    on<CreateLeagueEvent>(_onCreateLeague);
    on<GetLeagueEvent>(_onGetLeague);
    on<SearchLeagueEvent>(_handleSearchLeague);
    on<JoinLeagueEvent>(_handleJoinLeague);
    on<ExitLeagueEvent>(_onExitLeague);
    on<UpdateTeamNameEvent>(_onUpdateTeamName);
    on<AddEventEvent>(_onAddEvent);
    on<AddMemoryEvent>(_onAddMemory);
    on<GetRulesEvent>(_onGetRules);
    on<UpdateRuleEvent>(_onUpdateRule);
    on<DeleteRuleEvent>(_onDeleteRule);
    on<AddRuleEvent>(_onAddRule);
    on<GetUsersDetailsEvent>(_onGetUsersDetails);
    on<RemoveTeamParticipantsEvent>(_handleRemoveTeamParticipants);
  }

  // -----------------------------------------------------------
  // L E A G U E   M A I N   O P E R A T I O N S
  // -----------------------------------------------------------

  // C R E A T E   L E A G U E
  Future<void> _onCreateLeague(
    CreateLeagueEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());

    final result = await createLeague(
      CreateLeagueParams(
        name: event.name,
        description: event.description ?? "",
        isTeamBased: event.isTeamBased,
        rules: event.rules,
      ),
    );

    result.fold(
      (failure) => emit(LeagueError(message: failure.message)),
      (league) {
        emit(LeagueSuccess(league: league, operation: 'create_league'));

        // Refresh app league cubit after creating league
        appLeagueCubit.getUserLeagues();
        // Update app-wide shared preferences
        appLeagueCubit.selectLeague(league);
      },
    );
  }

  // S E A R C H   L E A G U E
  Future<void> _handleSearchLeague(
    SearchLeagueEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());
    final result = await searchLeague(
      SearchLeagueParams(inviteCode: event.inviteCode),
    );
    result.fold(
      (failure) => emit(LeagueError(message: failure.message)),
      (leagues) {
        if (leagues.isEmpty) {
          emit(const LeagueError(
              message: "Nessuna lega trovata con questo codice"));
        } else if (leagues.length == 1) {
          emit(LeagueWithInviteCode(
            league: leagues.first,
            inviteCode: event.inviteCode,
          ));
        } else {
          emit(MultiplePossibleLeagues(
            possibleLeagues: leagues,
            inviteCode: event.inviteCode,
          ));
        }
      },
    );
  }

  // J O I N   L E A G U E
  void _handleJoinLeague(
    JoinLeagueEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());

    try {
      final result = await joinLeague(
        JoinLeagueParams(
          inviteCode: event.inviteCode,
          teamName: event.teamName,
          teamMembers: event.teamMembers,
          specificLeagueId: event.specificLeagueId,
        ),
      );

      result.fold(
        (failure) {
          emit(LeagueError(message: failure.message));
        },
        (league) {
          emit(LeagueSuccess(
            league: league,
            operation: 'join_league',
          ));

          // Delete previous selected league from shared preferences
          appLeagueCubit.selectLeague(league);

          // Make sure to update the list of user leagues
          appLeagueCubit.getUserLeagues();
        },
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  // E X I T   L E A G U E
  Future<void> _onExitLeague(
    ExitLeagueEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      late String userId;
      final state = appUserCubit.state;

      if (state is AppUserIsLoggedIn) {
        userId = state.user.id;
      }

      final result = await exitLeague(
        ExitLeagueParams(
          league: event.league,
          userId: userId,
        ),
      );

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (_) {
          emit(ExitLeagueSuccess());
          // Remove selected league from shared preferences
          appLeagueCubit.clearSelectedLeague();
          // Refresh app league cubit after exiting
          appLeagueCubit.getUserLeagues();
        },
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  // G E T   L E A G U E
  Future<void> _onGetLeague(
    GetLeagueEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      final result = await getLeague(
        GetLeagueParams(
          leagueId: event.leagueId,
        ),
      );

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (league) =>
            emit(LeagueSuccess(league: league, operation: 'get_league')),
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  // -----------------------------------------------------------
  // R U L E S   M A N A G E M E N T
  // -----------------------------------------------------------

  // G E T   R U L E S
  Future<void> _onGetRules(
    GetRulesEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      // Validate mode parameter
      if (event.mode != "hard" && event.mode != "soft") {
        emit(const LeagueError(message: "Invalid mode. Use 'hard' or 'soft'"));
        return;
      }

      final result = await getRules(event.mode);

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (rules) => emit(RulesLoaded(rules: rules, mode: event.mode)),
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  // U P D A T E   R U L E
  Future<void> _onUpdateRule(
      UpdateRuleEvent event, Emitter<LeagueState> emit) async {
    emit(LeagueLoading());

    final result = await updateRule(
      UpdateRuleParams(
        league: event.league,
        rule: event.rule,
        originalRuleName: event.originalRuleName,
      ),
    );

    emit(result.fold(
      (failure) => LeagueError(message: failure.message),
      (league) {
        // Update the app-wide cubit state
        if (appLeagueCubit.state is AppLeagueExists) {
          appLeagueCubit.selectLeague(league);
        }

        return LeagueSuccess(league: league, operation: 'update_rule');
      },
    ));
  }

  // D E L E T E   R U L E
  Future<void> _onDeleteRule(
      DeleteRuleEvent event, Emitter<LeagueState> emit) async {
    emit(LeagueLoading());

    final result = await deleteRule(
      DeleteRuleParams(
        league: event.league,
        ruleName: event.ruleName,
      ),
    );

    emit(result.fold(
      (failure) => LeagueError(message: failure.message),
      (league) {
        // Update the app-wide cubit state
        if (appLeagueCubit.state is AppLeagueExists) {
          appLeagueCubit.selectLeague(league);
        }

        return LeagueSuccess(league: league, operation: 'delete_rule');
      },
    ));
  }

  // A D D   R U L E
  Future<void> _onAddRule(AddRuleEvent event, Emitter<LeagueState> emit) async {
    emit(LeagueLoading());

    final result = await addRule(
      AddRuleParams(
        league: event.league,
        rule: event.rule,
      ),
    );

    emit(result.fold(
      (failure) => LeagueError(message: failure.message),
      (league) {
        // Update the app-wide cubit state
        if (appLeagueCubit.state is AppLeagueExists) {
          appLeagueCubit.selectLeague(league);
        }

        return LeagueSuccess(league: league, operation: 'add_rule');
      },
    ));
  }

  // -----------------------------------------------------------
  // M E M B E R S H I P   O P E R A T I O N S
  // -----------------------------------------------------------

  // U P D A T E   T E A M   N A M E
  Future<void> _onUpdateTeamName(
    UpdateTeamNameEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      late String userId;
      final state = appUserCubit.state;

      if (state is AppUserIsLoggedIn) {
        userId = state.user.id;
      }

      final result = await updateTeamName(
        UpdateTeamNameParams(
          league: event.league,
          userId: userId,
          newName: event.newName,
        ),
      );

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (league) {
          emit(LeagueSuccess(league: league, operation: 'update_team_name'));

          // Update app-wide state if this is the selected league
          final cubitState = appLeagueCubit.state;
          if (cubitState is AppLeagueExists &&
              cubitState.selectedLeague.id == league.id) {
            appLeagueCubit.selectLeague(league);
          }
        },
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  // -----------------------------------------------------------
  // C O N T E N T   M A N A G E M E N T
  // -----------------------------------------------------------

  // A D D   E V E N T
  Future<void> _onAddEvent(
    AddEventEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      final result = await addEvent(
        AddEventParams(
          league: event.league,
          name: event.name,
          points: event.points,
          creatorId: event.creatorId,
          targetUser: event.targetUser,
          type: event.type,
          description: event.description,
        ),
      );

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (league) {
          emit(LeagueSuccess(league: league, operation: 'add_event'));

          // Update app-wide state if this is the selected league
          final cubitState = appLeagueCubit.state;
          if (cubitState is AppLeagueExists &&
              cubitState.selectedLeague.id == league.id) {
            appLeagueCubit.selectLeague(league);
          }
        },
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  // A D D   M E M O R Y
  Future<void> _onAddMemory(
    AddMemoryEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      final result = await addMemory(AddMemoryParams(
        league: event.league,
        imageUrl: event.imageUrl,
        text: event.text,
        userId: event.userId,
        relatedEventId: event.relatedEventId,
      ));

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (league) {
          emit(LeagueSuccess(league: league, operation: 'add_memory'));

          // Update app-wide state if this is the selected league
          final cubitState = appLeagueCubit.state;
          if (cubitState is AppLeagueExists &&
              cubitState.selectedLeague.id == league.id) {
            appLeagueCubit.selectLeague(league);
          }
        },
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  // G E T   U S E R S   D E T A I L S
  Future<void> _onGetUsersDetails(
    GetUsersDetailsEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      final result = await getUsersDetails(event.userIds);

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (usersDetails) => emit(UsersDetailsLoaded(usersDetails: usersDetails)),
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  // R E M O V E   T E A M   P A R T I C I P A N T S
  Future<void> _handleRemoveTeamParticipants(
    RemoveTeamParticipantsEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      // Ottieni l'ID dell'utente corrente
      late String requestingUserId;
      final userState = appUserCubit.state;

      if (userState is AppUserIsLoggedIn) {
        requestingUserId = userState.user.id;
      } else {
        emit(const LeagueError(message: "Utente non autenticato"));
        return;
      }

      // Controlla se l'utente è admin della lega
      if (!event.league.admins.contains(requestingUserId)) {
        emit(const LeagueError(
            message:
                "Solo gli amministratori possono rimuovere membri dai team"));
        return;
      }

      final result = await removeTeamParticipants(
        RemoveTeamParticipantsParams(
          league: event.league,
          teamName: event.teamName,
          userIdsToRemove: event.userIdsToRemove,
          requestingUserId: requestingUserId,
        ),
      );

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (league) {
          emit(TeammatesRemovedState(league: league));

          // Aggiorna lo stato globale se questa è la lega selezionata
          final cubitState = appLeagueCubit.state;
          if (cubitState is AppLeagueExists &&
              cubitState.selectedLeague.id == league.id) {
            appLeagueCubit.selectLeague(league);
          }
        },
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  // -----------------------------------------------------------
  // U T I L I T Y   M E T H O D S
  // -----------------------------------------------------------

  // Helper method to check if current user is admin of the selected league
  bool isAdmin() {
    // Get current user ID
    final userState = appUserCubit.state;
    if (userState is! AppUserIsLoggedIn) {
      return false;
    }

    final String userId = userState.user.id;

    // Check if there is a selected league in the app-wide cubit
    final leagueState = appLeagueCubit.state;
    if (leagueState is AppLeagueExists) {
      return leagueState.selectedLeague.admins.contains(userId);
    }

    return false;
  }
}
