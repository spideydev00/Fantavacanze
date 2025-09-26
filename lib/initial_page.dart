import 'dart:async';

import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_fs_league/app_fs_league_cubit.dart';
import 'package:fantavacanze_official/core/services/gdpr_service.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/gender_and_status_selection_page.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/onboarding.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/social_login.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/sections/dashboard.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/pages/fs_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeConsentFlow();
    });
  }

  Future<void> _initializeConsentFlow() async {
    await GdprService().initializeAndShowForm();
    await MobileAds.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppUserCubit, AppUserState>(
      builder: (context, userState) {
        if (userState is AppUserIsLoggedIn) {
          // User is logged in, now check FS league status
          return BlocBuilder<AppFsLeagueCubit, AppFsLeagueState>(
            builder: (context, fsState) {
              if (fsState is AppFsLeagueExists) {
                // User has FS league, navigate to FS dashboard
                return const FsDashboardPage();
              } else {
                // No FS league, navigate to normal dashboard
                return const DashboardScreen();
              }
            },
          );
        } else if (userState is AppUserNeedsOnboarding) {
          return OnBoardingScreen();
        } else if (userState is AppUserNeedsGenderOrStatus) {
          return GenderAndStatusSelectionPage();
        }
        return const SocialLoginPage();
      },
    );
  }
}
