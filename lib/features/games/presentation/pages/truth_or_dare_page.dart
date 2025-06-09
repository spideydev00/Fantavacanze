import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_page_specific_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/buttons/danger_action_button.dart';
import 'package:fantavacanze_official/core/widgets/buttons/gradient_option_button.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/core/widgets/info_container.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';
import 'package:fantavacanze_official/features/games/domain/entities/truth_or_dare_question.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/lobby/lobby_bloc.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/truth_or_dare/truth_or_dare_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';

class TruthOrDarePage extends StatefulWidget {
  const TruthOrDarePage({super.key});

  @override
  State<TruthOrDarePage> createState() => _TruthOrDarePageState();
}

class _TruthOrDarePageState extends State<TruthOrDarePage> {
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  GamePlayer? _getCurrentPlayer(TruthOrDareGameReady state) {
    if (state.session.currentTurnUserId == null) {
      return state.players.isNotEmpty ? state.players.first : null;
    }
    try {
      return state.players.firstWhere(
        (p) => p.userId == state.session.currentTurnUserId,
      );
    } catch (e) {
      return state.players.isNotEmpty ? state.players.first : null;
    }
  }

  // This method is now only for MANUAL swipes. Buttons will use direct BLoC events.
  void _onCardManuallySwiped(
    BuildContext context,
    TruthOrDareGameReady state,
    int? index,
    CardSwiperDirection direction,
    String userId,
  ) {
    // For simplicity, ONLY admin controls the next player turn on manual swipe.
    // Or, if it's the current player, their manual swipe is like submitting outcome.
    final bool isSuccess = direction == CardSwiperDirection.left;
    context
        .read<TruthOrDareBloc>()
        .add(PlayerTaskOutcomeSubmitted(isSuccess: isSuccess));
  }

