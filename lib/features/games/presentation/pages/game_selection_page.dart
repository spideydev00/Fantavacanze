import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_page_specific_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/buttons/modern_drink_card.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/premium_access_dialog.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/core/widgets/app_information_dialog.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_type_enum.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/game/game_bloc.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/word_bomb/word_bomb_bloc.dart';
import 'package:fantavacanze_official/features/games/presentation/pages/game_host_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/sections/dashboard.dart';
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
  GameType _selectedGameType = GameType.truthOrDare;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get current user to check premium status and trial availability
    final appUserState = context.watch<AppUserCubit>().state;

    bool hasWordBombTrial = false;
    bool isPremiumUser = false;

    if (appUserState is AppUserIsLoggedIn) {
      hasWordBombTrial = appUserState.user.isWordBombTrialAvailable;
      isPremiumUser = appUserState.user.isPremium;
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: context.textPrimaryColor,
          onPressed: () {
            context.read<AppNavigationCubit>().setIndex(0);

            Navigator.pushAndRemoveUntil(
              context,
              DashboardScreen.route,
              (route) => false,
            );
          },
        ),
        title: Text(
          'Drink Games',
          style: context.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocListener<LobbyBloc, LobbyState>(
        listenWhen: (previous, current) =>
            previous is! LobbySessionActive && current is LobbySessionActive,
        listener: (context, state) {
          if (state is LobbySessionActive) {
            // Navigate to GameHostPage when a session becomes active
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => GameHostPage(sessionId: state.session.id),
              ),
            );
          } else if (state is LobbyError) {
            showSpecificSnackBar(context, state.message);
          }
        },
        child: BlocBuilder<LobbyBloc, LobbyState>(
          builder: (context, state) {
            if (state is LobbyLoading) {
              return Loader(
                color: context.primaryColor,
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // First row: Two cards side by side
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ModernDrinkCard(
                            onTap: () {
                              setState(() {
                                _selectedGameType = GameType.truthOrDare;
                              });
                            },
                            isSelected:
                                _selectedGameType == GameType.truthOrDare,
                            pngIconPath:
                                'assets/images/icons/games_icons/balance.png',
                            label: "Truth or Dare",
                            description: "Un classico obbligo o verità",
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ModernDrinkCard(
                            onTap: () {
                              setState(() {
                                _selectedGameType = GameType.neverHaveIEver;
                              });
                            },
                            isSelected:
                                _selectedGameType == GameType.neverHaveIEver,
                            pngIconPath:
                                'assets/images/icons/games_icons/team-icon.png',
                            label: "Non Ho Mai",
                            description: "E tu cosa non hai mai fatto?",
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: ThemeSizes.md),
                    // Second row: Third card with Prosegui button next to it horizontally
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ModernDrinkCard(
                          onTap: () {
                            setState(() {
                              _selectedGameType = GameType.wordBomb;
                            });
                          },
                          isSelected: _selectedGameType == GameType.wordBomb,
                          svgIconPath:
                              'assets/images/icons/games_icons/bomb-icon.svg',
                          label: "Word Bomb",
                          isPremium: !isPremiumUser,
                          isTrialAvailable: hasWordBombTrial,
                          showInfoIcon: true,
                          onInfoIconTapped: () {
                            showDialog(
                              context: context,
                              builder: (context) => AppInformationDialog(
                                title: 'Word Bomb',
                                titleIcon: Icons.whatshot_rounded,
                                titleIconColor: ColorPalette.error,
                                sections: [
                                  InformationSection(
                                    icon: Icons.flag_circle_outlined,
                                    iconColor: ColorPalette.success,
                                    title: 'Obiettivo del Gioco',
                                    content:
                                        "L'obiettivo è evitare di essere l'ultimo giocatore a cui 'scoppia la bomba'. Per farlo, devi scrivere velocemente una parola che inizi con la lettera mostrata e appartenga alla categoria estratta. Il timer dura 60 secondi e l'ultimo utente a digitare perde!",
                                  ),
                                  InformationSection(
                                    icon: Icons.star_outline_rounded,
                                    iconColor: Colors.amber.shade700,
                                    title: 'Poteri Speciali',
                                    widgets: [
                                      FeatureItem(
                                        icon: Icons.add_alarm_rounded,
                                        iconColor: Colors.blue.shade600,
                                        title: "Guadagna Tempo (+10s)",
                                        description:
                                            "Aggiunge 10 secondi al tuo timer. Max. 3 utilizzi per partita. COSTO: 1.",
                                      ),
                                      FeatureItem(
                                        icon: Icons.shuffle_rounded,
                                        iconColor: Colors.orange.shade600,
                                        title: "Cambia Categoria",
                                        description:
                                            "Cambia la categoria e la lettera iniziale. Max. 2 utilizzi per giocatore. COSTO: 1.",
                                      ),
                                      FeatureItem(
                                        icon: Icons.visibility_off_outlined,
                                        iconColor: Colors.deepPurple.shade600,
                                        title: "Protocollo Fantasma",
                                        description:
                                            "Rende il timer invisibile a tutti i giocatori per 30 secondi. Attivabile una sola volta per partita da un giocatore casuale designato come 'Fantasma' all'inizio del round.",
                                      ),
                                    ],
                                  ),
                                  InformationSection(
                                    icon: Icons.pause_circle_outline_rounded,
                                    iconColor: ColorPalette.info,
                                    title: 'Pausa',
                                    content:
                                        "Quando usi un potere, il gioco andrà in pausa. Premi 'Prosegui' solo dopo aver completato l'azione per far ripartire il timer.",
                                  ),
                                  InformationSection(
                                    icon: Icons.rule_folder_outlined,
                                    iconColor: context.textSecondaryColor,
                                    title: 'Altre Info Utili',
                                    content:
                                        "Il timer è unico per tutti. La lettera iniziale e la categoria cambiano ad ogni round o con il potere 'Cambia Categoria'. Il 'Fantasma' viene designato casualmente all'inizio di ogni round.",
                                  ),
                                ],
                              ),
                            );
                          },
                          description: isPremiumUser
                              ? "Occhio a non far scoppiare la bomba!"
                              : null,
                        ),
                        const SizedBox(width: 26),
                        // Prosegui button right next to the third card
                        GestureDetector(
                          onTap: () {
                            if (_selectedGameType == GameType.wordBomb &&
                                (!isPremiumUser && hasWordBombTrial)) {
                              context
                                  .read<WordBombBloc>()
                                  .add(DeactivateTrialRequested());

                              context.read<LobbyBloc>().add(
                                    CreateSessionRequested(_selectedGameType),
                                  );
                            } else {
                              context.read<LobbyBloc>().add(
                                    CreateSessionRequested(_selectedGameType),
                                  );
                            }
                          },
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: context.textPrimaryColor
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 32,
                              color: context.textPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    CustomDivider(text: 'Oppure unisciti ad una partita'),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _inviteCodeController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        labelText: 'Codice Invito',
                        labelStyle: TextStyle(
                          color: context.textPrimaryColor,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: ColorPalette.info,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            final isWordBombInviteCode = _inviteCodeController
                                    .text
                                    .toUpperCase()
                                    .startsWith('W') &&
                                _inviteCodeController.text
                                    .toUpperCase()
                                    .endsWith('B');

                            if (_inviteCodeController.text.isNotEmpty) {
                              if (isWordBombInviteCode &&
                                  !hasWordBombTrial &&
                                  !isPremiumUser) {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) =>
                                      PremiumAccessDialog(
                                    premiumOnly: true,
                                    title: 'Accesso Premium Richiesto',
                                    description:
                                        'Per accedere a una lobby Word Bomb devi essere un utente premium!',
                                  ),
                                );
                                return;
                              }

                              context.read<LobbyBloc>().add(
                                    JoinSessionRequested(
                                      _inviteCodeController.text.trim(),
                                    ),
                                  );
                            }
                          },
                          icon: Icon(
                            Icons.arrow_forward_rounded,
                            size: 28,
                          ),
                        ),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
