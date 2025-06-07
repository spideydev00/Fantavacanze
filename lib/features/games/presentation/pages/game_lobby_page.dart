import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_session.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/lobby/lobby_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

class GameLobbyPage extends StatelessWidget {
  final GameSession session;
  final List<GamePlayer> players;

  const GameLobbyPage(
      {super.key, required this.session, required this.players});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AppUserCubit>().state;
    bool isAdmin = false;
    if (currentUser is AppUserIsLoggedIn) {
      isAdmin = currentUser.user.id == session.adminId;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Lobby: ${session.inviteCode}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              SharePlus.instance.share(ShareParams(
                  text:
                      'Unisciti alla mia partita su Fantavacanze! Codice: ${session.inviteCode}'));
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: session.inviteCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Codice invito copiato!')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Gioco: ${session.gameType.toString().split('.').last}',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Codice Invito: ${session.inviteCode}',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                        'Admin: ${players.firstWhere((p) => p.userId == session.adminId, orElse: () => GamePlayer(id: '', sessionId: '', userId: session.adminId, userName: 'Admin', joinedAt: DateTime.now())).userName}',
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Giocatori (${players.length}):',
                style: Theme.of(context).textTheme.headlineSmall),
            Expanded(
              child: players.isEmpty
                  ? const Center(
                      child: Text('Nessun giocatore ancora. In attesa...'))
                  : ListView.builder(
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final player = players[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              // backgroundImage: player.userAvatarUrl != null ? NetworkImage(player.userAvatarUrl!) : null,
                              child: player.userAvatarUrl == null
                                  ? Text(player.userName
                                      .substring(0, 1)
                                      .toUpperCase())
                                  : null,
                            ),
                            title: Text(player.userName),
                            trailing: player.userId == session.adminId
                                ? const Icon(Icons.star, color: Colors.amber)
                                : null,
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            if (isAdmin)
              ElevatedButton(
                onPressed:
                    (context.watch<LobbyBloc>().state as LobbySessionActive)
                            .isLoadingNextAction
                        ? null
                        : () {
                            // Add a check for minimum players if needed for the game type
                            // e.g., if (players.length < 2 && session.gameType == GameType.wordBombGhost) { ... show error ... return; }
                            context
                                .read<LobbyBloc>()
                                .add(StartGameRequested(session.id));
                          },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: (context.watch<LobbyBloc>().state as LobbySessionActive)
                        .isLoadingNextAction
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ))
                    : const Text('Inizia Partita'),
              ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                context
                    .read<LobbyBloc>()
                    .add(LeaveSessionRequested(session.id));
                // Navigator.of(context).pop(); // Pop back to selection, LobbyBloc will handle state change
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Theme.of(context).colorScheme.error),
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Esci dalla Lobby'),
            ),
          ],
        ),
      ),
    );
  }
}