  @override
  Widget build(BuildContext context) {
    final appUserState = context.read<AppUserCubit>().state;

    final String userId = (appUserState as AppUserIsLoggedIn).user.id;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Obbligo o Verità',
          style: context.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocConsumer<TruthOrDareBloc, TruthOrDareState>(
        listener: (context, state) {
          if (state is TruthOrDareError) {
            showSpecificSnackBar(
              context,
              state.message,
            );
          }
        },
        builder: (context, state) {
          if (state is TruthOrDareLoading || state is TruthOrDareInitial) {
            return Center(child: Loader(color: context.primaryColor));
          }

          if (state is TruthOrDareGameReady) {
            final currentPlayer = _getCurrentPlayer(state);
            final bool isMyTurn = currentPlayer?.userId == userId;

            return Padding(
              padding: const EdgeInsets.all(ThemeSizes.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Player turn indicator is now shown conditionally inside _buildGameContent
                  Expanded(
                    child: _buildGameContent(
                      context,
                      state,
                      isMyTurn,
                      currentPlayer,
                      // userId, // No longer directly needed by _buildGameContent itself
                      currentPlayer?.userName ?? "Giocatore Sconosciuto",
                    ),
                  ),
                  // Admin-specific controls like "Terminate Game" can be placed outside _buildGameContent
                  // if they should always be visible to admin regardless of whose turn it is.
                  // For now, the "Terminate Game" button is inside _buildChoiceButtons,
                  // which will only be shown if currentQuestion is null.
                  // If admin needs to terminate anytime, this button needs to be moved.
                  // Let's keep it as is for now, meaning admin can only terminate when it's choice time.
                  // OR, we can add a global admin action bar if needed.
                  // For simplicity, let's adjust _buildChoiceButtons to show Terminate for admin
                  // even if it's not their turn, but only when currentQuestion is null.
                ],
              ),
            );
          }
          return Center(
            child: Text(
              'Errore imprevisto o stato non gestito: $state. Riprova.',
              style: context.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerTurnIndicator(
    BuildContext context,
    GamePlayer? currentPlayer,
    // bool isAdmin, // Not directly needed for the text
    // List<GamePlayer> players, // Not directly needed for the text
    // String adminId, // Not directly needed for the text
    // String userId, // Not directly needed for the text
    bool isMyTurn, // New parameter to customize message
  ) {
    return InfoContainer(
      title: "Turno di ${currentPlayer?.userName ?? 'Giocatore'}",
      message: isMyTurn
          ? "Completa l'obbligo o rispondi alla verità proposta."
          : "Attendi che ${currentPlayer?.userName ?? 'il giocatore'} completi la sua azione.",
      icon: Icons.emoji_people_rounded,
      color: ColorPalette.info,
    );
  }

  Widget _buildGameContent(
      BuildContext context,
      TruthOrDareGameReady state,
      bool isMyTurn,
      GamePlayer? currentPlayer,
      // String userId, // No longer directly needed
      String currentUserName) {
    if (state.currentQuestion == null) {
      // Stage 1: No question selected yet
      if (isMyTurn) {
        return _buildChoiceButtons(
            context, currentUserName, state.isAdmin, state.session.id);
      } else {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Loader(color: context.primaryColor.withValues(alpha: 0.5)),
              const SizedBox(height: ThemeSizes.lg),
              Text(
                'In attesa che $currentUserName scelga...',
                style: context.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (state.isAdmin) ...[
                // Admin can still terminate game from here
                const SizedBox(height: ThemeSizes.xxl),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
                  child: DangerActionButton(
                    title: 'Termina Partita',
                    description:
                        'Questa azione terminerà la partita per tutti i giocatori.',
                    icon: Icons.power_settings_new_rounded,
                    onTap: () =>
                        _showTerminateDialog(context, state.session.id),
                  ),
                ),
              ]
            ],
          ),
        );
      }
    } else {
      // Stage 2: Question has been selected
      if (isMyTurn) {
        return Column(
          children: [
            _buildPlayerTurnIndicator(
              context,
              currentPlayer,
              isMyTurn,
            ),
            Expanded(
              child: _buildCardSwiper(
                context,
                state, // Pass the whole state
                state.currentQuestion!,
                // userId, // Not needed directly, isMyTurn is derived from state and userId already
              ),
            ),
          ],
        );
      } else {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Loader(color: context.primaryColor.withValues(alpha: 0.5)),
              const SizedBox(height: ThemeSizes.lg),
              Text(
                '$currentUserName sta affrontando la sfida...',
                style: context.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (state.isAdmin) ...[
                // Admin can still terminate game from here
                const SizedBox(height: ThemeSizes.xxl),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
                  child: DangerActionButton(
                    title: 'Termina Partita',
                    description:
                        'Questa azione terminerà la partita per tutti i giocatori.',
                    icon: Icons.power_settings_new_rounded,
                    onTap: () =>
                        _showTerminateDialog(context, state.session.id),
                  ),
                ),
              ]
            ],
          ),
        );
      }
    }
  }

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
          context.read<LobbyBloc>().add(KillSessionRequested(sessionId));
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

  Widget _buildChoiceButtons(BuildContext context, String currentUserName,
      bool isAdmin, String sessionId) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
              horizontal: ThemeSizes.lg, vertical: ThemeSizes.md),
          padding: const EdgeInsets.symmetric(
              vertical: ThemeSizes.md, horizontal: ThemeSizes.lg),
          decoration: BoxDecoration(
            color: ColorPalette.info.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            border: Border.all(
              color: ColorPalette.info.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_pin_rounded,
                color: ColorPalette.info,
                size: 28,
              ),
              const SizedBox(width: ThemeSizes.sm),
              Flexible(
                child: Text(
                  currentUserName,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.info,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: ThemeSizes.sm),
        Text(
          // currentUserName, // Already displayed above
          "È il tuo turno!",
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: ColorPalette.info,
          ),
        ),
        const SizedBox(height: ThemeSizes.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: GradientOptionButton(
                isSelected: true,
                label: 'Verità',
                icon: Icons.help_outline_rounded,
                primaryColor: ColorPalette.truthPrimary,
                secondaryColor: ColorPalette.truthSecondary,
                onTap: () {
                  context
                      .read<TruthOrDareBloc>()
                      .add(const CardTypeChosen(TruthOrDareCardType.truth));
                },
              ),
            ),
            SizedBox(width: ThemeSizes.md),
            Expanded(
              child: GradientOptionButton(
                isSelected: true,
                label: 'Obbligo',
                icon: Icons.gavel_rounded,
                primaryColor: ColorPalette.darePrimary,
                secondaryColor: ColorPalette.dareSecondary,
                onTap: () {
                  context
                      .read<TruthOrDareBloc>()
                      .add(const CardTypeChosen(TruthOrDareCardType.dare));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: ThemeSizes.xxl),
        if (isAdmin) // Only admin sees terminate button here
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
            child: DangerActionButton(
              title: 'Termina Partita',
              description:
                  'Questa azione terminerà la partita per tutti i giocatori.',
              icon: Icons.power_settings_new_rounded,
              onTap: () => _showTerminateDialog(context, sessionId),
            ),
          )
        // Removed the generic InfoBanner for non-admins/non-turn players from here
        // as it's handled by _buildGameContent now.
      ],
    );
  }

  Widget _buildCardSwiper(
    BuildContext context,
    TruthOrDareGameReady state, // Pass the whole state
    TruthOrDareQuestion question,
    // String userId, // Not needed directly, use state.session.currentTurnUserId and AppUserCubit.userId
  ) {
    final appUser =
        (context.read<AppUserCubit>().state as AppUserIsLoggedIn).user;
    final isMyTurn = state.session.currentTurnUserId == appUser.id;

    final cardColor = question.type == TruthOrDareCardType.truth
        ? ColorPalette.truthPrimary
        : ColorPalette.darePrimary;

    final cardIcon = question.type == TruthOrDareCardType.truth
        ? Icons.help_outline_rounded
        : Icons.gavel_rounded;

    // Interaction is now strictly for the current player
    final bool canInteract = isMyTurn;
    final bool canChangeQuestion = state.canChangeCurrentQuestion && isMyTurn;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: CardSwiper(
            controller: _swiperController,
            cardsCount: 1,
            numberOfCardsDisplayed: 1,
            // Swipe interaction is only for the current player
            isLoop: false, // Prevent accidental multiple swipes
            allowedSwipeDirection: canInteract
                ? AllowedSwipeDirection.symmetric(horizontal: true)
                : AllowedSwipeDirection
                    .none(), // Disable swipe if not interactable
            onSwipe: (previousIndex, currentIndex, direction) {
              if (!canInteract) {
                return false;
              }
              _onCardManuallySwiped(
                context,
                state,
                previousIndex,
                direction,
                appUser.id, // Pass current user's ID
              );
              return true;
            },
            cardBuilder:
                (context, index, percentThresholdX, percentThresholdY) {
              return Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ThemeSizes.borderRadiusXlg,
                  ),
                ),
                color: cardColor.withValues(alpha: 0.95),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeSizes.lg,
                  ),
                  child: ListView(
                    children: [
                      SizedBox(height: ThemeSizes.sm),
                      Icon(
                        cardIcon,
                        size: 60,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      const SizedBox(height: ThemeSizes.lg),
                      Text(
                        question.type == TruthOrDareCardType.truth
                            ? 'VERITÀ'
                            : 'OBBLIGO',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.anton(
                          fontSize: 36,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: ThemeSizes.md),
                      Text(
                        question.content,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 20.5,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: ThemeSizes.lg),
        if (canInteract) // Buttons only visible if it's my turn
          Padding(
            padding: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Fail Button
                GestureDetector(
                  onTap: () {
                    // No need to check canInteract again, this whole block is conditional
                    context.read<TruthOrDareBloc>().add(
                        const PlayerTaskOutcomeSubmitted(isSuccess: false));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(ThemeSizes.lg),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.secondaryBgColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: ColorPalette.error.withValues(alpha: 0.8),
                      size: 36,
                    ),
                  ),
                ),
                // Success Button
                GestureDetector(
                  onTap: () {
                    // No need to check canInteract again
                    context
                        .read<TruthOrDareBloc>()
                        .add(const PlayerTaskOutcomeSubmitted(isSuccess: true));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(ThemeSizes.lg),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.secondaryBgColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: ColorPalette.success.withValues(alpha: 0.8),
                      size: 36,
                    ),
                  ),
                ),
                // Change Question Button - New Icon Button
                if (state.currentQuestion != null) // This check is good
                  GestureDetector(
                    onTap: canChangeQuestion // This uses the combined flag
                        ? () {
                            context
                                .read<TruthOrDareBloc>()
                                .add(ChangeQuestionRequested());
                          }
                        : null,
                    child: Opacity(
                      opacity: canChangeQuestion ? 1.0 : 0.5,
                      child: Container(
                        padding: const EdgeInsets.all(ThemeSizes.lg),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade700,
                              Colors.amber.shade600,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (canInteract && state.currentQuestion != null)
          const SizedBox(height: ThemeSizes.sm),
        Text(
          canInteract
              ? "Completa e swipa o tocca le icone!"
              : "", // Message only if interactable
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}
