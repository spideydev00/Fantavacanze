import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit_cubit.dart';
import 'package:fantavacanze_official/core/theme/theme.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/social_login.dart';
import 'package:fantavacanze_official/init_dependencies.dart';
import 'package:fantavacanze_official/initial_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

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
            create: (_) => serviceLocator<AppUserCubit>(),
          )
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

    //check if session exists and update state
    final futureUser = context.read<AppUserCubit>().getCurrentUser();

    //splash screen 3 seconds duration
    final delayedSplash = Future.delayed(Duration(seconds: 3));

    //remove splash screen when both conditions are met
    Future.wait([futureUser, delayedSplash]).then(
      (_) => {FlutterNativeSplash.remove()},
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fantavacanze',
      home: const SocialLoginPage(),
      theme: AppTheme.getDarkTheme(context),
      debugShowCheckedModeBanner: false,
    );
  }
}
