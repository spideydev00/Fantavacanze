import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/theme/theme.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:fantavacanze_official/initial_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize dependencies
  await initDependencies();

  //vertical orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => serviceLocator<AuthBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<LeagueBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<AppUserCubit>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<AppLeagueCubit>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<AppNavigationCubit>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<AppThemeCubit>()..loadTheme(),
          ),
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
    await Future.wait([
      _initializeUserAndLeagues(),
      // Attendi almeno 3 secondi per permettere di mostrare lo splash screen
      Future.delayed(
        const Duration(seconds: 3),
      ),
    ]).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint("Initialization timed out!");
        return <void>[];
      },
    );

    debugPrint("User and leagues initialized successfully.");
  }

  Future<void> _initializeUserAndLeagues() async {
    try {
      // Get current user
      await context.read<AppUserCubit>().getCurrentUser();

      if (mounted) {
        final userState = context.read<AppUserCubit>().state;

        if (userState is AppUserIsLoggedIn) {
          // Fetch user leagues
          await context.read<AppLeagueCubit>().getUserLeagues();
        }
      }
    } catch (e) {
      debugPrint("Error in user/league initialization: $e");
    } finally {
      // Hide the splash screen
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppThemeCubit, AppThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          title: 'Fantavacanze',
          home: InitialPage(),
          themeMode: themeState.themeMode,
          theme: AppTheme.getLightTheme(context),
          darkTheme: AppTheme.getDarkTheme(context),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
