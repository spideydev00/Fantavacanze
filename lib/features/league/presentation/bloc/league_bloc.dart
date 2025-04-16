import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/add_event.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/add_memory.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/create_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/exit_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/get_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/get_rules.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/get_user_leagues.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/join_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remove_memory.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/update_team_name.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/update_rule.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/delete_rule.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

class LeagueBloc extends Bloc<LeagueEvent, LeagueState> {
  final CreateLeague createLeague;
  final GetLeague getLeague;
  final GetUserLeagues getUserLeagues;
  final JoinLeague joinLeague;
  final ExitLeague exitLeague;
  final UpdateTeamName updateTeamName;
  final AddEvent addEvent;
  final AddMemory addMemory;
  final RemoveMemory removeMemory;
  final GetRules getRules;
  final UpdateRule updateRule;
  final DeleteRule deleteRule;
  final AppUserCubit appUserCubit;
  final AppLeagueCubit appLeagueCubit;

  LeagueBloc({
    required this.createLeague,
    required this.getLeague,
    required this.getUserLeagues,
    required this.joinLeague,
    required this.exitLeague,
    required this.updateTeamName,
    required this.addEvent,
    required this.addMemory,
    required this.removeMemory,
    required this.getRules,
    required this.updateRule,
    required this.deleteRule,
    required this.appUserCubit,
    required this.appLeagueCubit,
  }) : super(LeagueInitial()) {
    on<CreateLeagueEvent>(_onCreateLeague);
    on<GetLeagueEvent>(_onGetLeague);
    on<GetUserLeaguesEvent>(_onGetUserLeagues);
    on<GetRulesEvent>(_onGetRules);
    on<JoinLeagueEvent>(_onJoinLeague);
    on<ExitLeagueEvent>(_onExitLeague);
    on<UpdateTeamNameEvent>(_onUpdateTeamName);
    on<AddEventEvent>(_onAddEvent);
    on<AddMemoryEvent>(_onAddMemory);
    on<UpdateRuleEvent>(_onUpdateRule);
    on<DeleteRuleEvent>(_onDeleteRule);
  }

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
        emit(LeagueCreated(league: league));
        emit(LeagueLoaded(league: league));
      },
    );
  }

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
        (league) => emit(LeagueLoaded(league: league)),
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  Future<void> _onGetUserLeagues(
    GetUserLeaguesEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      final result = await getUserLeagues(NoParams());

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (leagues) => _emitLeagueSuccess(leagues, emit),
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  // E M I T    L E A G U E    S U C C E S S
  void _emitLeagueSuccess(List<League> leagues, Emitter<LeagueState> emit) {
    appLeagueCubit.loadSelectedLeague(leagues);

    emit(UserLeaguesLoaded(leagues: leagues));
  }

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
          emit(LeagueJoined(league: league));
          _refreshSelectedLeague(league);
        },
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

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
          leagueId: event.leagueId,
          userId: userId,
        ),
      );

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (league) {
          emit(LeagueExited(league: league));
          _refreshSelectedLeague(league);
        },
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

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
          leagueId: event.leagueId,
          userId: userId,
          newName: event.newName,
        ),
      );

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (league) {
          emit(TeamNameUpdated(league: league));
          _refreshSelectedLeague(league);
        },
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  Future<void> _onAddEvent(
    AddEventEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      final result = await addEvent(
        AddEventParams(
          leagueId: event.leagueId,
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
          emit(LeagueLoaded(league: league));
          _refreshSelectedLeague(league);
        },
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  Future<void> _onAddMemory(
    AddMemoryEvent event,
    Emitter<LeagueState> emit,
  ) async {
    try {
      emit(LeagueLoading());

      late String userId;
      final state = appUserCubit.state;

      if (state is AppUserIsLoggedIn) {
        userId = state.user.id;
      }

      final result = await addMemory(AddMemoryParams(
        leagueId: event.leagueId,
        imageUrl: event.imageUrl,
        text: event.text,
        userId: userId,
        relatedEventId: event.relatedEventId,
      ));

      result.fold(
        (failure) => emit(LeagueError(message: failure.message)),
        (league) {
          emit(MemoryAdded(league: league));
          _refreshSelectedLeague(league);
        },
      );
    } catch (e) {
      emit(LeagueError(message: e.toString()));
    }
  }

  Future<void> _onUpdateRule(
      UpdateRuleEvent event, Emitter<LeagueState> emit) async {
    emit(LeagueLoading());

    // Ensure we're working with integer IDs
    final Map<String, dynamic> ruleWithIntId = Map.from(event.rule);
    if (ruleWithIntId['id'] is String) {
      ruleWithIntId['id'] = int.tryParse(ruleWithIntId['id']) ?? 0;
    }

    final result = await updateRule(
      UpdateRuleParams(
        leagueId: event.leagueId,
        rule: ruleWithIntId,
      ),
    );

    emit(result.fold(
      (failure) => LeagueError(message: failure.message),
      (league) {
        // If we have a selected league, update it
        if (appLeagueCubit.state is AppLeagueExists) {
          appLeagueCubit.selectLeague(league);
        }

        _refreshSelectedLeague(league);
        return LeagueLoaded(league: league);
      },
    ));
  }

  Future<void> _onDeleteRule(
      DeleteRuleEvent event, Emitter<LeagueState> emit) async {
    emit(LeagueLoading());

    final result = await deleteRule(
      DeleteRuleParams(
        leagueId: event.leagueId,
        ruleId: event.ruleId,
      ),
    );

    emit(result.fold(
      (failure) => LeagueError(message: failure.message),
      (league) {
        // If we have a selected league, update it
        if (appLeagueCubit.state is AppLeagueExists) {
          appLeagueCubit.selectLeague(league);
        }

        _refreshSelectedLeague(league);
        return LeagueLoaded(league: league);
      },
    ));
  }

  Stream<LeagueState> mapEventToState(LeagueEvent event) async* {
    if (event is AddMemoryEvent) {
      yield* _mapAddMemoryEventToState(event);
    } else if (event is RemoveMemoryEvent) {
      yield* _mapRemoveMemoryEventToState(event);
    } else if (event is UpdateTeamNameEvent) {
      yield* _mapUpdateTeamNameEventToState(event);
    } else if (event is ExitLeagueEvent) {
      yield* _mapExitLeagueEventToState(event);
    }
  }

  Stream<LeagueState> _mapAddMemoryEventToState(AddMemoryEvent event) async* {
    yield LeagueLoading();

    try {
      final result = await addMemory(
        AddMemoryParams(
          leagueId: event.leagueId,
          imageUrl: event.imageUrl,
          text: event.text,
          userId: event.userId,
          relatedEventId: event.relatedEventId, // Pass relatedEventId
        ),
      );

      yield* _handleLeagueResult(result);
    } catch (e) {
      yield LeagueError(message: e.toString());
    }
  }

  Stream<LeagueState> _mapRemoveMemoryEventToState(
      RemoveMemoryEvent event) async* {
    yield LeagueLoading();

    try {
      final result = await removeMemory(
        RemoveMemoryParams(
          leagueId: event.leagueId,
          memoryId: event.memoryId,
        ),
      );

      yield* _handleLeagueResult(result);
    } catch (e) {
      yield LeagueError(message: e.toString());
    }
  }

  Stream<LeagueState> _mapUpdateTeamNameEventToState(
      UpdateTeamNameEvent event) async* {
    yield LeagueLoading();

    try {
      final result = await updateTeamName(
        UpdateTeamNameParams(
          leagueId: event.leagueId,
          userId: event.userId,
          newName: event.newName,
        ),
      );

      yield* _handleLeagueResult(result);
    } catch (e) {
      yield LeagueError(message: e.toString());
    }
  }

  Stream<LeagueState> _mapExitLeagueEventToState(ExitLeagueEvent event) async* {
    yield LeagueLoading();

    try {
      final result = await exitLeague(
        ExitLeagueParams(
          leagueId: event.leagueId,
          userId: event.userId,
        ),
      );

      yield* _handleLeagueResult(result);
    } catch (e) {
      yield LeagueError(message: e.toString());
    }
  }

  Stream<LeagueState> _handleLeagueResult(
      Either<Failure, League> result) async* {
    yield result.fold(
      (failure) => LeagueError(message: failure.message),
      (league) {
        if (appLeagueCubit.state is AppLeagueExists) {
          final leagues = (appLeagueCubit.state as AppLeagueExists).leagues;
          final updatedLeagues =
              leagues.map((l) => l.id == league.id ? league : l).toList();
          appLeagueCubit.loadSelectedLeague(updatedLeagues);
        }

        _refreshSelectedLeague(league);
        return LeagueLoaded(league: league);
      },
    );
  }

  void _refreshSelectedLeague(League updatedLeague) {
    if (appLeagueCubit.state is AppLeagueExists) {
      final leagueState = appLeagueCubit.state as AppLeagueExists;

      if (leagueState.selectedLeague?.id == updatedLeague.id) {
        appLeagueCubit.selectLeague(updatedLeague);
      }

      appLeagueCubit.getUserLeagues();
    }
  }
}
