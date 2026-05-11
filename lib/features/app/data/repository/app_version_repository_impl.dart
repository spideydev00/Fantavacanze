import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/app/data/datasources/app_version_remote_data_source.dart';
import 'package:fantavacanze_official/features/app/domain/entities/app_version_config.dart';
import 'package:fantavacanze_official/features/app/domain/repository/app_version_repository.dart';
import 'package:fpdart/fpdart.dart';

class AppVersionRepositoryImpl implements AppVersionRepository {
  final AppVersionRemoteDataSource remoteDataSource;

  AppVersionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AppVersionConfig>> getAppVersionConfig() async {
    try {
      final response = await remoteDataSource.getAppVersionConfig();

      return right(
        AppVersionConfig(
          minSupportedVersion: response.minSupportedVersion,
          storeUrl: response.storeUrl,
        ),
      );
    } on ServerException catch (e) {
      return left(
        Failure(
          'Impossibile recuperare la configurazione versione app: ${e.message}',
        ),
      );
    }
  }
}
