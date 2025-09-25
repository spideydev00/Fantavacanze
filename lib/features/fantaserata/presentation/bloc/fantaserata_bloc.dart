import 'dart:async';
import 'package:fantavacanze_official/core/cubits/app_fs_league/app_fs_league_cubit.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/get_fs_league.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_memory.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/create_fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/join_fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/set_rule_as_completed.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/add_fs_memory.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/delete_fs_memory.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/exit_fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/delete_fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/refresh_fs_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/unlock_fs_rule.dart';

part 'fantaserata_event.dart';
part 'fantaserata_state.dart';

class FantaserataBloc extends Bloc<FantaserataEvent, FantaserataState> {
  final CreateFsLeague _createFsLeague;
  final JoinFsLeague _joinFsLeague;
  final GetFsLeague _getFsLeague;
  final SetRuleAsCompleted _setRuleAsCompleted;
  final AddFsMemory _addFsMemory;
  final DeleteFsMemory _deleteFsMemory;
  final ExitFsLeague _exitFsLeague;
  final DeleteFsLeague _deleteFsLeague;
  final RefreshFsRule _refreshFsRule;
  final UnlockFsRule _unlockFsRule;
  final AppFsLeagueCubit _appFsLeagueCubit;

  FantaserataBloc({
    required CreateFsLeague createFsLeague,
    required JoinFsLeague joinFsLeague,
    required GetFsLeague getFsLeague,
    required SetRuleAsCompleted setRuleAsCompleted,
    required AddFsMemory addFsMemory,
    required DeleteFsMemory deleteFsMemory,
    required ExitFsLeague exitFsLeague,
    required DeleteFsLeague deleteFsLeague,
    required RefreshFsRule refreshFsRule,
    required UnlockFsRule unlockFsRule,
    required AppFsLeagueCubit appFsLeagueCubit,
  })  : _createFsLeague = createFsLeague,
        _joinFsLeague = joinFsLeague,
        _getFsLeague = getFsLeague,
        _setRuleAsCompleted = setRuleAsCompleted,
        _addFsMemory = addFsMemory,
        _deleteFsMemory = deleteFsMemory,
        _exitFsLeague = exitFsLeague,
        _deleteFsLeague = deleteFsLeague,
        _refreshFsRule = refreshFsRule,
        _unlockFsRule = unlockFsRule,
        _appFsLeagueCubit = appFsLeagueCubit,
        super(FantaserataInitial()) {
    on<FantaserataEvent>((event, emit) => emit(FantaserataLoading()));
    on<GetFsLeagueEvent>(_onGetFsLeague);
    on<CreateFsLeagueEvent>(_onCreateFsLeague);
    on<JoinFsLeagueEvent>(_onJoinFsLeague);
    on<AddFsMemoryEvent>(_onAddFsMemory);
    on<DeleteFsMemoryEvent>(_onDeleteFsMemory);
    on<ExitFsLeagueEvent>(_onExitFsLeague);
    on<DeleteFsLeagueEvent>(_onDeleteFsLeague);
    on<RefreshFsRuleEvent>(_onRefreshFsRule);
    on<UnlockFsRuleEvent>(_onUnlockFsRule);
    on<SetRuleAsCompletedEvent>(_onSetRuleAsCompleted);
  }

  FutureOr<void> _onGetFsLeague(
    GetFsLeagueEvent event,
    Emitter<FantaserataState> emit,
  ) async {
    final result = await _getFsLeague(NoParams());

    result.fold(
      (failure) => emit(FantaserataFailure(failure.message)),
      (league) {
        if (league != null) {
          _appFsLeagueCubit.setFsLeagueExists(league);
          emit(FsLeagueLoaded(league));
        } else {
          _appFsLeagueCubit.setFsLeagueNotExists();
          emit(FsLeagueNotExists());
        }
      },
    );
  }

  FutureOr<void> _onCreateFsLeague(
    CreateFsLeagueEvent event,
    Emitter<FantaserataState> emit,
  ) async {
    final result = await _createFsLeague(CreateFsLeagueParams(
      name: event.name,
      description: event.description,
      creatorId: event.creatorId,
      creatorName: event.creatorName,
    ));

    result.fold(
      (failure) => emit(FantaserataFailure(failure.message)),
      (league) {
        _appFsLeagueCubit.setFsLeagueExists(league);
        emit(FsLeagueCreated(league));
      },
    );
  }

