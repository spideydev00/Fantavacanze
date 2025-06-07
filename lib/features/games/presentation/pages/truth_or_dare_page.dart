import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';
import 'package:fantavacanze_official/features/games/domain/entities/truth_or_dare_question.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/truth_or_dare/truth_or_dare_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TruthOrDarePage extends StatelessWidget {
  const TruthOrDarePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verità o Obbligo')),
      body: BlocConsumer<TruthOrDareBloc, TruthOrDareState>(
        listener: (context, state) {
          if (state is TruthOrDareError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is TruthOrDareLoading || state is TruthOrDareInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TruthOrDareGameReady) {
            final GamePlayer? currentPlayer;
            final String? currentTurnUserId = state.session.currentTurnUserId;
            GamePlayer? foundPlayer;

            if (currentTurnUserId != null) {
              try {
                foundPlayer = state.players
                    .firstWhere((p) => p.userId == currentTurnUserId);
              } catch (e) {
                // Player with currentTurnUserId not found in the list
                foundPlayer = null;
              }
            }

            if (foundPlayer != null) {
              currentPlayer = foundPlayer;
            } else if (state.players.isNotEmpty) {
              // Fallback to the first player in the list if currentTurnUserId is null or player not found
              currentPlayer = state.players.first;
            } else {
              // No players in the list
              currentPlayer = null;
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Turno di: ${currentPlayer?.userName ?? "N/A"}',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (state.currentQuestion != null)
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              state.currentQuestion!.type ==
                                      TruthOrDareCardType.truth
                                  ? 'VERITÀ'
                                  : 'OBBLIGO',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: state.currentQuestion!.type ==
                                            TruthOrDareCardType.truth
                                        ? Colors.blueAccent
                                        : Colors.redAccent,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              state.currentQuestion!.content,
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (state.isAdmin &&
                      state.session.currentTurnUserId != null) ...[
                    if (state.currentQuestion == null) ...[
                      ElevatedButton(
                        onPressed: () => context.read<TruthOrDareBloc>().add(
                            const CardTypeChosen(TruthOrDareCardType.truth)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent),
                        child: const Text('Pesca Verità'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => context.read<TruthOrDareBloc>().add(
                            const CardTypeChosen(TruthOrDareCardType.dare)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        child: const Text('Pesca Obbligo'),
                      ),
                    ] else ...[
                      ElevatedButton(
                        onPressed: () {
                          // Logic to select next player - for simplicity, admin picks from a list or cycles
                          // This example just picks the next in list, or first if current is last
                          if (state.players.isNotEmpty) {
                            int currentIndex = state.players.indexWhere((p) =>
                                p.userId == state.session.currentTurnUserId);
                            String nextPlayerId = state
                                .players[
                                    (currentIndex + 1) % state.players.length]
                                .userId;
                            context
                                .read<TruthOrDareBloc>()
                                .add(NextPlayerTurn(nextPlayerId));
                          }
                        },
                        child: const Text('Prossimo Giocatore / Nuova Carta'),
                      ),
                    ],
                    const SizedBox(height: 20),
                    // Dropdown to select next player (for admin)
                    if (state.players.isNotEmpty)
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: "Seleziona giocatore di turno"),
                        value: state.session.currentTurnUserId,
                        items: state.players
                            .map((player) => DropdownMenuItem(
                                  value: player.userId,
                                  child: Text(player.userName),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context
                                .read<TruthOrDareBloc>()
                                .add(NextPlayerTurn(value));
                          }
                        },
                      ),
                  ],
                  if (!state.isAdmin &&
                      state.session.currentTurnUserId != null &&
                      state.currentQuestion == null)
                    Text(
                      "In attesa che l'admin (${state.players.firstWhere((p) => p.userId == state.session.adminId).userName}) scelga una carta...",
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          }
          return const Center(
              child: Text('Errore caricamento gioco Verità o Obbligo.'));
        },
      ),
    );
  }
}
