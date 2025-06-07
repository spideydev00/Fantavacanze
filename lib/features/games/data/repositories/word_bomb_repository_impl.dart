import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/network/connection_checker.dart';
import 'package:fantavacanze_official/features/games/data/datasources/word_bomb_remote_data_source.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/word_bomb_repository.dart';

class WordBombRepositoryImpl implements WordBombRepository {
  final WordBombRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;

  WordBombRepositoryImpl({
    required this.remoteDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, List<String>>> getWordBombCategories() async {
    if (!await connectionChecker.isConnected) {
      return Left(Failure('Nessuna connessione internet.'));
    }
    try {
      final categories = await remoteDataSource.getWordBombCategories();
      return Right(categories);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
