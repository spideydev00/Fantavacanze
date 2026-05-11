import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/app/domain/entities/app_version_config.dart';
import 'package:fantavacanze_official/features/app/domain/use_cases/check_app_version.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppVersionState {
  final AppVersionStatus status;
  final String? storeUrl;

  const AppVersionState({
    required this.status,
    this.storeUrl,
  });
}

class AppVersionCubit extends Cubit<AppVersionState> {
  final CheckAppVersion _checkAppVersion;

  AppVersionCubit({required CheckAppVersion checkAppVersion})
      : _checkAppVersion = checkAppVersion,
        super(
          const AppVersionState(status: AppVersionStatus.upToDate),
        );

  Future<void> checkVersion() async {
    final result = await _checkAppVersion.call(NoParams());
    result.fold(
      (_) => emit(const AppVersionState(status: AppVersionStatus.upToDate)),
      (version) => emit(
        AppVersionState(
          status: version.status,
          storeUrl: version.config?.storeUrl,
        ),
      ),
    );
  }
}
