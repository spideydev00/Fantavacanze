import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_page_specific_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/buttons/danger_action_button.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/core/widgets/info_container.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/game/game_bloc.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/never_have_i_ever/never_have_i_ever_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class NeverHaveIEverGamePage extends StatelessWidget {
  const NeverHaveIEverGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Non Ho Mai...',
          style: context.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocConsumer<NeverHaveIEverBloc, NeverHaveIEverState>(
        listener: (context, state) {
          if (state is NeverHaveIEverError) {
            showSpecificSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is NeverHaveIEverLoading ||
              state is NeverHaveIEverInitial) {
            return Center(child: Loader(color: context.primaryColor));
          }

          if (state is NeverHaveIEverError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(ThemeSizes.lg),
                child: Text(
                  'Errore: ${state.message}',
                  style: context.textTheme.bodyLarge
                      ?.copyWith(color: ColorPalette.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (state is NeverHaveIEverGameReady) {
            return _buildGameContent(context, state);
          }
          return _buildWaitingDisplay(context, "Caricamento partita...");
        },
      ),
    );
  }

  Widget _buildPlayerTurnIndicator(
    BuildContext context,
    String? currentPlayerName,
  ) {
    return InfoContainer(
      title: "E tu? l'hai mai fatto?",
      message:
          "Se la risposta è 'No', non fai nulla. Altrimenti, fai una penalità!",
      icon: Icons.record_voice_over_rounded,
      color: ColorPalette.success,
    );
  }

  Widget _buildGameContent(
    BuildContext context,
    NeverHaveIEverGameReady state,
  ) {
    return Padding(
      padding: const EdgeInsets.all(ThemeSizes.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPlayerTurnIndicator(context, state.currentPlayerName),
          const SizedBox(height: ThemeSizes.md),
          Expanded(
            child: Center(
              child: state.currentQuestion != null
                  ? _buildQuestionDisplay(
                      context, state.currentQuestion!.content)
                  : _buildWaitingDisplay(
                      context, "In attesa della prossima domanda..."),
            ),
          ),
          const SizedBox(height: ThemeSizes.md),
          if (state.isAdmin) ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.skip_next_rounded),
              label: const Text('Prossima Domanda'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                textStyle: context.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                context
                    .read<NeverHaveIEverBloc>()
                    .add(const NextQuestionRequested());
              },
            ),
            const SizedBox(height: ThemeSizes.sm),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: ThemeSizes.sm),
              child: DangerActionButton(
                title: 'Termina Partita',
                description:
                    'Questa azione terminerà la partita per tutti i giocatori.',
                icon: Icons.power_settings_new_rounded,
                onTap: () => _showTerminateDialog(context, state.session.id),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionDisplay(BuildContext context, String questionContent) {
    return Container(
      padding: const EdgeInsets.all(ThemeSizes.xl),
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusXlg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Text(
        questionContent,
        textAlign: TextAlign.center,
        style: GoogleFonts.grenze(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: context.textPrimaryColor,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildWaitingDisplay(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Loader(color: context.primaryColor.withValues(alpha: 0.7)),
          const SizedBox(height: ThemeSizes.lg),
          Text(
            message,
            style: context.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
}
