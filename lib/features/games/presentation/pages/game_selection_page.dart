import 'package:fantavacanze_official/features/games/domain/entities/game_type_enum.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/lobby/lobby_bloc.dart';
import 'package:fantavacanze_official/features/games/presentation/pages/game_host_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameSelectionPage extends StatefulWidget {
  static const String routeName = '/game_selection';

  static Route get route => MaterialPageRoute(
        builder: (context) => const GameSelectionPage(),
        settings: const RouteSettings(name: routeName),
      );
  const GameSelectionPage({super.key});

  @override
  State<GameSelectionPage> createState() => _GameSelectionPageState();
}

class _GameSelectionPageState extends State<GameSelectionPage> {
  final _inviteCodeController = TextEditingController();

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleziona Gioco Social')),
      body: BlocListener<LobbyBloc, LobbyState>(
        listener: (context, state) {
          if (state is LobbySessionActive) {
            // Navigate to GameHostPage when a session becomes active
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => GameHostPage(sessionId: state.session.id),
              ),
            );
          } else if (state is LobbyError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<LobbyBloc, LobbyState>(
          builder: (context, state) {
            if (state is LobbyLoading) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  if (state.message != null) ...[
                    const SizedBox(height: 16),
                    Text(state.message!),
                  ]
                ],
              ));
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Crea una nuova partita:',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Example: Create a Truth or Dare game
                      context.read<LobbyBloc>().add(
                          const CreateSessionRequested(GameType.truthOrDare));
                    },
                    child: const Text('Crea Verità o Obbligo'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      context.read<LobbyBloc>().add(
                          const CreateSessionRequested(GameType.wordBombGhost));
                    },
                    child: const Text('Crea Word Bomb: Ghost Protocol'),
                  ),
                  const SizedBox(height: 40),
                  Text('Oppure unisciti con un codice:',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _inviteCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Codice Invito',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 6,
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_inviteCodeController.text.isNotEmpty) {
                        context.read<LobbyBloc>().add(JoinSessionRequested(
                            _inviteCodeController.text.trim().toUpperCase()));
                      }
                    },
                    child: const Text('Unisciti alla Partita'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
