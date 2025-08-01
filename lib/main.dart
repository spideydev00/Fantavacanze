import 'dart:async';
import 'package:fantavacanze_official/features/league/presentation/bloc/notifications_bloc/notifications_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/subscription_bloc/subscription_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/cubits/notification_count/notification_count_cubit.dart';
import 'package:fantavacanze_official/core/theme/theme.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/never_have_i_ever/never_have_i_ever_bloc.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/truth_or_dare/truth_or_dare_bloc.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/word_bomb/word_bomb_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/daily_challenges_bloc/daily_challenges_bloc.dart';
import 'package:fantavacanze_official/features/games/presentation/bloc/game/game_bloc.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:fantavacanze_official/initial_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

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
          BlocProvider(create: (_) => serviceLocator<DailyChallengesBloc>()),
          BlocProvider(create: (_) => serviceLocator<NotificationsBloc>()),
          BlocProvider(create: (_) => serviceLocator<SubscriptionBloc>()),
          BlocProvider(create: (_) => serviceLocator<AppUserCubit>()),
          BlocProvider(create: (_) => serviceLocator<AppLeagueCubit>()),
          BlocProvider(create: (_) => serviceLocator<AppNavigationCubit>()),
          BlocProvider(create: (_) => serviceLocator<NotificationCountCubit>()),
          BlocProvider.value(value: themeCubit),
          BlocProvider(create: (_) => serviceLocator<LobbyBloc>()),
          BlocProvider(create: (_) => serviceLocator<WordBombBloc>()),
          BlocProvider(create: (_) => serviceLocator<TruthOrDareBloc>()),
          BlocProvider(create: (_) => serviceLocator<NeverHaveIEverBloc>()),
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
    _listenToPremiumStatusChanges();
  }

  Future<void> _initializeApp() async {
    try {
      if (mounted) {
        await context.read<AppUserCubit>().getCurrentUser();
      }

      // If user is logged in, then load their specific data and check subscription
      if (mounted && context.read<AppUserCubit>().state is AppUserIsLoggedIn) {
        await _checkSubscriptionOnStartup();
        if (mounted) {
          await context.read<AppLeagueCubit>().getUserLeagues();
        }
      }
    } catch (e) {
      debugPrint("Errore di inizializzazione nel main: $e");
    } finally {
      FlutterNativeSplash.remove();
    }
  }

  Future<void> _checkSubscriptionOnStartup() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      final entitlement = customerInfo.entitlements.all['premium_benefit'];
      final isPremium = entitlement?.isActive ?? false;

      // If the user is no longer premium, update their status in the app
      if (!isPremium && mounted) {
        // Also check if the user in the cubit is currently premium before removing it
        final userState = context.read<AppUserCubit>().state;
        if (userState is AppUserIsLoggedIn && userState.user.isPremium) {
          context.read<AppUserCubit>().removePremium();
        }
      }
    } catch (e) {
      debugPrint("Errore durante il controllo dell'abbonamento all'avvio: $e");
    }
  }

  void _listenToPremiumStatusChanges() {
    Purchases.addCustomerInfoUpdateListener(
      (customerInfo) {
        final entitlement = customerInfo.entitlements.all['premium_benefit'];

        // If the entitlement doesn't exist, do nothing.
        if (entitlement == null) {
          return;
        }

        final isPremium = entitlement.isActive;

        if (!isPremium && mounted) {
          // We can add the same check here for consistency
          final userState = context.read<AppUserCubit>().state;
          if (userState is AppUserIsLoggedIn && userState.user.isPremium) {
            context.read<AppUserCubit>().removePremium();
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppThemeCubit, AppThemeState>(
      builder: (context, state) {
        return MaterialApp(
          showSemanticsDebugger: false,
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: messengerKey,
          title: 'Fantavacanze',
          home: const InitialPage(),
          themeMode: state.themeMode,
          theme: AppTheme.getLightTheme(context),
          darkTheme: AppTheme.getDarkTheme(context),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('it', 'IT'),
          ],
          locale: const Locale(
            'it',
            'IT',
          ),
        );
      },
    );
  }
}
