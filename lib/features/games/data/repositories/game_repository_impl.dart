import 'package:fpdart/fpdart.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/network/connection_checker.dart';
import 'package:fantavacanze_official/features/games/data/datasources/game_remote_data_source.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_session.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_type_enum.dart';
import 'package:fantavacanze_official/features/games/domain/repositories/game_repository.dart';

class GameRepositoryImpl implements GameRepository {
  final GameRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;

  GameRepositoryImpl({
    required this.remoteDataSource,
    required this.connectionChecker,
  });

  Future<Either<Failure, T>> _handleRequest<T>(
      Future<T> Function() request) async {
    if (!await connectionChecker.isConnected) {
      return Left(Failure('Nessuna connessione internet.'));
    }
    try {
      final result = await request();
      return Right(result);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Stream<Either<Failure, T>> _handleStreamRequest<T>(
      Stream<T> Function() requestStream) async* {
    if (!await connectionChecker.isConnected) {
      yield Left(Failure('Nessuna connessione internet.'));
      return;
    }
    try {
      await for (final data in requestStream()) {
        yield Right(data);
      }
    } on ServerException catch (e) {
      yield Left(Failure(e.message));
    } catch (e) {
      yield Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GameSession>> createGameSession({
    required String adminId,
    required GameType gameType,
  }) async {
    return _handleRequest(() => remoteDataSource.createGameSession(
          adminId: adminId,
          gameType: gameType,
        ));
  }

  @override
  Future<Either<Failure, GameSession>> joinGameSession({
    required String inviteCode,
    required String userId,
    required String userName,
    String? userAvatarUrl,
  }) async {
    return _handleRequest(() => remoteDataSource.joinGameSession(
          inviteCode: inviteCode,
          userId: userId,
          userName: userName,
          userAvatarUrl: userAvatarUrl,
        ));
  }

  @override
  Future<Either<Failure, void>> leaveGameSession(
      {required String sessionId, required String userId}) async {
    return _handleRequest(() => remoteDataSource.leaveGameSession(
        sessionId: sessionId, userId: userId));
  }

  @override
  Stream<Either<Failure, GameSession>> streamGameSession(
      {required String sessionId}) {
    return _handleStreamRequest(
        () => remoteDataSource.streamGameSession(sessionId: sessionId));
  }

  @override
  Stream<Either<Failure, List<GamePlayer>>> streamLobbyPlayers(
      {required String sessionId}) {
    return _handleStreamRequest(
        () => remoteDataSource.streamLobbyPlayers(sessionId: sessionId));
  }

  @override
  Future<Either<Failure, GameSession>> updateGameState({
    required String sessionId,
    required Map<String, dynamic> newGameState,
    String? currentTurnUserId,
    String? status,
  }) async {
    return _handleRequest(() => remoteDataSource.updateGameState(
          sessionId: sessionId,
          newGameState: newGameState,
          currentTurnUserId: currentTurnUserId,
          status: status,
        ));
  }

  @override
  Future<Either<Failure, GamePlayer>> updateGamePlayer({
    required String playerId,
    required String sessionId,
    required String userId,
    int? score,
    bool? isGhost,
    bool? hasUsedSpecialAbility,
  }) async {
    return _handleRequest(() => remoteDataSource.updateGamePlayer(
          playerId: playerId,
          sessionId: sessionId,
          userId: userId,
          score: score,
          isGhost: isGhost,
          hasUsedSpecialAbility: hasUsedSpecialAbility,
        ));
  }
}