  FutureOr<void> _onJoinFsLeague(
    JoinFsLeagueEvent event,
    Emitter<FantaserataState> emit,
  ) async {
    final result = await _joinFsLeague(JoinFsLeagueParams(
      inviteCode: event.inviteCode,
      userId: event.userId,
      userName: event.userName,
    ));

    result.fold(
      (failure) => emit(FantaserataFailure(failure.message)),
      (league) {
        _appFsLeagueCubit.setFsLeagueExists(league);
        emit(FsLeagueJoined(league));
      },
    );
  }

  FutureOr<void> _onAddFsMemory(
    AddFsMemoryEvent event,
    Emitter<FantaserataState> emit,
  ) async {
    final result = await _addFsMemory(AddFsMemoryParams(
      leagueId: event.leagueId,
      imageUrl: event.imageUrl,
      description: event.description,
      userId: event.userId,
      participantName: event.participantName,
      relatedEventId: event.relatedEventId,
      eventName: event.eventName,
    ));

    result.fold(
      (failure) => emit(FantaserataFailure(failure.message)),
      (memory) => emit(FsMemoryAdded(memory)),
    );
  }

  FutureOr<void> _onDeleteFsMemory(
    DeleteFsMemoryEvent event,
    Emitter<FantaserataState> emit,
  ) async {
    final result = await _deleteFsMemory(DeleteFsMemoryParams(
      leagueId: event.leagueId,
      memoryId: event.memoryId,
    ));

    result.fold(
      (failure) => emit(FantaserataFailure(failure.message)),
      (_) => emit(FsMemoryDeleted()),
    );
  }

  FutureOr<void> _onExitFsLeague(
    ExitFsLeagueEvent event,
    Emitter<FantaserataState> emit,
  ) async {
    final result = await _exitFsLeague(ExitFsLeagueParams(
      leagueId: event.leagueId,
      userId: event.userId,
    ));

    result.fold(
      (failure) => emit(FantaserataFailure(failure.message)),
      (_) {
        _appFsLeagueCubit.setFsLeagueNotExists();
        emit(FsLeagueExited());
      },
    );
  }

  FutureOr<void> _onDeleteFsLeague(
    DeleteFsLeagueEvent event,
    Emitter<FantaserataState> emit,
  ) async {
    final result = await _deleteFsLeague(DeleteFsLeagueParams(
      leagueId: event.leagueId,
    ));

    result.fold(
      (failure) => emit(FantaserataFailure(failure.message)),
      (_) {
        _appFsLeagueCubit.setFsLeagueNotExists();
        emit(FsLeagueDeleted());
      },
    );
  }

  FutureOr<void> _onRefreshFsRule(
    RefreshFsRuleEvent event,
    Emitter<FantaserataState> emit,
  ) async {
    final result = await _refreshFsRule(RefreshFsRuleParams(
      userId: event.userId,
      leagueId: event.leagueId,
      challengeId: event.challengeId,
    ));

    result.fold(
      (failure) => emit(FantaserataFailure(failure.message)),
      (_) => emit(FsRuleRefreshed()),
    );
  }

  FutureOr<void> _onUnlockFsRule(
    UnlockFsRuleEvent event,
    Emitter<FantaserataState> emit,
  ) async {
    final result = await _unlockFsRule(UnlockFsRuleParams(
      userId: event.userId,
      leagueId: event.leagueId,
      challengeId: event.challengeId,
    ));

    result.fold(
      (failure) => emit(FantaserataFailure(failure.message)),
      (_) => emit(FsRuleUnlocked()),
    );
  }

  FutureOr<void> _onSetRuleAsCompleted(
    SetRuleAsCompletedEvent event,
    Emitter<FantaserataState> emit,
  ) async {
    final result = await _setRuleAsCompleted(SetRuleAsCompletedParams(
      userId: event.userId,
      leagueId: event.leagueId,
      challengeId: event.challengeId,
      ruleName: event.ruleName,
      points: event.points,
      type: event.type,
    ));

    result.fold(
      (failure) => emit(FantaserataFailure(failure.message)),
      (_) => emit(FsRuleCompleted()),
    );
  }
}
