import 'dart:async';
import 'dart:typed_data';
import 'package:fantavacanze_official/core/cubits/app_fs_league/app_fs_league_cubit.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_league/get_fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_league/upload_winner_photo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_league/create_fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_league/join_fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_league/exit_fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_league/delete_fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_league/delete_winner_photo.dart';

part 'fs_event.dart';
part 'fs_state.dart';

class FsBloc extends Bloc<FsEvent, FsState> {
  final CreateFsLeague _createFsLeague;
  final JoinFsLeague _joinFsLeague;
  final GetFsLeague _getFsLeague;
  final ExitFsLeague _exitFsLeague;
  final DeleteFsLeague _deleteFsLeague;
  final UploadWinnerPhoto _uploadWinnerPhoto;
  final AppFsLeagueCubit _appFsLeagueCubit;
  final DeleteWinnerPhoto _deleteWinnerPhoto;

  FsBloc({
    required CreateFsLeague createFsLeague,
    required JoinFsLeague joinFsLeague,
    required GetFsLeague getFsLeague,
    required ExitFsLeague exitFsLeague,
    required DeleteFsLeague deleteFsLeague,
    required UploadWinnerPhoto uploadWinnerPhoto,
    required AppFsLeagueCubit appFsLeagueCubit,
    required DeleteWinnerPhoto deleteWinnerPhoto,
  })  : _createFsLeague = createFsLeague,
        _joinFsLeague = joinFsLeague,
        _getFsLeague = getFsLeague,
        _exitFsLeague = exitFsLeague,
        _deleteFsLeague = deleteFsLeague,
        _uploadWinnerPhoto = uploadWinnerPhoto,
        _appFsLeagueCubit = appFsLeagueCubit,
        _deleteWinnerPhoto = deleteWinnerPhoto,
        super(FsInitial()) {
    on<GetFsLeagueEvent>(_onGetFsLeague);
    on<CreateFsLeagueEvent>(_onCreateFsLeague);
    on<JoinFsLeagueEvent>(_onJoinFsLeague);
    on<ExitFsLeagueEvent>(_onExitFsLeague);
    on<DeleteFsLeagueEvent>(_onDeleteFsLeague);
    on<UploadWinnerPhotoEvent>(_onUploadWinnerPhoto);
    on<DeleteWinnerPhotoEvent>(_onDeleteWinnerPhoto);
  }

  FutureOr<void> _onGetFsLeague(
    GetFsLeagueEvent event,
    Emitter<FsState> emit,
  ) async {
    emit(FsLoading());
    final result = await _getFsLeague(NoParams());

    result.fold(
      (failure) => emit(FsFailure(failure.message)),
      (league) {
        if (league != null) {
          _appFsLeagueCubit.setFsLeagueExists(league);
          emit(FsLeagueLoaded(league));
        } else {
          _appFsLeagueCubit.setFsLeagueNotExists();
          emit(FsFailure("La lega non esiste!"));
        }
      },
    );
  }

  FutureOr<void> _onCreateFsLeague(
    CreateFsLeagueEvent event,
    Emitter<FsState> emit,
  ) async {
    emit(FsLoading());
    final result = await _createFsLeague(CreateFsLeagueParams(
      name: event.name,
      description: event.description,
      creatorId: event.creatorId,
      creatorName: event.creatorName,
    ));

    result.fold(
      (failure) => emit(FsFailure(failure.message)),
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
    emit(FsLoading());
    final result = await _joinFsLeague(JoinFsLeagueParams(
      inviteCode: event.inviteCode,
      userId: event.userId,
      userName: event.userName,
    ));

    result.fold(
      (failure) => emit(FsFailure(failure.message)),
      (league) {
        _appFsLeagueCubit.setFsLeagueExists(league);
        emit(FsLeagueJoined(league));
      },
    );
  }

  FutureOr<void> _onExitFsLeague(
    ExitFsLeagueEvent event,
    Emitter<FsState> emit,
  ) async {
    emit(FsLoading());
    final result = await _exitFsLeague(ExitFsLeagueParams(
      leagueId: event.leagueId,
      userId: event.userId,
    ));

    result.fold(
      (failure) => emit(FsFailure(failure.message)),
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
    emit(FsLoading());
    final result = await _deleteFsLeague(DeleteFsLeagueParams(
      leagueId: event.leagueId,
    ));

    result.fold(
      (failure) => emit(FsFailure(failure.message)),
      (_) {
        _appFsLeagueCubit.setFsLeagueNotExists();
        emit(FsLeagueDeleted());
      },
    );
  }

  FutureOr<void> _onUploadWinnerPhoto(
    UploadWinnerPhotoEvent event,
    Emitter<FsState> emit,
  ) async {
    emit(FsLoading());
    final result = await _uploadWinnerPhoto(UploadWinnerPhotoParams(
      leagueId: event.leagueId,
      imageBytes: event.imageBytes,
    ));

    result.fold(
      (failure) => emit(FsFailure(failure.message)),
      (league) {
        emit(WinnerPhotoUploaded(league.winnerPhotoUrl!));

        _appFsLeagueCubit.setFsLeagueExists(league);
      },
    );
  }

  FutureOr<void> _onDeleteWinnerPhoto(
    DeleteWinnerPhotoEvent event,
    Emitter<FsState> emit,
  ) async {
    emit(FsLoading());
    final result = await _deleteWinnerPhoto(DeleteWinnerPhotoParams(
      leagueId: event.leagueId,
    ));

    result.fold(
      (failure) => emit(FsFailure(failure.message)),
      (league) {
        emit(WinnerPhotoDeleted());

        _appFsLeagueCubit.setFsLeagueExists(league);
      },
    );
  }
}
