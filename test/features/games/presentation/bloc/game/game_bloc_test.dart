import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_session.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_status_enum.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_type_enum.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/create_game_session.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/join_game_session.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/kill_game_session.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/leave_game_session.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/remove_game_player_from_lobby.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/stream_game_session.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/stream_lobby_players.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/stream_lobby_presence.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/update_game_player_name_in_lobby.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/update_game_state.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/game/game_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateGameSession extends Mock implements CreateGameSession {}

class MockJoinGameSession extends Mock implements JoinGameSession {}

class MockLeaveGameSession extends Mock implements LeaveGameSession {}

class MockStreamGameSession extends Mock implements StreamGameSession {}

class MockStreamLobbyPlayers extends Mock implements StreamLobbyPlayers {}

class MockStreamLobbyPresence extends Mock implements StreamLobbyPresence {}

class MockUpdateGameState extends Mock implements UpdateGameState {}

class MockKillGameSession extends Mock implements KillGameSession {}

class MockUpdateGamePlayerNameInLobby extends Mock
    implements UpdateGamePlayerNameInLobby {}

class MockRemoveGamePlayerFromLobby extends Mock
    implements RemoveGamePlayerFromLobby {}

class MockAppUserCubit extends Mock implements AppUserCubit {}

class FakeCreateGameSessionParams extends Fake
    implements CreateGameSessionParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeCreateGameSessionParams());
  });

  group('LobbyBloc', () {
    late CreateGameSession createGameSession;
    late JoinGameSession joinGameSession;
    late LeaveGameSession leaveGameSession;
    late StreamGameSession streamGameSession;
    late StreamLobbyPlayers streamLobbyPlayers;
    late StreamLobbyPresence streamLobbyPresence;
    late UpdateGameState updateGameState;
    late KillGameSession killGameSession;
    late UpdateGamePlayerNameInLobby updateGamePlayerNameInLobby;
    late RemoveGamePlayerFromLobby removeGamePlayerFromLobby;
    late AppUserCubit appUserCubit;
    late StreamController<Either<Failure, GameSession>> sessionController;
    late StreamController<Either<Failure, List<GamePlayer>>> playersController;
    late StreamController<Either<Failure, Set<String>>> presenceController;

    const user = User(
      id: 'u1',
      email: 'ann@example.com',
      name: 'Ann',
      gender: 'female',
      isOnboarded: true,
      isAdult: true,
      isWordBombTrialAvailable: true,
      sentimentalStatus: 'single',
    );

    final session = GameSession(
      id: 's1',
      inviteCode: 'ABC123',
      adminId: 'u1',
      gameType: GameType.truthOrDare,
      status: GameStatus.waiting,
      createdAt: DateTime(2026, 6, 30),
    );

    final player = GamePlayer(
      id: 'p1',
      sessionId: 's1',
      userId: 'u1',
      userName: 'Ann',
      joinedAt: DateTime(2026, 6, 30, 10),
    );

    LobbyBloc buildBloc() {
      when(() => appUserCubit.state).thenReturn(
        AppUserIsLoggedIn(user: user),
      );
      when(() => createGameSession(any())).thenAnswer((_) async {
        return right(session);
      });
      when(() => streamGameSession(any())).thenAnswer(
        (_) => sessionController.stream,
      );
      when(() => streamLobbyPlayers(any())).thenAnswer(
        (_) => playersController.stream,
      );
      when(() => streamLobbyPresence(any())).thenAnswer(
        (_) => presenceController.stream,
      );

      return LobbyBloc(
        createGameSession: createGameSession,
        joinGameSession: joinGameSession,
        leaveGameSession: leaveGameSession,
        streamGameSession: streamGameSession,
        streamLobbyPlayers: streamLobbyPlayers,
        streamLobbyPresence: streamLobbyPresence,
        updateGameState: updateGameState,
        appUserCubit: appUserCubit,
        killGameSession: killGameSession,
        updateGamePlayerNameInLobby: updateGamePlayerNameInLobby,
        removeGamePlayerFromLobby: removeGamePlayerFromLobby,
      );
    }

    setUp(() {
      createGameSession = MockCreateGameSession();
      joinGameSession = MockJoinGameSession();
      leaveGameSession = MockLeaveGameSession();
      streamGameSession = MockStreamGameSession();
      streamLobbyPlayers = MockStreamLobbyPlayers();
      streamLobbyPresence = MockStreamLobbyPresence();
      updateGameState = MockUpdateGameState();
      killGameSession = MockKillGameSession();
      updateGamePlayerNameInLobby = MockUpdateGamePlayerNameInLobby();
      removeGamePlayerFromLobby = MockRemoveGamePlayerFromLobby();
      appUserCubit = MockAppUserCubit();
      sessionController = StreamController.broadcast();
      playersController = StreamController.broadcast();
      presenceController = StreamController.broadcast();
    });

    tearDown(() async {
      await sessionController.close();
      await playersController.close();
      await presenceController.close();
    });

    blocTest<LobbyBloc, LobbyState>(
      'consumes session, players and presence streams without delay',
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const CreateSessionRequested(GameType.truthOrDare));
        await Future<void>.delayed(Duration.zero);
        sessionController.add(right(session));
        playersController.add(right([player]));
        presenceController.add(right({'u1'}));
      },
      expect: () => [
        isA<LobbyLoading>(),
        isA<LobbySessionActive>()
            .having((state) => state.session.id, 'session id', 's1')
            .having((state) => state.players, 'players', isEmpty),
        isA<LobbySessionActive>().having(
          (state) => state.players,
          'players',
          [player],
        ),
        isA<LobbySessionActive>().having(
          (state) => state.onlinePlayerIds,
          'online user ids',
          {'u1'},
        ),
      ],
      verify: (_) {
        verify(() => streamGameSession('s1')).called(1);
        verify(() => streamLobbyPlayers('s1')).called(1);
        verify(() => streamLobbyPresence('s1')).called(1);
      },
    );
  });
}
