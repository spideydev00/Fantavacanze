import 'dart:async';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/utils/show_page_specific_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/games/domain/entities/word_bomb_game_state.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/word_bomb/word_bomb_bloc.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/word_bomb/word_bomb_strategic_action_type.dart'; // Added
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/lobby/lobby_bloc.dart';
import 'package:fantavacanze_official/core/widgets/buttons/danger_action_button.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/widgets/info_container.dart';

class WordBombPage extends StatefulWidget {
  const WordBombPage({super.key});

  @override
  State<WordBombPage> createState() => _WordBombPageState();
}

class _WordBombPageState extends State<WordBombPage> {
  final _wordController = TextEditingController();
  Timer? _uiRefreshTimer;
  int _displayRemainingTimeMs = 0;
  bool _isConfirmationDialogVisible = false;

  @override
  void initState() {
    super.initState();
    _startUiRefreshTimer();
    // _preloadSound(); // For sound
  }

  // Future<void> _preloadSound() async { // For sound
  //   await _audioPlayer.setSource(AssetSource('audio/tick.mp3'));
  // }

  // void _playTickSound() { // For sound
  //   _audioPlayer.resume(); // Or play() depending on version and if already played
  // }

  void _startUiRefreshTimer() {
    _uiRefreshTimer?.cancel();
    _uiRefreshTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final blocState = context.read<WordBombBloc>().state;
      if (blocState is WordBombGameActive && !blocState.gameState.isPaused) {
        final newTime = blocState.gameState.calculatedRemainingTimeMs;
        if (_displayRemainingTimeMs > 0 && newTime < _displayRemainingTimeMs) {
          // _playTickSound(); // Play sound on time decrease
        }
        setState(() {
          _displayRemainingTimeMs = newTime;
        });
      } else if (blocState is WordBombSessionState &&
          (blocState.gameState.isPaused ||
              blocState.gameState.playerWhoExplodedId != null)) {
        setState(() {
          _displayRemainingTimeMs =
              blocState.gameState.calculatedRemainingTimeMs;
        });
      }
    });
  }

  @override
  void dispose() {
    _wordController.dispose();
    _uiRefreshTimer?.cancel();
    // _audioPlayer.dispose(); // For sound
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appUserState = context.watch<AppUserCubit>().state;
    String? myId;
    if (appUserState is AppUserIsLoggedIn) {
      myId = appUserState.user.id;
    }

    return Scaffold(
      appBar: AppBar(
        // Reinstated AppBar
        title: Text(
          'Word Bomb',
          style: context.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        // SafeArea can remain
        child: BlocConsumer<WordBombBloc, WordBombState>(
          // Directly use BlocConsumer
          listenWhen: (previous, current) {
            if (current is WordBombError) return true;
            if (current is WordBombGameActive && current.errorMessage != null) {
              return true;
            }

            if (current is WordBombAwaitingConfirmation) {
              // Only proceed if the current confirmation state has a valid pauseTimeEpochMs.
              if (current.gameState.pauseTimeEpochMs == null) {
                return false;
              }
              if (previous is WordBombAwaitingConfirmation) {
                // If it's the same logical confirmation (same action, same non-null pause time),
                // don't re-trigger.
                if (previous.gameState.pauseTimeEpochMs != null &&
                    previous.actionBeingConfirmed ==
                        current.actionBeingConfirmed &&
                    previous.gameState.pauseTimeEpochMs ==
                        current.gameState.pauseTimeEpochMs) {
                  return false;
                }
              }
              // If previous was not WBA, or if it's a WBA for a different action/pause,
              // or if previous WBA had a null pauseTime (which shouldn't happen for a valid one),
              // then allow listener to trigger.
              return true;
            }
            return false;
          },
          listener: (context, state) {
            if (state is WordBombError) {
              // Ensure no dialog is trying to be shown if an error occurs
              if (_isConfirmationDialogVisible && Navigator.canPop(context)) {
                // Potentially pop if a confirmation dialog was up and an error state superseded it.
                // However, this might be too aggressive. For now, rely on flag.
              }
              _isConfirmationDialogVisible = false; // Reset flag on error
              showSpecificSnackBar(
                context,
                state.message,
              );
            } else if (state is WordBombGameActive &&
                state.errorMessage != null) {
              showSpecificSnackBar(context, state.errorMessage!);
              context
                  .read<WordBombBloc>()
                  .add(const ClearWordBombErrorMessage());
            } else if (state is WordBombAwaitingConfirmation) {
              // If listenWhen allowed this, it means we should show the dialog,
              // guarded by the _isConfirmationDialogVisible flag.
              _showActionConfirmationDialog(context, state);
            }
          },
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _buildContentBasedOnState(context, state, myId),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContentBasedOnState(
      BuildContext context, WordBombState state, String? myId) {
    if (state is WordBombLoading || state is WordBombInitial) {
      return Loader(
        key: const ValueKey('loader'),
        color: ColorPalette.error,
      );
    }

    if (state is WordBombSessionState) {
      // If awaiting confirmation, the game interface might be overlaid by the dialog.
      // The underlying view will show the game as paused.
      return _buildGameInterface(context, state, myId);
    }
    return const Center(
        key: ValueKey('error_text'), // Added key for AnimatedSwitcher
        child: Text('Errore caricamento Word Bomb.'));
  }

  Widget _buildGameInterface(
    BuildContext context,
    WordBombSessionState state,
    String? myId,
  ) {
    final gameSession = state.session;
    final gameState = state.gameState;
    final players = state.players;
    final isAdmin = state.isAdmin;
    final isMyTurn = myId == gameSession.currentTurnUserId;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _buildInnerGameContent(context, state, myId, gameSession,
          gameState, players, isAdmin, isMyTurn),
    );
  }

  // Helper method to build the content for AnimatedSwitcher in _buildGameInterface
  Widget _buildInnerGameContent(
    BuildContext context,
    WordBombSessionState state,
    String? myId,
    /*GameSession*/ dynamic gameSession,
    WordBombGameState gameState,
    List<GamePlayer> players,
    bool isAdmin,
    bool isMyTurn,
  ) {
    if (state is WordBombPlayerExploded) {
      return _buildPlayerExplodedView(context, state, myId);
    }

    if (state.gameState.isPaused && state is! WordBombAwaitingConfirmation) {
      return _buildPausedView(context, state, myId);
    }

    return Padding(
      key: const ValueKey('active_game_content_padding'),
      padding: const EdgeInsets.all(ThemeSizes.md),
      child: ListView(
        // Replaced Column with ListView
        // physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()), // ListView has its own physics
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child:
                _buildTurnIndicator(context, state.currentPlayerName ?? 'N/A'),
          ),
          const SizedBox(height: ThemeSizes.md),
          _buildTimerAndInfoSection(context, gameState),
          const SizedBox(height: ThemeSizes.lg),
          _buildStrategicActions(context, state, isMyTurn, myId),
          const SizedBox(height: ThemeSizes.md),
          _buildWordInputSection(context, gameState, isMyTurn),
          const SizedBox(height: ThemeSizes.md),
          _buildPlayerListAndAdminControls(
              context, players, isAdmin, gameState, gameSession.id),
        ],
      ),
    );
  }

  Widget _buildTurnIndicator(BuildContext context, String currentPlayerName) {
    return InfoContainer(
      // Key added for AnimatedSwitcher to correctly identify changes
      key: ValueKey<String>(currentPlayerName),
      title: "Turno di: $currentPlayerName",
      message:
          "Scrivi una parola che inizi con la lettera data e appartenga alla categoria!",
      icon: Icons.person_pin_rounded,
      color: ColorPalette.info,
    );
  }

  Widget _buildTimerAndInfoSection(
    BuildContext context,
    WordBombGameState gameState,
  ) {
    final timeToShow = gameState.isGhostTimerCurrentlyHidden
        ? gameState.currentTurnTotalDurationMs
        : _displayRemainingTimeMs;
    final progressValue = gameState.currentTurnTotalDurationMs > 0
        ? timeToShow / gameState.currentTurnTotalDurationMs
        : 0.0;

    final themeState = context.read<AppThemeCubit>().state;
    final backgroundColor = themeState.themeMode == ThemeMode.dark
        ? ColorPalette.info.withValues(alpha: 0.07)
        : ColorPalette.info.withValues(alpha: 0.5);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer and Bomb
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: CircularProgressIndicator(
                          value: progressValue,
                          strokeWidth: 8,
                          backgroundColor:
                              ColorPalette.success.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ColorPalette.success,
                          ),
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/images/icons/games_icons/bomb-icon.svg',
                        height: 70,
                      ),
                      if (!gameState.isGhostTimerCurrentlyHidden) // Changed
                        Text(
                          '${(timeToShow / 1000).toStringAsFixed(1)}s',
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: const Offset(1, 1),
                                blurRadius: 7,
                              ),
                            ],
                          ),
                        )
                      else
                        Icon(
                          // This is the icon shown when timer is hidden by ghost protocol
                          Icons.visibility_off_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                    ],
                  ),
                  const SizedBox(height: ThemeSizes.md),
                  // Category Label (like PlanLabel)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Container(
                      key: ValueKey<String>(
                        gameState.currentCategory,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeSizes.sm,
                        vertical: ThemeSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: ColorPalette.success.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(ThemeSizes.borderRadiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 16,
                            color: ColorPalette.success,
                          ),
                          const SizedBox(width: ThemeSizes.xs),
                          Expanded(
                            child: Text(
                              gameState.currentCategory,
                              maxLines: 3,
                              textAlign: TextAlign.center,
                              style: context.textTheme.labelMedium?.copyWith(
                                color: ColorPalette.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: ThemeSizes.md),
            // Used Words
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Parole Usate:",
                    style: context.textTheme.titleSmall,
                  ),
                  const SizedBox(height: ThemeSizes.xs),
                  Container(
                    height: 143,
                    decoration: BoxDecoration(
                      color: context.secondaryBgColor,
                      borderRadius: BorderRadius.circular(
                        ThemeSizes.borderRadiusMd,
                      ),
                    ),
                    child: gameState.usedWords.isEmpty
                        ? Center(
                            child: Text(
                              "Nessuna parola ancora...",
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.textSecondaryColor,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: gameState.usedWords.length,
                            itemBuilder: (context, index) {
                              final word = gameState.usedWords[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: ThemeSizes.sm,
                                    vertical: ThemeSizes.xs / 2),
                                child: Text(
                                  '• $word',
                                  style: context.textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: ThemeSizes.md),
        // Initial Letter Card
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Card(
            key: ValueKey<String>(gameState.currentLetterSyllable),
            elevation: 2,
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
              side: BorderSide(
                color: ColorPalette.info.withValues(alpha: 0.3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: ThemeSizes.sm,
                horizontal: ThemeSizes.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lettera Iniziale: ',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    gameState.currentLetterSyllable.toUpperCase(),
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: themeState.themeMode == ThemeMode.dark
                          ? ColorPalette.info
                          : ColorPalette.infoDarker,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWordInputSection(
      BuildContext context, WordBombGameState gameState, bool isMyTurn) {
    OutlineInputBorder border() {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
      );
    }

    return Column(
      children: [
        TextField(
          controller: _wordController,
          enabled: isMyTurn && !gameState.isPaused,
          cursorColor: ColorPalette.info,
          decoration: InputDecoration(
            focusedErrorBorder: border(),
            disabledBorder: border(),
            errorBorder: border(),
            enabledBorder: border(),
            focusedBorder: border(),
            border: border(),
            hintText: isMyTurn
                ? 'Scrivi la tua parola...'
                : "Attendi il tuo turno...",
          ),
          onSubmitted: isMyTurn && !gameState.isPaused
              ? (_) {
                  if (_wordController.text.isNotEmpty) {
                    context
                        .read<WordBombBloc>()
                        .add(SubmitWord(_wordController.text));
                    _wordController.clear();
                  }
                }
              : null,
        ),
        const SizedBox(height: ThemeSizes.md),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: isMyTurn
              ? ElevatedButton.icon(
                  key: const ValueKey('send_button_active'),
                  icon: const Icon(Icons.send),
                  label: const Text('Invia Parola'),
                  onPressed: !gameState.isPaused
                      ? () {
                          if (_wordController.text.isNotEmpty) {
                            context
                                .read<WordBombBloc>()
                                .add(SubmitWord(_wordController.text));
                            _wordController.clear();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.success,
                    minimumSize: const Size(double.infinity, 50),
                    textStyle: context.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                )
              : Container(
                  key: const ValueKey('send_button_inactive'),
                  height: 50,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  alignment: Alignment.center,
                  child: Text(
                    'Non è il tuo turno',
                    style: context.textTheme.titleMedium
                        ?.copyWith(color: context.textSecondaryColor),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildStrategicActionChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String tooltip,
    required VoidCallback? onPressed,
    required Color primaryColor,
    required Color secondaryColor,
    String? usesLeftText,
  }) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: onPressed == null ? 0.5 : 1.0,
          child: Container(
            height: 78,
            width: 78,
            padding: const EdgeInsets.all(ThemeSizes.sm),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                if (usesLeftText != null)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(
                          ThemeSizes.borderRadiusLg,
                        ),
                      ),
                      child: Text(
                        usesLeftText,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // New method for disabled action chips
  Widget _buildCompletedActionChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String tooltip,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: AnimatedOpacity(
        // Added AnimatedOpacity for consistency
        duration: const Duration(milliseconds: 200),
        opacity: 0.7,
        child: Container(
          height: 78,
          width: 78,
          padding: const EdgeInsets.all(ThemeSizes.sm),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                primaryColor.withValues(alpha: 0.3),
                secondaryColor.withValues(alpha: 0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: Colors.white.withValues(alpha: 0.3), size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStrategicActions(
    BuildContext context,
    WordBombSessionState blocState,
    bool isMyTurn,
    String? myId,
  ) {
    // Allow showing actions even if in WordBombAwaitingConfirmation, but they'd be disabled by onPressed logic.
    // Or, hide them if blocState is WordBombAwaitingConfirmation. For now, let's allow, onPressed handles it.
    if (blocState is! WordBombGameActive &&
        blocState is! WordBombAwaitingConfirmation) {
      return const SizedBox.shrink();
    }

    final gameState = blocState.gameState;
    GamePlayer? gamePlayer;
    if (myId != null && blocState.players.any((p) => p.userId == myId)) {
      gamePlayer = blocState.players.firstWhere((p) => p.userId == myId);
    }

    final bool canChangeCategory =
        gamePlayer != null && gamePlayer.changeCategoryUsesLeft > 0;
    final bool changeCategoryAvailable = isMyTurn &&
        !gameState.isPaused &&
        blocState is! WordBombAwaitingConfirmation;
    final bool canBuyTime = gameState.buyTimeUsesLeftForRound > 0;
    final bool buyTimeAvailable = isMyTurn &&
        !gameState.isPaused &&
        blocState is! WordBombAwaitingConfirmation;

    final bool isGhost = myId != null && myId == gameState.ghostPlayerId;
    final bool ghostProtocolUsed = gamePlayer?.hasUsedGhostProtocol ??
        true; // Assume used if no player data
    final bool ghostProtocolAvailable = isGhost &&
        !ghostProtocolUsed &&
        !gameState.isPaused &&
        blocState is! WordBombAwaitingConfirmation;

    List<Widget> actionChips = [];

    // Add Change Category chip
    if (gamePlayer != null) {
      // Show chip if player data exists
      if (canChangeCategory) {
        actionChips.add(
          _buildStrategicActionChip(
            context: context,
            icon: Icons.shuffle_rounded,
            label: "Cambia Categoria",
            tooltip: changeCategoryAvailable
                ? "Cambia la categoria e la lettera iniziale. Costa un utilizzo. (${gamePlayer.changeCategoryUsesLeft} rimasti)"
                : (gameState.isPaused
                    ? "Gioco in pausa o azione in attesa"
                    : (isMyTurn ? "Usi esauriti" : "Non è il tuo turno")),
            onPressed: changeCategoryAvailable
                ? () => context
                    .read<WordBombBloc>()
                    .add(const RequestStrategicAction(
                      WordBombStrategicActionType.changeCategory,
                    ))
                : null,
            primaryColor: Colors.orange.shade600,
            secondaryColor: Colors.deepOrange.shade400,
            usesLeftText: "${gamePlayer.changeCategoryUsesLeft}",
          ),
        );
      } else {
        actionChips.add(
          _buildCompletedActionChip(
            context: context,
            icon: Icons.shuffle_rounded,
            label: "Cambia Categoria",
            tooltip: "Hai esaurito i cambi categoria disponibili.",
            primaryColor: Colors.orange.shade600,
            secondaryColor: Colors.deepOrange.shade400,
          ),
        );
      }
    }

    // Add Buy Time chip
    if (canBuyTime) {
      actionChips.add(
        _buildStrategicActionChip(
          context: context,
          icon: Icons.add_alarm_rounded,
          label: "Compra Tempo",
          tooltip: buyTimeAvailable
              ? "Aggiunge 10 secondi al timer. (${gameState.buyTimeUsesLeftForRound} rimasti per il round)"
              : (gameState.isPaused
                  ? "Gioco in pausa o azione in attesa"
                  : (isMyTurn ? "Usi esauriti" : "Non è il tuo turno")),
          onPressed: buyTimeAvailable
              ? () => context.read<WordBombBloc>().add(
                  const RequestStrategicAction(
                      WordBombStrategicActionType.buyTime))
              : null,
          primaryColor: Colors.blue.shade600,
          secondaryColor: Colors.lightBlue.shade400,
          usesLeftText: "${gameState.buyTimeUsesLeftForRound}",
        ),
      );
    } else {
      actionChips.add(
        _buildCompletedActionChip(
          context: context,
          icon: Icons.add_alarm_rounded,
          label: "Compra Tempo",
          tooltip:
              "Hai esaurito gli acquisti di tempo disponibili per questo round.",
          primaryColor: Colors.blue.shade600,
          secondaryColor: Colors.lightBlue.shade400,
        ),
      );
    }

    // Add Ghost Protocol chip
    if (isGhost) {
      // Only show to the ghost player
      if (!ghostProtocolUsed) {
        actionChips.add(
          _buildStrategicActionChip(
            context: context,
            icon: Icons.visibility_off_outlined,
            label: "Protocollo Fantasma",
            tooltip: ghostProtocolAvailable
                ? "Attiva il Protocollo Fantasma: il timer non sarà visibile agli altri giocatori per questo turno."
                : (gameState.isPaused
                    ? "Gioco in pausa o azione in attesa"
                    : (isGhost
                        ? (ghostProtocolUsed
                            ? "Già usato in questo round"
                            : "Azione non disponibile")
                        : "Non sei il fantasma")), // Updated tooltip logic
            onPressed: ghostProtocolAvailable
                ? () => context
                    .read<WordBombBloc>()
                    .add(const ActivateGhostProtocolRequested())
                : null,
            primaryColor: Colors.deepPurple.shade600,
            secondaryColor: Colors.purple.shade400,
            usesLeftText:
                "1", // Ghost protocol is typically a one-time use per round/game
          ),
        );
      } else {
        actionChips.add(
          _buildCompletedActionChip(
            context: context,
            icon: Icons.visibility_off_outlined,
            label: "Protocollo Fantasma",
            tooltip: "Hai già usato il Protocollo Fantasma in questo round.",
            primaryColor: Colors.deepPurple.shade600,
            secondaryColor: Colors.purple.shade400,
          ),
        );
      }
    }

    if (actionChips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ThemeSizes.sm),
      child: Wrap(
        spacing: ThemeSizes.md,
        runSpacing: ThemeSizes.sm,
        alignment: WrapAlignment.center,
        children: actionChips,
      ),
    );
  }

  Widget _buildPlayerListAndAdminControls(
      BuildContext context,
      List<GamePlayer> players,
      bool isAdmin,
      WordBombGameState gameState,
      String sessionId) {
    return ListView(
      // This ListView is now a child of another ListView
      shrinkWrap: true, // Keep shrinkWrap if nested and not primary scroll
      physics: const NeverScrollableScrollPhysics(), // Keep physics if nested
      children: [
        if (isAdmin) ...[
          // Pause button for everyone
          OutlinedButton.icon(
            icon: Icon(gameState.isPaused ? Icons.play_arrow : Icons.pause),
            label: Text(
              gameState.isPaused ? 'Riprendi Gioco' : 'Metti in Pausa',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: ColorPalette.info,
              side: BorderSide(color: ColorPalette.info, width: 1),
            ),
            onPressed: () {
              final bloc = context.read<WordBombBloc>();
              if (gameState.isPaused) {
                bloc.add(const ResumeGameTriggered());
              } else {
                bloc.add(const PauseGameTriggered());
              }
            },
          ),
          // Terminate Session Button for Admin
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeSizes.md,
            ), // Added padding
            child: DangerActionButton(
              title: 'Termina Partita',
              description:
                  'Questa azione terminerà la partita per tutti i giocatori.',
              icon: Icons.power_settings_new_rounded,
              onTap: () => _showTerminateDialog(context, sessionId),
            ),
          ),
        ],
        // Ghost Player Display
        if (gameState.ghostPlayerId != null) ...[
          Builder(builder: (context) {
            final ghostPlayer = players.firstWhere(
              (p) => p.userId == gameState.ghostPlayerId,
            );
            return InfoContainer(
              // Using InfoContainer for better display
              title: '${ghostPlayer.userName} è il Fantasma!',
              message:
                  'Il fantasma può usare il "Protocollo Fantasma" una volta per round per nascondere il timer.',
              icon: Icons.visibility_rounded,
              color: Colors.purple.shade300,
            );
          }),
        ],
      ],
    );
  }

  Widget _buildPausedView(
    BuildContext context,
    WordBombSessionState state,
    String? myId,
  ) {
    final currentPlayerName = state.currentPlayerName;
    final bool canResume =
        state.isAdmin || myId == state.session.currentTurnUserId;

    return Center(
      key: const ValueKey('paused_view'), // Key for AnimatedSwitcher
      child: Card(
        color: context.secondaryBgColor,
        margin: const EdgeInsets.all(
          ThemeSizes.lg,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            ThemeSizes.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pause_circle_filled_rounded,
                size: 60,
                color: ColorPalette.info,
              ),
              const SizedBox(height: ThemeSizes.md),
              Text(
                'Gioco in Pausa',
                style: context.textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: ThemeSizes.sm),
              Text(
                'Turno di: ${currentPlayerName ?? "N/A"}. Attendi che il gioco riprenda.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ThemeSizes.lg),
              ElevatedButton(
                onPressed: canResume // Use the flag here
                    ? () => context.read<WordBombBloc>().add(
                          const ResumeGameTriggered(),
                        )
                    : null, // Disable button if canResume is false
                style: ElevatedButton.styleFrom(
                  backgroundColor: canResume ? ColorPalette.info : Colors.grey,
                ),
                child: Text(
                  "Riprendi Gioco",
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerExplodedView(
    BuildContext context,
    WordBombPlayerExploded state,
    String? myId,
  ) {
    if (state.players.isEmpty) {
      // This case should ideally not happen if an explosion means there were players.
      return Center(
        key:
            const ValueKey('player_exploded_error'), // Key for AnimatedSwitcher
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Errore: la lista dei giocatori è vuota ma un giocatore è esploso. Contatta l'assistenza.",
            style: TextStyle(
              color: ColorPalette.error,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    GamePlayer explodedPlayer;
    try {
      explodedPlayer = state.players.firstWhere(
        (p) => p.userId == state.explodedPlayerId,
      );
    } catch (e) {
      // Fallback if player not found, though this shouldn't happen
      explodedPlayer = GamePlayer(
          id: '',
          sessionId: '',
          userId: state.explodedPlayerId,
          userName: 'Giocatore Esploso Sconosciuto',
          joinedAt: DateTime.now());
    }

    final bool iAmTheLoser = myId == state.explodedPlayerId;

    return Center(
      key: ValueKey(
          'player_exploded_${state.explodedPlayerId}'), // Key for AnimatedSwitcher
      child: Card(
        margin: const EdgeInsets.all(ThemeSizes.lg),
        color: context.secondaryBgColor,
        child: Padding(
          padding: const EdgeInsets.all(ThemeSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/images/icons/games_icons/bomb-icon.svg',
                height: 120,
              ),
              const SizedBox(height: ThemeSizes.md),
              Text(
                iAmTheLoser
                    ? 'BOOM! Sei Esploso!'
                    : '${explodedPlayer.userName} è Esploso!',
                style: context.textTheme.headlineSmall?.copyWith(
                  color: ColorPalette.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ThemeSizes.sm),
              Text(
                iAmTheLoser
                    ? "Peccato! Sarai il prossimo a iniziare il round."
                    : "Attendi l'inizio del prossimo round.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ThemeSizes.lg),
              state.isAdmin
                  ? ElevatedButton(
                      onPressed: () {
                        context
                            .read<WordBombBloc>()
                            .add(const PlayerAcceptedDefeat());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Prossimo round!'),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for Terminate Dialog
  void _showTerminateDialog(BuildContext context, String sessionId) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog(
        title: 'Termina Partita',
        message:
            'Sei sicuro di voler terminare la partita? Questa azione è irreversibile e chiuderà la sessione per tutti i partecipanti.',
        confirmText: 'Termina',
        cancelText: 'Annulla',
        icon: Icons.power_settings_new_rounded,
        iconColor: ColorPalette.error,
        onConfirm: () {
          BlocProvider.of<LobbyBloc>(context).add(
            KillSessionRequested(sessionId),
          );
        },
        elevatedButtonStyle: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.error,
          foregroundColor: Colors.white,
        ),
        outlinedButtonStyle: OutlinedButton.styleFrom(
          foregroundColor: context.textSecondaryColor,
          side: BorderSide(
            color: context.textSecondaryColor.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Future<void> _showActionConfirmationDialog(
      BuildContext pageContext, WordBombAwaitingConfirmation state) async {
    if (_isConfirmationDialogVisible) return; // Guard against re-entry

    _isConfirmationDialogVisible = true;

    String title;
    String message;
    final actionType = state.actionBeingConfirmed;

    if (actionType == WordBombStrategicActionType.buyTime) {
      title = "Conferma Acquisto Tempo";
      message = "Aggiungere 10 secondi al timer ti costerà 1 shot. Continuare?";
    } else if (actionType == WordBombStrategicActionType.changeCategory) {
      title = "Cambio Categoria";
      message = "Cambiare categoria ti costerà 1 shot. Continuare?";
    } else {
      _isConfirmationDialogVisible = false; // Reset flag if action is unknown
      return; // Should not happen
    }

    await showGeneralDialog<void>(
      context: pageContext,
      barrierDismissible: false,
      barrierLabel:
          MaterialLocalizations.of(pageContext).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration:
          const Duration(milliseconds: 300), // Animation duration
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        // This is the widget that will be displayed.
        return ConfirmationDialog(
          backgroundColor: buildContext.bgColor,
          elevatedButtonStyle: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(
              actionType == WordBombStrategicActionType.buyTime
                  ? Colors.blue.shade600
                  : Colors.orange.shade600,
            ),
          ),
          outlinedButtonStyle: ButtonStyle(
            foregroundColor: WidgetStatePropertyAll<Color>(
              actionType == WordBombStrategicActionType.buyTime
                  ? Colors.blue.shade600
                  : Colors.orange.shade600,
            ),
            side: WidgetStatePropertyAll<BorderSide>(
              BorderSide(
                color: actionType == WordBombStrategicActionType.buyTime
                    ? Colors.blue.shade600
                    : Colors.orange.shade600,
                width: 1.5,
              ),
            ),
          ),
          title: title,
          message: message,
          confirmText: 'Cavallo',
          cancelText: 'Naahh',
          icon: actionType == WordBombStrategicActionType.buyTime
              ? Icons.add_alarm_rounded
              : Icons.shuffle_rounded,
          iconColor: actionType == WordBombStrategicActionType.buyTime
              ? Colors.blue.shade600
              : Colors.orange.shade600,
          onConfirm: () {
            // ConfirmationDialog pops itself via Navigator.pop(context)
            // Ensure the BLoC event is dispatched using pageContext
            BlocProvider.of<WordBombBloc>(pageContext)
                .add(const ConfirmStrategicAction());
          },
          onCancel: () {
            // ConfirmationDialog pops itself
            BlocProvider.of<WordBombBloc>(pageContext)
                .add(const CancelStrategicAction());
          },
        );
      },
      transitionBuilder: (BuildContext buildContext,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child) {
        // Custom transition (e.g., FadeTransition)
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic, // Smoother curve
            reverseCurve: Curves.easeInCubic,
          ),
          child: ScaleTransition(
            // Optional: Add a slight scale effect
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack, // Gives a slight overshoot
              reverseCurve: Curves.easeInBack,
            ),
            child: child,
          ),
        );
      },
    ).whenComplete(() {
      _isConfirmationDialogVisible = false;
    });
  }
}
