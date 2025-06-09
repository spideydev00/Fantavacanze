import 'dart:async';

import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/cubits/notification_count/notification_count_cubit.dart';
import 'package:fantavacanze_official/core/services/gdpr_service.dart';
import 'package:fantavacanze_official/core/theme/theme.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/lobby/lobby_bloc.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:fantavacanze_official/initial_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

/// Key per mostrare SnackBar globali
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Key per navigare sempre sul Navigator principale
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize dependencies
  await initDependencies();

  // Pre-load theme settings
  final themeCubit = serviceLocator<AppThemeCubit>();
  await themeCubit.loadTheme();

  // Vertical orientation
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
          BlocProvider(create: (_) => serviceLocator<LeagueBloc>()),
          BlocProvider(create: (_) => serviceLocator<AppUserCubit>()),
          BlocProvider(create: (_) => serviceLocator<AppLeagueCubit>()),
          BlocProvider(create: (_) => serviceLocator<AppNavigationCubit>()),
          BlocProvider(create: (_) => serviceLocator<NotificationCountCubit>()),
          BlocProvider.value(value: themeCubit),
          BlocProvider(create: (_) => serviceLocator<LobbyBloc>()),
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      if (mounted) {
        await context.read<AppUserCubit>().getCurrentUser();
      }

      await serviceLocator<GdprService>().initializeAndShowForm();

      // If user is logged in, then load their specific data
      if (mounted && context.read<AppUserCubit>().state is AppUserIsLoggedIn) {
        await context.read<AppLeagueCubit>().getUserLeagues();
      }
    } catch (e) {
      debugPrint("Errore di inizializzazione nel main: $e");
    } finally {
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppThemeCubit, AppThemeState>(
      builder: (context, state) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: messengerKey,
          title: 'Fantavacanze',
          home: const InitialPage(),
          themeMode: state.themeMode,
          theme: AppTheme.getLightTheme(context),
          darkTheme: AppTheme.getDarkTheme(context),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
