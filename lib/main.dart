import 'dart:async';

import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/cubits/notification_count/notification_count_cubit.dart';
import 'package:fantavacanze_official/core/theme/theme.dart';
import 'package:fantavacanze_official/core/utils/route_observer_wrapper.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:fantavacanze_official/initial_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fantavacanze_official/core/utils/ad_helper.dart';

/// Key per mostrare SnackBar globali
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Key per navigare sempre sul Navigator principale
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Add this RouteObserver to track navigation
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

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
        ],
        child: const MyApp(),
      ),
    );
  });
}

class AdManagerWidget extends StatefulWidget {
  final Widget child;

  const AdManagerWidget({super.key, required this.child});

  @override
  State<AdManagerWidget> createState() => _AdManagerWidgetState();
}

class _AdManagerWidgetState extends State<AdManagerWidget>
    with WidgetsBindingObserver, RouteAware {
  late AdHelper _adHelper;
  Timer? _initialAdTimer;
  final RouteObserver<PageRoute> _routeObserver = RouteObserver<PageRoute>();

  @override
  void initState() {
    super.initState();
    _adHelper = serviceLocator<AdHelper>();

    // Set excluded routes
    _setupExcludedRoutes();

    WidgetsBinding.instance.addObserver(this);

    // Start with a 30-second delay for the first ad
    _initialAdTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        // Show the first ad
        _adHelper.showInterstitialAd();

        // Then start the regular timer for subsequent ads
        _adHelper.startAdTimer(context);
      }
    });
  }

  void _setupExcludedRoutes() {
    // Add routes that should be excluded from recurring ads
    _adHelper.excludeRouteFromAds('/drink_games');
    // Add more excluded routes as needed
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _adHelper.stopAdTimer();
    _initialAdTimer?.cancel();
    _routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _adHelper.startAdTimer(context);
    } else if (state == AppLifecycleState.paused) {
      _adHelper.stopAdTimer();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPush() {
    // Route was pushed, update current route
    final route = ModalRoute.of(context);
    if (route != null) {
      _adHelper.updateCurrentRoute(route.settings.name ?? '/unknown');
    }
  }

  @override
  void didPop() {
    // Route was popped, update current route
    final route = ModalRoute.of(context);
    if (route != null) {
      _adHelper.updateCurrentRoute(route.settings.name ?? '/unknown');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
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

      if (mounted && context.read<AppUserCubit>().state is AppUserIsLoggedIn) {
        await context.read<AppLeagueCubit>().getUserLeagues();
      }

      await Future.delayed(const Duration(seconds: 1));
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
          navigatorObservers: [
            SafeRouteObserver(),
          ],
        );
      },
    );
  }
}
