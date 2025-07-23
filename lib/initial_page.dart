import 'dart:async';

// import 'package:advertising_id/advertising_id.dart';
// import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/services/gdpr_service.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // La nuova, semplicissima funzione di inizializzazione
      _initializeConsentFlow();
    });
  }

  Future<void> _initializeConsentFlow() async {
    // 1. Chiama il tuo GdprService che usa l'SDK UMP.
    await GdprService().initializeAndShowForm();

    // //per iOS
    // final idfa = await AppTrackingTransparency.getAdvertisingIdentifier();
    // debugPrint('IDFA dispositivo: $idfa');

    // //per Android
    // final adId = await AdvertisingId.id(true);
    // debugPrint('Advertising ID dispositivo: $adId');

    // 2. Inizializza l'SDK di AdMob solo dopo che il flusso di consenso è terminato.
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
