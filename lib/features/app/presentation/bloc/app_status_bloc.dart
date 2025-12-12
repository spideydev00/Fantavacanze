import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/core/cubits/app_status/app_status_cubit.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/app/domain/entities/app_status.dart';
import 'package:fantavacanze_official/features/app/domain/use_cases/get_app_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_status_event.dart';
part 'app_status_state.dart';

class AppStatusBloc extends Bloc<AppStatusEvent, AppStatusState> {
  final GetAppStatus _getAppStatus;
  final AppStatusCubit _appStatusCubit;

  AppStatusBloc(
      {required GetAppStatus getAppStatus,
      required AppStatusCubit appStatusCubit})
      : _getAppStatus = getAppStatus,
        _appStatusCubit = appStatusCubit,
        super(AppAvailable()) {
    on<GetAppStatusEvent>(_onGetAppStatus);
  }

  Future<void> _onGetAppStatus(
    GetAppStatusEvent event,
    Emitter<AppStatusState> emit,
  ) async {
    final result = await _getAppStatus.call(NoParams());

    result.fold((failure) => emit(AppStatusFailure(failure.message)), (app) {
      _appStatusCubit.setStatus(app.status);
      if (app.status == AppStatusType.available) {
        emit(AppAvailable());
      } else {
        emit(AppUnavailable());
      }
    });
  }
}
