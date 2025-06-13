import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/services/gdpr_service.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/idfa_explainer_dialog.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/gender_selection_page.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/onboarding.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/social_login.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/sections/dashboard.dart';
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
    // Avviamo la sequenza completa di inizializzazione.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAttAndGdpr();
    });
  }

  Future<void> _initializeAttAndGdpr() async {
    // 1. Subito dopo, gestisci il consenso ATT (IDFA).
    if (await AppTrackingTransparency.trackingAuthorizationStatus ==
            TrackingStatus.notDetermined &&
        mounted) {
      await IdfaExplainerDialog.show(
        context,
        onContinue: () async {
          await AppTrackingTransparency.requestTrackingAuthorization();
        },
      );
    }

    // 2. Gestisci il consenso GDPR.
    Future.delayed(
      const Duration(seconds: 1, milliseconds: 4),
      () async {
        await GdprService().initializeAndShowForm();
      },
    );

    // 3. ORA e solo ora, inizializza l'SDK di AdMob.
    await MobileAds.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppUserCubit, AppUserState>(
      builder: (context, state) {
        if (state is AppUserIsLoggedIn) {
          return const DashboardScreen();
        } else if (state is AppUserNeedsOnboarding) {
          return OnBoardingScreen();
        } else if (state is AppUserNeedsGender) {
          return GenderSelectionPage();
        }
        return const SocialLoginPage();
      },
    );
  }
}
