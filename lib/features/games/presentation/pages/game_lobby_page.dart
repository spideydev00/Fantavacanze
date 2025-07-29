import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_page_specific_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/info_banner.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_session.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_type_enum.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/game/game_bloc.dart';
import 'package:fantavacanze_official/features/games/presentation/widgets/edit_game_player_name_dialog.dart'; // Import new dialog
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart'; // Import ConfirmationDialog
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/team_info/widgets/section_card.dart';
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

    // Safely get admin name
    GamePlayer? adminPlayer;
    for (final player in players) {
      if (player.userId == session.adminId) {
        adminPlayer = player;
        break;
      }
    }

    String getGameName(GameSession session) {
      // Get the enum value as a string (e.g., "truthOrDare")
      GameType gameType = session.gameType;

      String formattedName = '';

      switch (gameType) {
        case GameType.truthOrDare:
          formattedName = 'Obbligo o Verità';
        case GameType.neverHaveIEver:
          formattedName = 'Non Ho Mai...';
        case GameType.wordBomb:
          formattedName = 'Word Bomb';
      }

      return formattedName;
    }

    final String adminName = adminPlayer?.userName ?? 'Admin';

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        backgroundColor: context.bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: context.textPrimaryColor),
        title: Text('Lobby: ${session.inviteCode}',
            style: context.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: context.textPrimaryColor),
            onPressed: () {
              SharePlus.instance.share(ShareParams(
                  text:
                      'Unisciti alla mia partita su Fantavacanze! Codice: ${session.inviteCode}'));
            },
          ),
          IconButton(
            icon: Icon(Icons.copy, color: context.textPrimaryColor),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: session.inviteCode));
              showSpecificSnackBar(
                context,
                "Codice invito copiato!",
                color: ColorPalette.success,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: ThemeSizes.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SectionCard(
                title: 'Info Partita',
                icon: Icons.info_outline_rounded,
                child: Padding(
                  padding: const EdgeInsets.all(ThemeSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        icon: Icons.gamepad_rounded,
                        label: 'Gioco',
                        value: getGameName(session),
                      ),
                      const SizedBox(height: ThemeSizes.sm),
                      _InfoRow(
                          icon: Icons.vpn_key_rounded,
                          label: 'Codice Invito',
                          value: session.inviteCode),
                      const SizedBox(height: ThemeSizes.sm),
                      _InfoRow(
                          icon: Icons.admin_panel_settings_rounded,
                          label: 'Admin',
                          value: adminName),
                    ],
                  ),
                ),
              ),
              session.gameType == GameType.wordBomb
                  ? SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeSizes.lg,
                        vertical: ThemeSizes.md,
                      ),
                      child: InfoBanner(
                        message:
                            "Attendi l'ingresso di tutti i partecipanti oppure avvia subito se volete giocare su un singolo dispositivo.",
                        color: ColorPalette.info,
                      ),
                    ),
              SectionCard(
                title: 'Giocatori (${players.length})',
                icon: Icons.people_alt_rounded,
                child: players.isEmpty
                    ? Center(
                        child: Text(
                          'Nessun giocatore ancora. In attesa...',
                          style: context.textTheme.bodyMedium,
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: players.length,
                        padding: const EdgeInsets.symmetric(
                          vertical: ThemeSizes.sm,
                        ),
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          thickness: 1,
                          color: context.borderColor.withValues(alpha: 0.05),
                          indent: ThemeSizes.md,
                          endIndent: ThemeSizes.md,
                        ),
                        itemBuilder: (context, index) {
                          final player = players[index];
                          final bool isCurrentUserAdmin = isAdmin;
                          final bool isThisPlayerTheAdmin =
                              player.userId == session.adminId;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  context.primaryColor.withValues(alpha: 0.1),
                              foregroundColor: context.primaryColor,
                              child: Text(
                                player.userName.substring(0, 1).toUpperCase(),
                              ),
                            ),
                            title: Text(
                              player.userName,
                              style: context.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isThisPlayerTheAdmin)
                                  Icon(Icons.star_rounded,
                                      color: Colors.amber.shade600),
                                if (isCurrentUserAdmin) ...[
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        color: context.textPrimaryColor
                                            .withValues(alpha: 0.7)),
                                    onPressed: () =>
                                        _showEditGamePlayerNameDialog(
                                            // Changed method name
                                            context,
                                            player,
                                            session.id),
                                  ),
                                  if (!isThisPlayerTheAdmin)
                                    IconButton(
                                      icon: Icon(Icons.delete,
                                          color: ColorPalette.error
                                              .withValues(alpha: 0.7)),
                                      onPressed: () => _showRemovePlayerDialog(
                                          context, player, session.id),
                                    ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: ThemeSizes.xl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
                child: isAdmin
                    ? Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: (context.watch<LobbyBloc>().state
                                        as LobbySessionActive)
                                    .isLoadingNextAction
                                ? null
                                : () {
                                    context
                                        .read<LobbyBloc>()
                                        .add(StartGameRequested(session.id));
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (context.watch<LobbyBloc>().state
                                          as LobbySessionActive)
                                      .isLoadingNextAction
                                  ? ColorPalette.info.withValues(
                                      alpha: 0.7,
                                    )
                                  : ColorPalette.info,
                            ),
                            icon: Icon(
                              Icons.play_arrow_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                            label: Text(
                              'Inizia Partita',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: ThemeSizes.md),
                          OutlinedButton(
                            onPressed: () {
                              context
                                  .read<LobbyBloc>()
                                  .add(LeaveSessionRequested(session.id));
                            },
                            style: OutlinedButton.styleFrom(
                              fixedSize: Size.fromWidth(
                                Constants.getWidth(context) * 0.75,
                              ),
                              side: BorderSide(
                                color: ColorPalette.info,
                                width: 1.5,
                              ),
                              foregroundColor: ColorPalette.info,
                            ),
                            child: Text(
                              'Esci dalla Lobby',
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              context
                                  .read<LobbyBloc>()
                                  .add(LeaveSessionRequested(session.id));
                            },
                            style: OutlinedButton.styleFrom(
                              fixedSize: Size.fromWidth(
                                Constants.getWidth(context) * 0.75,
                              ),
                              side: BorderSide(
                                color: ColorPalette.info,
                                width: 1.5,
                              ),
                              foregroundColor: ColorPalette.info,
                            ),
                            child: Text(
                              'Esci dalla Lobby',
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: ThemeSizes.xl),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditGamePlayerNameDialog(
      // Renamed from _showEditNameDialog
      BuildContext context,
      GamePlayer player,
      String sessionId) {
    EditGamePlayerNameDialog.show(
      context,
      player: player,
      sessionId: sessionId,
    );
  }

  void _showRemovePlayerDialog(
      BuildContext context, GamePlayer player, String sessionId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return ConfirmationDialog.delete(
          itemType: 'giocatore ${player.userName}',
          customMessage:
              'Sei sicuro di voler rimuovere ${player.userName} dalla lobby?',
          onDelete: () {
            context.read<LobbyBloc>().add(
                  RemovePlayerFromLobbyRequested(player.id, sessionId),
                );
            // Navigator.of(dialogContext).pop(); // ConfirmationDialog handles its own dismissal
          },
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: context.primaryColor,
          size: 20,
        ),
        const SizedBox(width: ThemeSizes.md),
        Text(
          '$label: ',
          style: context.textTheme.bodyMedium,
        ),
        Expanded(
          child: Text(
            value,
            style: context.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
