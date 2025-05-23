import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_state.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/join_league/choose_team_page.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/core/widgets/info_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// ------------------------------
/// Definisce lo stato della ricerca (iniziale o in corso)
/// ------------------------------
enum SearchingStatus {
  initial,
  searching,
}

/// ------------------------------
/// Widget di pagina per cercare una lega tramite codice invito
/// ------------------------------
class SearchLeaguePage extends StatefulWidget {
  static Route get route => MaterialPageRoute(
        builder: (context) => const SearchLeaguePage(),
      );

  const SearchLeaguePage({super.key});

  @override
  State<SearchLeaguePage> createState() => _SearchLeaguePageState();
}

class _SearchLeaguePageState extends State<SearchLeaguePage> {
  final TextEditingController _inviteCodeController = TextEditingController();
  SearchingStatus _searchingStatus = SearchingStatus.initial;
  String? _userId;
  bool _isJoiningLeague = false;

  /// ------------------------------
  /// Inizializza lo stato recuperando l'userId dal cubit
  /// ------------------------------
  @override
  void initState() {
    super.initState();
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserIsLoggedIn) {
      _userId = userState.user.id;
    }
  }

  /// ------------------------------
  /// Pulisce il TextEditingController quando il widget viene smontato
  /// ------------------------------
  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  /// ------------------------------
  /// Metodo che scatta la ricerca di una lega tramite codice invito
  /// ------------------------------
  void _searchLeague() {
    FocusScope.of(context).unfocus();

    if (_inviteCodeController.text.isEmpty || _userId == null) return;

    setState(() {
      _searchingStatus = SearchingStatus.searching;
    });

    context.read<LeagueBloc>().add(
          SearchLeagueEvent(inviteCode: _inviteCodeController.text),
        );
  }

  /// ------------------------------
  /// Costruisce la UI principale con AppBar, BlocConsumer e overlay di loading
  /// ------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cerca Lega', style: context.textTheme.headlineSmall),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          BlocConsumer<LeagueBloc, LeagueState>(
            listener: (context, state) {
              if (state is LeagueError) {
                showSnackBar(context, state.message, color: ColorPalette.error);
                setState(() {
                  _searchingStatus = SearchingStatus.initial;
                  _isJoiningLeague = false;
                });
              } else if (state is MultiplePossibleLeagues) {
                setState(() => _searchingStatus = SearchingStatus.initial);
                _showMultipleLeaguesDialog(
                  state.possibleLeagues,
                  state.inviteCode,
                );
              } else if (state is LeagueWithInviteCode) {
                setState(() => _searchingStatus = SearchingStatus.initial);
                _showLeagueFoundConfirmation(
                  context,
                  state.league,
                  state.inviteCode,
                );
              } else if (state is LeagueSuccess &&
                  state.operation == 'join_league') {
                setState(() => _isJoiningLeague = false);
                Navigator.of(context).popUntil((route) => route.isFirst);
                context.read<AppNavigationCubit>().setIndex(0);
              }
            },
            builder: (context, state) {
              return _buildSearchView();
            },
          ),
          if (_isJoiningLeague)
            // ------------------------------
            // Overlay full-screen di attesa durante l'unione alla lega
            // ------------------------------
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Card(
                  color: context.colorScheme.surface,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusMd),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(ThemeSizes.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Loader(color: ColorPalette.success),
                        const SizedBox(height: ThemeSizes.md),
                        Text(
                          'Unione alla lega in corso...',
                          style: TextStyle(
                            color: context.textPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: ThemeSizes.xs),
                        Text(
                          'Attendi il completamento',
                          style: TextStyle(
                            color: context.textSecondaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// ------------------------------
  /// Widget contenente il campo di input e il pulsante per cercare
  /// ------------------------------
  Widget _buildSearchView() {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      ),
      margin: const EdgeInsets.all(ThemeSizes.md),
      padding: const EdgeInsets.all(ThemeSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InfoBanner(
            message: "Inserisci il codice di invito per unirti a una lega",
            color: ColorPalette.info,
          ),
          const SizedBox(height: ThemeSizes.sm),
          TextField(
            controller: _inviteCodeController,
            decoration: InputDecoration(
              labelText: 'Codice Invito',
              hintText: 'Inserisci il codice di invito',
              prefixIcon: const Icon(Icons.code),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(ThemeSizes.borderRadiusMd),
                ),
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _searchLeague(),
          ),
          const SizedBox(height: ThemeSizes.lg),
          ElevatedButton.icon(
            style: context.elevatedButtonThemeData.style!.copyWith(
              fixedSize: WidgetStatePropertyAll(
                Size.fromWidth(Constants.getWidth(context) * 0.2),
              ),
            ),
            onPressed: _searchingStatus == SearchingStatus.searching
                ? null
                : _searchLeague,
            label: _searchingStatus == SearchingStatus.searching
                ? Loader(color: context.textPrimaryColor)
                : const Text('Cerca Lega'),
            icon: _searchingStatus == SearchingStatus.searching
                ? null
                : const Icon(Icons.search, size: 24),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  /// ------------------------------
  /// Mostra un dialog per scegliere tra più leghe con lo stesso codice
  /// ------------------------------
  void _showMultipleLeaguesDialog(
    List<League> possibleLeagues,
    String inviteCode,
  ) {
    final parentContext = context; // contesto della pagina, rimane valido

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(parentContext).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: parentContext.bgColor,
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ------------------------------
              // Header del dialog di selezione leghe
              // ------------------------------
              Container(
                padding: const EdgeInsets.all(ThemeSizes.lg),
                decoration: BoxDecoration(
                  color: ColorPalette.info.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(ThemeSizes.borderRadiusLg),
                    topRight: Radius.circular(ThemeSizes.borderRadiusLg),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(ThemeSizes.xs),
                      decoration: BoxDecoration(
                        color: ColorPalette.info.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.groups_rounded,
                        color: ColorPalette.info,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: ThemeSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seleziona una Lega',
                            style: parentContext.textTheme.bodyLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Abbiamo trovato più leghe con lo stesso codice',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ------------------------------
              // Lista scrollabile delle leghe disponibili
              // ------------------------------
              Flexible(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    vertical: ThemeSizes.md,
                    horizontal: ThemeSizes.md,
                  ),
                  itemCount: possibleLeagues.length,
                  separatorBuilder: (_, __) => Divider(
                    color: ColorPalette.darkGrey.withValues(alpha: 0.2),
                    height: 1,
                  ),
                  itemBuilder: (_, index) {
                    final league = possibleLeagues[index];
                    return InkWell(
                      borderRadius:
                          BorderRadius.circular(ThemeSizes.borderRadiusMd),
                      onTap: () {
                        // chiudo il dialog corrente con il dialogContext
                        Navigator.of(dialogContext).pop();
                        // riapro il confirmation dialog usando il context della pagina
                        _showLeagueFoundConfirmation(
                          parentContext,
                          league,
                          inviteCode,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: ThemeSizes.md,
                          horizontal: ThemeSizes.xs,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: parentContext.accentColor
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  league.name.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: parentContext.accentColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: ThemeSizes.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    league.name,
                                    style: parentContext.textTheme.bodyLarge!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  if (league.description != null &&
                                      league.description!.isNotEmpty)
                                    Text(
                                      league.description!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: parentContext.textTheme.labelLarge,
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: parentContext.textSecondaryColor,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ------------------------------
              // Pulsante per annullare la selezione e chiudere il dialog
              // ------------------------------
              Container(
                padding: const EdgeInsets.all(ThemeSizes.md),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: parentContext.outlinedButtonThemeData.style!.copyWith(
                    foregroundColor: WidgetStatePropertyAll(
                      parentContext.textPrimaryColor,
                    ),
                    minimumSize: const WidgetStatePropertyAll(
                      Size(double.infinity, 50),
                    ),
                  ),
                  child: const Text('Annulla'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // --------------------------------------------------

  /// ------------------------------
  /// Naviga alla pagina per scegliere la squadra nella lega team-based
  /// ------------------------------
  void _navigateToChooseTeamPage(
    League league,
    String inviteCode,
  ) {
    Navigator.push(
      context,
      ChooseTeamPage.route(
        league: league,
        inviteCode: inviteCode,
      ),
    );
  }

  /// ------------------------------
  /// Mostra dialog di conferma per la lega trovata (Sì/No)
  /// ------------------------------
  void _showLeagueFoundConfirmation(
    BuildContext context,
    League league,
    String inviteCode,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ConfirmationDialog.leagueFound(
        leagueName: league.name,
        description: league.description,
        outlinedButtonStyle: context.outlinedButtonThemeData.style!.copyWith(
          foregroundColor: WidgetStatePropertyAll(
            context.textPrimaryColor,
          ),
          side: WidgetStatePropertyAll(
            BorderSide(
              color: context.textPrimaryColor,
              width: 1,
            ),
          ),
        ),
        elevatedButtonStyle: context.elevatedButtonThemeData.style!.copyWith(
          backgroundColor: WidgetStatePropertyAll(
            ColorPalette.info,
          ),
        ),
        onCancel: () => Navigator.of(dialogContext).pop(),
        onConfirm: () {
          Future.microtask(() {
            if (!league.isTeamBased && context.mounted) {
              _showJoinIndividualLeagueConfirmationWithAnimation(
                context,
                league,
                inviteCode,
              );
            } else {
              _navigateToChooseTeamPage(league, inviteCode);
            }
          });
        },
      ),
    );
  }

  /// ------------------------------
  /// Mostra dialog animato “rimbalzo” per conferma unione leghe individuali
  /// ------------------------------
  void _showJoinIndividualLeagueConfirmationWithAnimation(
    BuildContext context,
    League league,
    String inviteCode,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Barrier',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: Dialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                padding: const EdgeInsets.all(ThemeSizes.lg),
                decoration: BoxDecoration(
                  color: context.bgColor,
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(ThemeSizes.md),
                      decoration: BoxDecoration(
                        color: ColorPalette.success.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.group_add,
                        color: ColorPalette.success,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: ThemeSizes.md),
                    Text(
                      'Unisciti alla Lega',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: ThemeSizes.sm),
                    Text(
                      'Vuoi unirti a ${league.name}?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: ThemeSizes.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style:
                                context.outlinedButtonThemeData.style!.copyWith(
                              foregroundColor: WidgetStatePropertyAll(
                                context.textPrimaryColor,
                              ),
                              side: WidgetStatePropertyAll(
                                BorderSide(
                                  color: context.textPrimaryColor,
                                  width: 1,
                                ),
                              ),
                            ),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Annulla'),
                          ),
                        ),
                        const SizedBox(width: ThemeSizes.md),
                        Expanded(
                          child: ElevatedButton(
                            style:
                                context.elevatedButtonThemeData.style!.copyWith(
                              backgroundColor: const WidgetStatePropertyAll(
                                ColorPalette.success,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              setState(() => _isJoiningLeague = true);
                              context.read<LeagueBloc>().add(
                                    JoinLeagueEvent(
                                      inviteCode: inviteCode,
                                      specificLeagueId: league.id,
                                    ),
                                  );
                            },
                            child: const Text('Unisciti'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
