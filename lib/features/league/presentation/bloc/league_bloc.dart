import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/add_event.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/add_memory.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/create_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/exit_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/get_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/get_rules.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/join_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remove_memory.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/update_team_name.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/update_rule.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/delete_rule.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/add_rule.dart';
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
  final GetRules getRules;
  final UpdateRule updateRule;
  final DeleteRule deleteRule;
  final AddRule addRule;
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
    required this.appUserCubit,
    required this.appLeagueCubit,
  }) : super(LeagueInitial()) {
    on<CreateLeagueEvent>(_onCreateLeague);
    on<GetLeagueEvent>(_onGetLeague);
    on<JoinLeagueEvent>(_onJoinLeague);
    on<ExitLeagueEvent>(_onExitLeague);
    on<UpdateTeamNameEvent>(_onUpdateTeamName);
    on<AddEventEvent>(_onAddEvent);
    on<AddMemoryEvent>(_onAddMemory);
    on<GetRulesEvent>(_onGetRules);
    on<UpdateRuleEvent>(_onUpdateRule);
    on<DeleteRuleEvent>(_onDeleteRule);
    on<AddRuleEvent>(_onAddRule);
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

  // J O I N   L E A G U E
  Future<void> _onJoinLeague(
    JoinLeagueEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      late String userId;
      final state = appUserCubit.state;

      if (state is AppUserIsLoggedIn) {
        userId = state.user.id;
      }

      final result = await joinLeague(
        JoinLeagueParams(
          inviteCode: event.inviteCode,
          userId: userId,
          teamName: event.teamName,
          teamMembers: event.teamMembers,
          specificLeagueId: event.specificLeagueId,
        ),
      );

      result.fold(
        (failure) {
          // Check if we have multiple leagues with same invite code
          if (failure.data != null && failure.data is List) {
            emit(MultiplePossibleLeagues(
              inviteCode: event.inviteCode,
              possibleLeagues: failure.data,
            ));
          } else {
            emit(LeagueError(message: failure.message));
          }
        },
        (league) {
          emit(LeagueSuccess(league: league, operation: 'join_league'));
          // Refresh app league cubit after joining
          appLeagueCubit.getUserLeagues();
          // Update app-wide shared preferences
          appLeagueCubit.selectLeague(league);
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
        (league) {
          emit(LeagueSuccess(league: league, operation: 'exit_league'));

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
