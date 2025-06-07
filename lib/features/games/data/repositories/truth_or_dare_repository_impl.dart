import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/network/connection_checker.dart';
import 'package:fantavacanze_official/features/games/data/datasources/truth_or_dare_remote_data_source.dart';
import 'package:fantavacanze_official/features/games/domain/entities/truth_or_dare_question.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/truth_or_dare_repository.dart';

class TruthOrDareRepositoryImpl implements TruthOrDareRepository {
  final TruthOrDareRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;

  TruthOrDareRepositoryImpl({
    required this.remoteDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, List<TruthOrDareQuestion>>> getTruthOrDareCards(
      {int limit = 50}) async {
    if (!await connectionChecker.isConnected) {
      return Left(Failure('Nessuna connessione internet.'));
    }
    try {
      final questions =
          await remoteDataSource.getTruthOrDareCards(limit: limit);
      return Right(questions);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
