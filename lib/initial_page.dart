import 'dart:async';

import 'package:fantavacanze_official/core/cubits/app_status/app_status_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_version/app_version_cubit.dart';
import 'package:fantavacanze_official/core/cubits/drop/drop_cubit.dart';
import 'package:fantavacanze_official/core/services/gdpr_service.dart';
import 'package:fantavacanze_official/features/app/domain/entities/app_status.dart';
import 'package:fantavacanze_official/features/app/domain/entities/app_version_config.dart';
import 'package:fantavacanze_official/features/app/presentation/app_unavailable.dart';
import 'package:fantavacanze_official/features/app/presentation/force_update_page.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/gender_and_status_selection_page.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/onboarding.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/social_login.dart';
import 'package:fantavacanze_official/features/drop/presentation/pages/drop_poster_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/sections/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppVersionCubit, AppVersionState>(
      builder: (context, versionState) {
        if (versionState.status == AppVersionStatus.forceUpdate) {
          return ForceUpdatePage(storeUrl: versionState.storeUrl);
        }

        return BlocBuilder<AppStatusCubit, AppStatusType>(
          builder: (context, appStatus) {
            if (appStatus == AppStatusType.unavailable) {
              return const AppUnavailablePage();
            }

            return BlocBuilder<AppUserCubit, AppUserState>(
              builder: (context, userState) {
                if (userState is AppUserIsLoggedIn) {
                  return BlocBuilder<DropCubit, DropState>(
                    builder: (context, dropState) {
                      if (dropState is DropVisible) {
                        return DropPosterPage(drop: dropState.drop);
                      }
                      return const DashboardScreen();
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
          },
        );
      },
    );
  }
}
