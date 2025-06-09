import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/network/connection_checker.dart';
import 'package:fantavacanze_official/features/games/data/datasources/never_have_i_ever_remote_data_source.dart';
import 'package:fantavacanze_official/features/games/domain/entities/never_have_i_ever_question.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/never_have_i_ever_repository.dart';

class NeverHaveIEverRepositoryImpl implements NeverHaveIEverRepository {
  final NeverHaveIEverRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;

  NeverHaveIEverRepositoryImpl({
    required this.remoteDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, List<NeverHaveIEverQuestion>>> getNeverHaveIEverCards({
    required String sessionId, // Add sessionId
    int limit = 200,
  }) async {
    if (!await connectionChecker.isConnected) {
      return Left(Failure('Nessuna connessione internet.'));
    }
    try {
      final questions = await remoteDataSource.getNeverHaveIEverCards(
        sessionId: sessionId, // Pass sessionId
        limit: limit,
      );
      return Right(questions);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('Errore imprevisto: ${e.toString()}'));
    }
  }
}
