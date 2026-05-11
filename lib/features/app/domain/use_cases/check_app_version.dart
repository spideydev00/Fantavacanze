import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/app/domain/entities/app_version_config.dart';
import 'package:fantavacanze_official/features/app/domain/repository/app_version_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

class AppVersionCheckResult {
  final AppVersionStatus status;
  final AppVersionConfig? config;

  AppVersionCheckResult({
    required this.status,
    this.config,
  });
}

class CheckAppVersion implements Usecase<AppVersionCheckResult, NoParams> {
  final AppVersionRepository appVersionRepository;

  CheckAppVersion({required this.appVersionRepository});

  @override
  Future<Either<Failure, AppVersionCheckResult>> call(NoParams params) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final localVersion = packageInfo.version;

    final response = await appVersionRepository.getAppVersionConfig();

    return response.fold(
      (_) => right(
        AppVersionCheckResult(status: AppVersionStatus.upToDate),
      ),
      (config) {
        try {
          final local = Version.parse(localVersion);

          // debugPrint("local: ${local.toString()}");
          final remote = Version.parse(config.minSupportedVersion);

          // debugPrint("remote: ${remote.toString()}");
          final status = local < remote
              ? AppVersionStatus.forceUpdate
              : AppVersionStatus.upToDate;

          return right(
            AppVersionCheckResult(
              status: status,
              config: config,
            ),
          );
        } catch (_) {
          // Failsafe: un formato inatteso non deve bloccare l'utente.
          return right(
            AppVersionCheckResult(status: AppVersionStatus.upToDate),
          );
        }
      },
    );
  }
}
