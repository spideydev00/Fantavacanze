import 'package:fantavacanze_official/core/cubits/app_fs_league/app_fs_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/pages/fs_dashboard_page.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/pages/fs_main_page.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/pages/fs_onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FsRouterPage extends StatefulWidget {
  static const String routeName = '/fs-router';

  static get route => MaterialPageRoute(
        builder: (context) => const FsRouterPage(),
        settings: const RouteSettings(name: routeName),
      );

  const FsRouterPage({super.key});

  @override
  State<FsRouterPage> createState() => _FsRouterPageState();
}

class _FsRouterPageState extends State<FsRouterPage> {
  @override
  void initState() {
    super.initState();
    // Check FS League state when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppFsLeagueCubit>().checkFsLeague();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: BlocBuilder<AppFsLeagueCubit, AppFsLeagueState>(
        builder: (context, fsState) {
          return _getAppropriateScreen(fsState);
        },
      ),
    );
  }

  Widget _getAppropriateScreen(AppFsLeagueState fsState) {
    if (fsState is AppFsLeagueExists) {
      // User has a FantaSerata league -> show dashboard
      return const FsDashboardPage();
    } else if (fsState is AppFsLeagueNotExists) {
      // User doesn't have a FantaSerata league -> check if first time
      final userState = context.read<AppUserCubit>().state;

      if (userState is AppUserIsLoggedIn) {
        if (!userState.user.hasPlayedFs) {
          // First time user -> show onboarding
          return const FsOnboardingScreen();
        } else {
          // Returning user -> show main page
          return const FsMainPage();
        }
      } else {
        // User not logged in -> fallback to main page
        return const FsMainPage();
      }
    }

    // Loading state - return empty container
    return Container();
  }
}
