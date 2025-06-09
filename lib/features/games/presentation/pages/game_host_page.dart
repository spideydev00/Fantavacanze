import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_session.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_status_enum.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_type_enum.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/lobby/lobby_bloc.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/truth_or_dare/truth_or_dare_bloc.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/word_bomb/word_bomb_bloc.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/never_have_i_ever/never_have_i_ever_bloc.dart';
import 'package:fantavacanze_official/features/games/presentation/pages/never_have_i_ever_page.dart';
import 'package:fantavacanze_official/features/games/presentation/pages/game_lobby_page.dart';
import 'package:fantavacanze_official/features/games/presentation/pages/truth_or_dare_page.dart';
import 'package:fantavacanze_official/features/games/presentation/pages/word_bomb_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/sections/dashboard.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameHostPage extends StatelessWidget {
  final String sessionId;

  const GameHostPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LobbyBloc, LobbyState>(
      builder: (context, lobbyState) {
        if (lobbyState is LobbySessionActive &&
            lobbyState.session.id == sessionId) {
          final gameSession = lobbyState.session;

          if (gameSession.status == GameStatus.waiting) {
            return GameLobbyPage(
              key: ValueKey(gameSession.id),
              session: gameSession,
              players: lobbyState.players,
            );
          } else if (gameSession.status == GameStatus.inProgress ||
              gameSession.status == GameStatus.paused) {
            return _buildGameScreen(context, gameSession, lobbyState.players);
          } else if (gameSession.status == GameStatus.finished) {
            return Scaffold(
                appBar: AppBar(title: Text("Partita Terminata")),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          "La partita '${gameTypeToString(gameSession.gameType)}' è terminata."),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate back to game selection or home
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                          // Optionally clear lobby state if needed
                          // context.read<LobbyBloc>().add(ClearLobbyState());
                        },
                        child: const Text("Torna alla Selezione Giochi"),
                      )
                    ],
                  ),
                ));
          }
        } else if (lobbyState is LobbyLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else if (lobbyState is LobbyError) {
          return Scaffold(
              appBar: AppBar(title: const Text("Errore!")),
              body: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lobbyState.message,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AppNavigationCubit>().setIndex(0);

                      Navigator.of(context).pushAndRemoveUntil(
                        DashboardScreen.route,
                        (route) => false,
                      );
                    },
                    child: const Text("Indietro"),
                  )
                ],
              )));
        }
        // Default or error state: navigate back or show error
        // This might happen if the session ID doesn't match or lobby state is initial.
        return Scaffold(
          appBar: AppBar(title: const Text("Caricamento...")),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("In attesa dei dati della sessione..."),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AppNavigationCubit>().setIndex(0);

                    Navigator.of(context).pushAndRemoveUntil(
                      DashboardScreen.route,
                      (route) => false,
                    );
                  },
                  label: const Text("Torna alla home"),
                  icon: const Icon(Icons.home, size: 20),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameScreen(
      BuildContext context, GameSession session, List<GamePlayer> players) {
    switch (session.gameType) {
      case GameType.truthOrDare:
        return BlocProvider(
          create: (context) => serviceLocator<TruthOrDareBloc>()
            ..add(
              InitializeTruthOrDareGame(session),
            ),
          child: const TruthOrDarePage(),
        );
      case GameType.wordBomb:
        return BlocProvider(
          create: (context) => serviceLocator<WordBombBloc>()
            ..add(
              InitializeWordBombGame(session),
            ),
          child: const WordBombPage(),
        );
      case GameType.neverHaveIEver:
        return BlocProvider(
          create: (context) => serviceLocator<NeverHaveIEverBloc>()
            ..add(
              InitializeNeverHaveIEverGame(session),
            ),
          child: const NeverHaveIEverGamePage(),
        );
    }
  }
}
