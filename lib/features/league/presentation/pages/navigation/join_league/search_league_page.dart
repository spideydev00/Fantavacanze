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
import 'package:fantavacanze_official/features/league/presentation/widgets/core/confirmation_dialog.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/core/info_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SearchingStatus {
  initial,
  searching,
}

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
  bool _isJoiningLeague = false; // Track joining state separately

  @override
  void initState() {
    super.initState();
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserIsLoggedIn) {
      _userId = userState.user.id;
    }
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  // Search for a league with the provided invite code
  void _searchLeague() {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_inviteCodeController.text.isEmpty || _userId == null) return;

    setState(() {
      _searchingStatus = SearchingStatus.searching;
    });

    context.read<LeagueBloc>().add(
          SearchLeagueEvent(
            inviteCode: _inviteCodeController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cerca Lega',
          style: context.textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          BlocConsumer<LeagueBloc, LeagueState>(
            listener: (context, state) {
              if (state is LeagueError) {
                showSnackBar(
                  context,
                  state.message,
                  color: ColorPalette.error,
                );
                setState(() {
                  _searchingStatus = SearchingStatus.initial;
                  _isJoiningLeague = false; // Reset joining state
                });
              } else if (state is MultiplePossibleLeagues) {
                setState(() => _searchingStatus = SearchingStatus.initial);
                _showMultipleLeaguesDialog(
                    state.possibleLeagues, state.inviteCode);
              } else if (state is LeagueWithInviteCode) {
                setState(() => _searchingStatus = SearchingStatus.initial);
                _showLeagueFoundConfirmation(
                    context, state.league, state.inviteCode);
              } else if (state is LeagueSuccess &&
                  state.operation == 'join_league') {
                setState(() => _isJoiningLeague = false); // Reset joining state

                // Navigate to home screen first
                Navigator.of(context).popUntil((route) => route.isFirst);
                context.read<AppNavigationCubit>().setIndex(0);
              }
            },
            builder: (context, state) {
              return _buildSearchView();
            },
          ),

          // Full-screen loading overlay using our own tracked state
          if (_isJoiningLeague)
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

  Widget _buildSearchView() {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      ),
      margin: const EdgeInsets.all(ThemeSizes.lg),
      padding: const EdgeInsets.all(ThemeSizes.lg),
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
                : const Icon(
                    Icons.search,
                    size: 24,
                  ),
          ),
        ],
      ),
    );
  }

  // Show dialog for selecting between multiple leagues with the same invite code
  void _showMultipleLeaguesDialog(
    List<League> possibleLeagues,
    String inviteCode,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleziona una Lega'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: possibleLeagues.length,
            itemBuilder: (context, index) {
              final league = possibleLeagues[index];
              return ListTile(
                title: Text(league.name),
                subtitle: Text(league.description ?? 'Nessuna descrizione'),
                onTap: () {
                  Navigator.pop(context);
                  // Show confirmation for the selected league
                  _showLeagueFoundConfirmation(context, league, inviteCode);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
        ],
      ),
    );
  }

  // Navigate to team selection page
  void _navigateToChooseTeamPage(League league, String inviteCode) {
    Navigator.push(
        context, ChooseTeamPage.route(league: league, inviteCode: inviteCode));
  }

  // Show initial confirmation dialog when a league is found
  void _showLeagueFoundConfirmation(
      BuildContext context, League league, String inviteCode) {
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
          if (!league.isTeamBased) {
            FocusScope.of(context).unfocus();
            // Add a small delay for smoother transition
            Future.delayed(const Duration(milliseconds: 200), () {
              if (context.mounted) {
                // Show confirmation dialog for joining the league
                _showJoinIndividualLeagueConfirmation(
                  context,
                  league,
                  inviteCode,
                );
              }
            });
          } else {
            Navigator.of(dialogContext).pop();
            _navigateToChooseTeamPage(league, inviteCode);
          }
        },
      ),
    );
  }

  // Completely redesigned method that simplifies the flow
  void _showJoinIndividualLeagueConfirmationWithAnimation(
    BuildContext context,
    League league,
    String inviteCode,
  ) {
    // Show a bouncy dialog for joining the league
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Barrier',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        // Create bounce animation
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
                              // Close this dialog
                              Navigator.of(dialogContext).pop();

                              // Set loading state
                              setState(() => _isJoiningLeague = true);

                              // Directly trigger the join league event
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

  // Show confirmation dialog for joining an individual league (original version - kept for reference)
  void _showJoinIndividualLeagueConfirmation(
      BuildContext context, League league, String inviteCode) {
    _showJoinIndividualLeagueConfirmationWithAnimation(
      context,
      league,
      inviteCode,
    );
  }
}
