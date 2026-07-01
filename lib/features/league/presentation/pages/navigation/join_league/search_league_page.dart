import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/ambient_glow.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/core/widgets/info_banner.dart';
import 'package:fantavacanze_official/core/widgets/joining_league_overlay.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_state.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/partner_bloc/partner_cubit.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/create_league/league_user_explainer_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/join_league/choose_team_page.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SearchingStatus {
  initial,
  searching,
}

class SearchLeaguePage extends StatefulWidget {
  static const String routeName = '/search_league';

  static Route get route => MaterialPageRoute(
        builder: (context) => const SearchLeaguePage(),
        settings: const RouteSettings(name: routeName),
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

  // Cubit partner dedicato a questa pagina, usato per l'unione alle leghe
  // travel (che richiedono la parola d'ordine validata lato server).
  late final PartnerCubit _partnerCubit;

  /// ------------------------------
  /// Inizializza lo stato recuperando l'userId dal cubit
  /// ------------------------------
  @override
  void initState() {
    super.initState();
    _partnerCubit = serviceLocator<PartnerCubit>();
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
    _partnerCubit.close();
    super.dispose();
  }

  /// ------------------------------
  /// Metodo che scatta la ricerca di una lega tramite codice invito
  /// ------------------------------
  void _searchLeague() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_inviteCodeController.text.isEmpty || _userId == null) return;

    setState(() {
      _searchingStatus = SearchingStatus.searching;
    });

