import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/app/domain/entities/app_version_config.dart';
import 'package:fpdart/fpdart.dart';

abstract class AppVersionRepository {
  Future<Either<Failure, AppVersionConfig>> getAppVersionConfig();
}
