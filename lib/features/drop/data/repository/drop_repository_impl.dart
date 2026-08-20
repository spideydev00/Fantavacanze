import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/drop/data/datasources/drop_remote_data_source.dart';
import 'package:fantavacanze_official/features/drop/domain/entities/drop.dart';
import 'package:fantavacanze_official/features/drop/domain/repository/drop_repository.dart';
import 'package:fpdart/fpdart.dart';

class DropRepositoryImpl implements DropRepository {
  final DropRemoteDataSource remoteDataSource;

  DropRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DropCheck>> getDropCheck() async {
    try {
      final results = await Future.wait<Object?>([
        remoteDataSource.getActiveDrop(),
        remoteDataSource.getLastSeenDrop(),
      ]);
      return right(
        DropCheck(
          drop: results[0] as Drop?,
          lastSeenDrop: results[1] as String?,
        ),
      );
    } on ServerException catch (error) {
      return left(Failure(error.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> markSeen(String code) async {
    try {
      await remoteDataSource.markSeen(code);
      return right(unit);
    } on ServerException catch (error) {
      return left(Failure(error.message));
    }
  }
}
