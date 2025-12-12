import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/app/domain/entities/app_status.dart';
import 'package:fantavacanze_official/features/app/domain/use_cases/get_app_status.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppStatusCubit extends Cubit<AppStatusType> {
  final GetAppStatus _getAppStatus;

  AppStatusCubit({required GetAppStatus getAppStatus})
      : _getAppStatus = getAppStatus,
        super(AppStatusType.available);

  Future<void> fetchStatus() async {
    final result = await _getAppStatus.call(NoParams());
    result.fold(
      (_) => emit(AppStatusType.available),
      (app) => emit(app.status),
    );
  }

  void setStatus(AppStatusType status) {
    emit(status);
  }
}