    context.read<LeagueBloc>().add(
          SearchLeagueEvent(inviteCode: _inviteCodeController.text.trim()),
        );
  }

  /// ------------------------------
  /// Costruisce la UI principale con AppBar, BlocConsumer e overlay di loading
  /// ------------------------------
  @override
  Widget build(BuildContext context) {
    return BlocListener<PartnerCubit, PartnerState>(
      bloc: _partnerCubit,
      listener: _onPartnerState,
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Cerca Lega',
          style: context.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: AmbientGlow(
        child: SafeArea(
          child: Stack(
            children: [
              BlocConsumer<LeagueBloc, LeagueState>(
                listener: (context, state) {
                  if (state is LeagueError) {
                    showSnackBar(
                      state.message,
                      color: ColorPalette.error,
                    );
                    setState(() {
                      _searchingStatus = SearchingStatus.initial;
                      _isJoiningLeague = false;
                    });
                  } else if (state is MultiplePossibleLeagues) {
                    setState(
                      () => _searchingStatus = SearchingStatus.initial,
                    );
                    _showMultipleLeaguesDialog(
                      state.possibleLeagues,
                      state.inviteCode,
                    );
                  } else if (state is LeagueWithInviteCode) {
                    setState(
                      () => _searchingStatus = SearchingStatus.initial,
                    );
                    _showLeagueFoundConfirmation(
                      context,
                      state.league,
                      state.inviteCode,
                    );
                  } else if (state is LeagueSuccess &&
                      state.operation == 'join_league') {
                    setState(
                      () => _isJoiningLeague = false,
                    );
                    context.read<AppNavigationCubit>().setIndex(0);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LeagueUserExplainerPage(),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  // Wrap the content in SingleChildScrollView to prevent overflow
                  return SingleChildScrollView(
                    // Make sure it fills available space for proper positioning
                    child: Container(
                      // This ensures the container takes at least the full screen height
                      // minus the app bar height, preventing awkward scrolling for small content
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            AppBar().preferredSize.height -
                            MediaQuery.of(context).padding.top,
                      ),
                      child: _buildSearchView(),
                    ),
                  );
                },
              ),
              if (_isJoiningLeague) const JoiningLeagueOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  /// ------------------------------
  /// Widget contenente il campo di input e il pulsante per cercare
  /// ------------------------------
  Widget _buildSearchView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
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
  /// Reagisce agli stati del PartnerCubit per l'unione alle leghe travel
  /// ------------------------------
  void _onPartnerState(BuildContext context, PartnerState state) {
    if (state is PartnerFailure) {
      showSnackBar(state.message, color: ColorPalette.error);
      setState(() => _isJoiningLeague = false);
      return;
    }

    if (state is PartnerLeagueReady) {
      setState(() => _isJoiningLeague = false);
      context.read<AppLeagueCubit>().selectLeague(state.league);
      context.read<AppNavigationCubit>().setIndex(0);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const LeagueUserExplainerPage(),
        ),
      );
    }
  }

  /// ------------------------------
  /// Chiede la parola d'ordine per unirsi a una lega partner di tipo travel
  /// ------------------------------
  Future<void> _showTravelPasswordDialog(
    League league,
    String inviteCode,
  ) async {
    // Chiudi la keyboard prima di aprire il dialog: si riaprirà solo se
    // l'utente tocca il campo password.
    FocusManager.instance.primaryFocus?.unfocus();

    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TravelPasswordDialog(leagueName: league.name),
    );

    if (password == null || !mounted) return;
    _joinTravelLeague(inviteCode, password);
  }

  /// ------------------------------
  /// Avvia l'unione partner (con password) tramite il PartnerCubit
  /// ------------------------------
  void _joinTravelLeague(String inviteCode, String password) {
    final userState = context.read<AppUserCubit>().state;
    if (userState is! AppUserIsLoggedIn) {
      showSnackBar(
        'Devi effettuare l\'accesso per unirti alla lega.',
        color: ColorPalette.error,
      );
      return;
    }

    setState(() => _isJoiningLeague = true);
    _partnerCubit.joinLeague(
      userName: userState.user.name,
      inviteCode: inviteCode,
      password: password,
    );
  }

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
      builder: (_) => ConfirmationDialog.leagueFound(
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
        onConfirm: () {
          if (!mounted) return;

          // Lega travel: serve la parola d'ordine (validata lato server dal
          // flusso partner). Non usare l'unione generica che la salterebbe.
          final isTravelPartner =
              league.partner != null && league.partnerRoundId != null;
          if (isTravelPartner) {
            _showTravelPasswordDialog(league, inviteCode);
            return;
          }

          if (league.type == LeagueType.individual) {
            _showJoinIndividualLeagueConfirmationWithAnimation(
              context,
              league,
              inviteCode,
            );
          } else {
            _navigateToChooseTeamPage(league, inviteCode);
          }
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

/// ------------------------------
/// Dialog (stateful) per la parola d'ordine di una lega partner travel.
/// Possiede il proprio controller e lo dispone nel ciclo di vita del widget
/// (niente dispose in `.then`, che causava un crash all'annullamento).
/// Niente autofocus: la keyboard si apre solo toccando il campo.
/// Restituisce la password tramite `Navigator.pop`, oppure `null` se annullato.
/// ------------------------------
class _TravelPasswordDialog extends StatefulWidget {
  final String leagueName;

  const _TravelPasswordDialog({required this.leagueName});

  @override
  State<_TravelPasswordDialog> createState() => _TravelPasswordDialogState();
}

class _TravelPasswordDialogState extends State<_TravelPasswordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final password = _controller.text.trim();
    if (password.isEmpty) {
      showSnackBar(
        'Inserisci la parola d\'ordine',
        color: ColorPalette.warning,
      );
      return;
    }
    Navigator.of(context).pop(password);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
      ),
      title: Text(
        'Parola d\'ordine',
        style: context.textTheme.titleMedium!
            .copyWith(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${widget.leagueName}" è una lega partner: inserisci la parola d\'ordine per unirti.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: ThemeSizes.md),
          TextField(
            controller: _controller,
            // obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Parola d\'ordine',
              prefixIcon: const Icon(Icons.lock_outline),
              filled: true,
              fillColor: context.secondaryBgColor,
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        ThemeSizes.lg,
        0,
        ThemeSizes.lg,
        ThemeSizes.lg,
      ),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Unisciti'),
            ),
            const SizedBox(height: ThemeSizes.xs),
            OutlinedButton(
              style: context.outlinedButtonThemeData.style!.copyWith(
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
          ],
        ),
      ],
    );
  }
}
