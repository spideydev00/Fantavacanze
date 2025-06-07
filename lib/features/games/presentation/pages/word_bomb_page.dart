import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/word_bomb/word_bomb_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart'; // Import AppUserCubit

class WordBombPage extends StatefulWidget {
  const WordBombPage({super.key});

  @override
  State<WordBombPage> createState() => _WordBombPageState();
}

class _WordBombPageState extends State<WordBombPage> {
  final _wordController = TextEditingController();

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get myId from AppUserCubit
    final appUserState = context.watch<AppUserCubit>().state;
    String? myId;
    if (appUserState is AppUserIsLoggedIn) {
      myId = appUserState.user.id;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Word Bomb: Ghost Protocol')),
      body: BlocConsumer<WordBombBloc, WordBombState>(
        listener: (context, state) {
          if (state is WordBombError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is WordBombGameActive || state is WordBombPaused) {
            // Clear text field when turn changes or game state updates significantly
            // This is a basic way, might need more nuanced logic
            final currentTurnUserId = state is WordBombGameActive
                ? state.session.currentTurnUserId
                : (state as WordBombPaused).session.currentTurnUserId;
            if (myId == currentTurnUserId) {
              // _wordController.clear(); // Potentially annoying if cleared too often
            }
          }
        },
        builder: (context, state) {
          if (state is WordBombLoading || state is WordBombInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WordBombGameActive || state is WordBombPaused) {
            final gameSession = state is WordBombGameActive
                ? state.session
                : (state as WordBombPaused).session;
            final gameState = state is WordBombGameActive
                ? state.gameState
                : (state as WordBombPaused).gameState;
            final players = state is WordBombGameActive
                ? state.players
                : (state as WordBombPaused).players;
            final isAdmin = state is WordBombGameActive
                ? state.isAdmin
                : (state as WordBombPaused).isAdmin;
            final currentPlayerName = state is WordBombGameActive
                ? state.currentPlayerName
                : (state as WordBombPaused).currentPlayerName;
            // final myId = context.read<WordBombBloc>()._currentUser?.id; // Removed this line
            final isMyTurn = myId == gameSession.currentTurnUserId;

            if (gameState.isPaused && myId != gameSession.currentTurnUserId) {
              return Center(
                child: Card(
                  margin: const EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Gioco in Pausa!",
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 10),
                        Text(
                            "${currentPlayerName ?? "Qualcuno"} sta subendo una penalità o il gioco è in pausa."),
                        const SizedBox(height: 20),
                        if (isAdmin)
                          ElevatedButton(
                            onPressed: () => context
                                .read<WordBombBloc>()
                                .add(const ResumeGameTriggered()),
                            child: const Text("Riprendi Gioco (Admin)"),
                          )
                        else
                          const Text(
                              "In attesa che l'admin riprenda il gioco..."),
                      ],
                    ),
                  ),
                ),
              );
            }
            if (gameState.isPaused && isMyTurn) {
              // Current player caused the pause
              return Center(
                child: Card(
                  margin: const EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Ops! Penalità!",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(color: Colors.red)),
                        const SizedBox(height: 10),
                        const Text(
                            "Hai sbagliato o il tempo è scaduto. Bevi!"), // Example penalty
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => context.read<WordBombBloc>().add(
                              const ResumeGameTriggered()), // Player acknowledges penalty
                          child: const Text("Ho Bevuto! Continua."),
                        ),
                        if (isAdmin &&
                            myId !=
                                gameSession
                                    .adminId) // Admin can force continue if player is stuck
                          TextButton(
                            onPressed: () => context
                                .read<WordBombBloc>()
                                .add(const ResumeGameTriggered()),
                            child: const Text("Forza Ripresa (Admin)"),
                          )
                      ],
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Text('Turno di: ${currentPlayerName ?? "N/A"}',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 5),
                      Text('Categoria: ${gameState.currentCategory}',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(
                          'Lettera/Sillaba: ${gameState.currentLetterSyllable.toUpperCase()}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor)),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: gameState.totalTurnTimeMs > 0
                            ? gameState.remainingTimeMs /
                                gameState.totalTurnTimeMs
                            : 0, // Use gameState.totalTurnTimeMs
                        minHeight: 10,
                      ),
                      Text(
                          '${(gameState.remainingTimeMs / 1000).toStringAsFixed(1)}s',
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  if (isMyTurn)
                    TextField(
                      controller: _wordController,
                      decoration: const InputDecoration(
                        labelText: 'Scrivi una parola...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          context.read<WordBombBloc>().add(SubmitWord(value));
                          _wordController.clear();
                        }
                      },
                    )
                  else
                    Center(
                        child: Text(
                      "In attesa di ${currentPlayerName ?? "..."}",
                      style: Theme.of(context).textTheme.titleMedium,
                    )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isMyTurn)
                        ElevatedButton(
                          onPressed: () {
                            if (_wordController.text.isNotEmpty) {
                              context
                                  .read<WordBombBloc>()
                                  .add(SubmitWord(_wordController.text));
                              _wordController.clear();
                            }
                          },
                          child: const Text('Invia Parola'),
                        ),
                      const SizedBox(height: 10),
                      Text(
                        'Parole Usate: ${gameState.usedWords.join(", ")}',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      if (isAdmin) ...[
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: () => context
                              .read<WordBombBloc>()
                              .add(const NextPlayerTurnRequested()),
                          child: const Text('Salta Turno (Admin)'),
                        ),
                        const SizedBox(height: 5),
                        OutlinedButton(
                          onPressed: () {
                            if (gameState.isPaused) {
                              context
                                  .read<WordBombBloc>()
                                  .add(const ResumeGameTriggered());
                            } else {
                              context
                                  .read<WordBombBloc>()
                                  .add(const PauseGameTriggered());
                            }
                          },
                          child: Text(gameState.isPaused
                              ? 'Riprendi Gioco (Admin)'
                              : 'Metti in Pausa (Admin)'),
                        ),
                        if (players.isNotEmpty &&
                            gameState.ghostPlayerId == null) ...[
                          // Show only if ghost not assigned
                          const SizedBox(height: 5),
                          Text("Assegna Fantasma (Admin):",
                              style: Theme.of(context).textTheme.labelSmall),
                          DropdownButtonFormField<String>(
                              items: players
                                  .map((p) => DropdownMenuItem(
                                      value: p.id, child: Text(p.userName)))
                                  .toList(),
                              onChanged: (playerId) {
                                if (playerId != null) {
                                  context
                                      .read<WordBombBloc>()
                                      .add(AssignGhostRole(playerId));
                                }
                              },
                              hint: const Text("Scegli un giocatore")),
                        ] else if (gameState.ghostPlayerId != null) ...[
                          Text(
                              "Fantasma: ${players.firstWhere((p) => p.userId == gameState.ghostPlayerId, orElse: () => GamePlayer(id: '', sessionId: '', userId: '', userName: 'N/D', joinedAt: DateTime.now())).userName}",
                              style: Theme.of(context).textTheme.labelMedium)
                        ]
                      ]
                    ],
                  )
                ],
              ),
            );
          }
          return const Center(child: Text('Errore caricamento Word Bomb.'));
        },
      ),
    );
  }
}
