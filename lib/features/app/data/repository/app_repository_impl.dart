import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/app/data/datasources/app_remote_data_source.dart';
import 'package:fantavacanze_official/features/app/domain/entities/app_status.dart';
import 'package:fantavacanze_official/features/app/domain/repository/app_repository.dart';
import 'package:fpdart/fpdart.dart';

class AppRepositoryImpl implements AppRepository {
  final AppRemoteDataSource remoteDataSource;

  AppRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AppStatus>> getAppStatus() async {
    try {
      final response = await remoteDataSource.getAppStatus();

      return right(
        AppStatus(status: response.status),
      );
    } on ServerException catch (e) {
      return left(
        Failure(e.message),
      );
    }
  }
}
