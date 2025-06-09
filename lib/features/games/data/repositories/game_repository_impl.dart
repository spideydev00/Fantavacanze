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
  Future<Either<Failure, GameSession>> createGameSession(
      {required String adminId,
      required GameType gameType,
      required String userName}) async {
    return _handleRequest(() => remoteDataSource.createGameSession(
          adminId: adminId,
          gameType: gameType,
          userName: userName,
        ));
  }

  @override
  Future<Either<Failure, GameSession>> joinGameSession({
    required String inviteCode,
    required String userId,
    required String userName,
  }) async {
    return _handleRequest(() => remoteDataSource.joinGameSession(
          inviteCode: inviteCode,
          userId: userId,
          userName: userName,
        ));
  }

  @override
  Future<Either<Failure, bool>> leaveGameSession(
      {required String sessionId, required String userId}) async {
    return _handleRequest<bool>(() => remoteDataSource.leaveGameSession(
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
    Map<String, dynamic>? newGameState,
    String? currentTurnUserId,
    String? status,
  }) async {
    if (!await (connectionChecker.isConnected)) {
      return Left(Failure('Nessuna connessione internet.'));
    }
    try {
      final gameSessionModel = await remoteDataSource.updateGameState(
        sessionId: sessionId,
        newGameState: newGameState,
        currentTurnUserId: currentTurnUserId,
        status: status,
      );
      return Right(gameSessionModel);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, GamePlayer>> updateGamePlayer({
    required String playerId,
    required String sessionId,
    required String userId,
    int? score,
    bool? isGhost,
    bool? hasUsedSpecialAbility,
    bool? hasUsedGhostProtocol,
    int? changeCategoryUsesLeft,
  }) async {
    return _handleRequest(
      () => remoteDataSource.updateGamePlayer(
        playerId: playerId,
        sessionId: sessionId,
        userId: userId,
        score: score,
        isGhost: isGhost,
        hasUsedSpecialAbility: hasUsedSpecialAbility,
        hasUsedGhostProtocol: hasUsedGhostProtocol,
        changeCategoryUsesLeft: changeCategoryUsesLeft,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> updateGamePlayerNameInLobby({
    required String playerId,
    required String newName,
    required String sessionId,
  }) async {
    return _handleRequest(
      () => remoteDataSource.updateGamePlayerNameInLobbyDb(
        playerId: playerId,
        newName: newName,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> removeGamePlayerFromLobby({
    required String playerId,
    required String sessionId,
  }) async {
    return _handleRequest(
      () => remoteDataSource.removeGamePlayerFromLobbyDb(
        playerId: playerId,
        sessionId: sessionId,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> killSession({required String sessionId}) async {
    return _handleRequest(() => remoteDataSource.killSession(
          sessionId: sessionId,
        ));
  }
}
