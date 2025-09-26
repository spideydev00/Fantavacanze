import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_fs_league/app_fs_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/fs_navigation/fs_navigation_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/bloc/fs_dynamic_rules_bloc/fs_dynamic_rules_bloc.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_dashboard/fs_dashboard_header.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_dashboard/fs_objectives_section.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_dashboard/fs_bottom_navigation.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/pages/fs_main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FsDashboardPage extends StatelessWidget {
  static const String routeName = '/fs-dashboard';

  static get route => MaterialPageRoute(
        builder: (context) => const FsDashboardPage(),
        settings: const RouteSettings(name: routeName),
      );

  const FsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FsDashboardPageContent();
  }
}

class _FsDashboardPageContent extends StatefulWidget {
  const _FsDashboardPageContent();

  @override
  State<_FsDashboardPageContent> createState() =>
      _FsDashboardPageContentState();
}

class _FsDashboardPageContentState extends State<_FsDashboardPageContent> {
  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  void _initializeDashboard() {
    final userState = context.read<AppUserCubit>().state;
    final fsLeagueState = context.read<AppFsLeagueCubit>().state;

    if (userState is AppUserIsLoggedIn && fsLeagueState is AppFsLeagueExists) {
      // Initialize dynamic rules
      context.read<FsDynamicRulesBloc>().add(
            GetUserDynamicRulesEvent(
              userId: userState.user.id,
              leagueId: fsLeagueState.league.id,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AppUserCubit>().state;
    final fsLeagueState = context.watch<AppFsLeagueCubit>().state;

    // Check if user is authenticated
    if (userState is! AppUserIsLoggedIn) {
      return _buildErrorScaffold(
        context,
        'Errore: utente non autenticato',
        null,
      );
    }

    // Check if user has a FS league
    if (fsLeagueState is! AppFsLeagueExists) {
      return _buildErrorScaffold(
        context,
        'Nessuna lega FantaSerata trovata',
        'Crea o unisciti a una lega per iniziare',
        onAction: () {
          Navigator.of(context).pushReplacement(FsMainPage.route);
        },
        actionText: 'Torna alla Home',
      );
    }

    final league = fsLeagueState.league;

    return Scaffold(
      backgroundColor: context.bgColor,
      appBar: AppBar(
        toolbarHeight: 80,
        title: Image.asset(
          'assets/images/fantaserata/logo/Logo-Fs.png',
          width: Constants.getWidth(context) * 0.20,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header with league info
          FsDashboardHeader(league: league),

          // Main content
          Expanded(
            child: BlocBuilder<FsNavigationCubit, FsNavigationState>(
              builder: (context, navState) {
                return _buildCurrentPage(
                    userState.user, league, navState.selectedIndex);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BlocBuilder<FsNavigationCubit, FsNavigationState>(
        builder: (context, navState) {
          return FsBottomNavigation(
            currentIndex: navState.selectedIndex,
            onTap: (index) {
              context.read<FsNavigationCubit>().setIndex(index);
            },
          );
        },
      ),
    );
  }

  Widget _buildCurrentPage(user, league, int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return FsObjectivesSection(
          user: user,
          league: league,
        );
      case 1:
        return _buildPlaceholderPage('Classifica', Icons.leaderboard);
      default:
        return FsObjectivesSection(
          user: user,
          league: league,
        );
    }
  }

  Widget _buildErrorScaffold(
    BuildContext context,
    String message,
    String? subtitle, {
    VoidCallback? onAction,
    String? actionText,
  }) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(ThemeSizes.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: context.textSecondaryColor,
              ),
              const SizedBox(height: ThemeSizes.md),
              Text(
                message,
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: ThemeSizes.sm),
                Text(
                  subtitle,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (onAction != null && actionText != null) ...[
                const SizedBox(height: ThemeSizes.lg),
                ElevatedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(actionText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderPage(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: context.textSecondaryColor,
          ),
          const SizedBox(height: ThemeSizes.md),
          Text(
            title,
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: ThemeSizes.sm),
          Text(
            'Sezione in sviluppo',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
