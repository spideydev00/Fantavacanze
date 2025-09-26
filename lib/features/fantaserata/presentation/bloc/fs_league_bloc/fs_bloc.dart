import 'dart:async';
import 'package:fantavacanze_official/core/cubits/app_fs_league/app_fs_league_cubit.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_league/get_fs_league.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_league/create_fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_league/join_fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_league/add_fs_memory.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_league/delete_fs_memory.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_league/exit_fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_league/delete_fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_league/add_fs_event.dart';

part 'fs_event.dart';
part 'fs_state.dart';

class FsBloc extends Bloc<FsEvent, FsState> {
  final CreateFsLeague _createFsLeague;
  final JoinFsLeague _joinFsLeague;
  final GetFsLeague _getFsLeague;
  final AddFsMemory _addFsMemory;
  final DeleteFsMemory _deleteFsMemory;
  final ExitFsLeague _exitFsLeague;
  final DeleteFsLeague _deleteFsLeague;
  final AddFsEvent _addFsEvent;
  final AppFsLeagueCubit _appFsLeagueCubit;

  FsBloc({
    required CreateFsLeague createFsLeague,
    required JoinFsLeague joinFsLeague,
    required GetFsLeague getFsLeague,
    required AddFsMemory addFsMemory,
    required DeleteFsMemory deleteFsMemory,
    required ExitFsLeague exitFsLeague,
    required DeleteFsLeague deleteFsLeague,
    required AddFsEvent addFsEvent,
    required AppFsLeagueCubit appFsLeagueCubit,
  })  : _createFsLeague = createFsLeague,
        _joinFsLeague = joinFsLeague,
        _getFsLeague = getFsLeague,
        _addFsMemory = addFsMemory,
        _deleteFsMemory = deleteFsMemory,
        _exitFsLeague = exitFsLeague,
        _deleteFsLeague = deleteFsLeague,
        _addFsEvent = addFsEvent,
        _appFsLeagueCubit = appFsLeagueCubit,
        super(FantaserataInitial()) {
    on<FsEvent>((event, emit) => emit(FantaserataLoading()));
    on<GetFsLeagueEvent>(_onGetFsLeague);
    on<CreateFsLeagueEvent>(_onCreateFsLeague);
    on<JoinFsLeagueEvent>(_onJoinFsLeague);
    on<AddFsMemoryEvent>(_onAddFsMemory);
    on<DeleteFsMemoryEvent>(_onDeleteFsMemory);
    on<ExitFsLeagueEvent>(_onExitFsLeague);
    on<DeleteFsLeagueEvent>(_onDeleteFsLeague);
    on<AddFsEventEvent>(_onAddFsEvent);
  }

  FutureOr<void> _onGetFsLeague(
    GetFsLeagueEvent event,
    Emitter<FsState> emit,
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
          emit(FantaserataFailure("La lega non esiste!"));
        }
      },
    );
  }

  FutureOr<void> _onCreateFsLeague(
    CreateFsLeagueEvent event,
    Emitter<FsState> emit,
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
    Emitter<FsState> emit,
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
    Emitter<FsState> emit,
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
      (league) {
        _appFsLeagueCubit.setFsLeagueExists(league);

        emit(FsMemoryAdded(league));
      },
    );
  }

  FutureOr<void> _onDeleteFsMemory(
    DeleteFsMemoryEvent event,
    Emitter<FsState> emit,
  ) async {
    final result = await _deleteFsMemory(DeleteFsMemoryParams(
      leagueId: event.leagueId,
      memoryId: event.memoryId,
    ));

    result.fold(
      (failure) => emit(FantaserataFailure(failure.message)),
      (league) {
        _appFsLeagueCubit.setFsLeagueExists(league);
        emit(FsMemoryDeleted(league));
      },
    );
  }

  FutureOr<void> _onExitFsLeague(
    ExitFsLeagueEvent event,
    Emitter<FsState> emit,
  ) async {
    final result = await _exitFsLeague(ExitFsLeagueParams(
      leagueId: event.leagueId,
      userId: event.userId,
    ));

    result.fold(
      (failure) => emit(FantaserataFailure(failure.message)),
      (league) {
        _appFsLeagueCubit.setFsLeagueNotExists();

        emit(FsLeagueExited());
      },
    );
  }

  FutureOr<void> _onDeleteFsLeague(
    DeleteFsLeagueEvent event,
    Emitter<FsState> emit,
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

  FutureOr<void> _onAddFsEvent(
    AddFsEventEvent event,
    Emitter<FsState> emit,
  ) async {
    final result = await _addFsEvent(AddFsEventParams(
      leagueId: event.leagueId,
      name: event.name,
      points: event.points,
      targetParticipantId: event.targetParticipantId,
      type: event.type,
    ));

    result.fold(
      (failure) => emit(FantaserataFailure(failure.message)),
      (league) {
        _appFsLeagueCubit.setFsLeagueExists(league);
        emit(FsEventAdded(league));
      },
    );
  }
}
