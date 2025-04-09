import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/secrets/app_secrets.dart';
import 'package:fantavacanze_official/features/auth/data/remote_data_source/auth_remote_data_source.dart';
import 'package:fantavacanze_official/features/auth/data/repository/auth_repository_impl.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/apple_sign_in.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/email_sign_in.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/email_sign_up.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/get_current_user.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/google_sign_in.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/league/data/remote_data_source/league_remote_data_source.dart';
import 'package:fantavacanze_official/features/league/data/repository/league_repository_impl.dart';
import 'package:fantavacanze_official/features/league/domain/repository/league_repository.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/add_event.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/add_memory.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/create_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/exit_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/get_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/get_rules.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/join_league.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/update_team_name.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  final supabase = await Supabase.initialize(
    anonKey: AppSecrets.supabaseKey,
    url: AppSecrets.supabaseUrl,
  );

  serviceLocator.registerLazySingleton(() => supabase.client);

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register UUID generator
  serviceLocator.registerLazySingleton(() => const Uuid());

  _initAuth();
  _initLeague();
}

void _initAuth() {
  serviceLocator
    //datasource
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(supabaseClient: serviceLocator()),
    )
    //repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(authRemoteDataSource: serviceLocator()),
    )
    //usecases
    ..registerFactory(
      () => GoogleSignIn(authRepository: serviceLocator()),
    )
    ..registerFactory(
      () => AppleSignIn(authRepository: serviceLocator()),
    )
    ..registerFactory(
      () => EmailSignIn(authRepository: serviceLocator()),
    )
    ..registerFactory(
      () => EmailSignUp(authRepository: serviceLocator()),
    )
    ..registerFactory(
      () => GetCurrentUser(authRepository: serviceLocator()),
    )
    //app-wide cubits:
    //1. user cubit
    ..registerLazySingleton(
        () => AppUserCubit(getCurrentUser: serviceLocator()))
    //2. navigation cubit
    ..registerLazySingleton(() => AppNavigationCubit())
    //3. theme cubit
    ..registerLazySingleton<AppThemeCubit>(
      () => AppThemeCubit(prefs: serviceLocator<SharedPreferences>()),
    )
    //bloc
    ..registerLazySingleton(
      () => AuthBloc(
        googleSignIn: serviceLocator(),
        appleSignIn: serviceLocator(),
        appUserCubit: serviceLocator(),
        emailSignIn: serviceLocator(),
        emailSignUp: serviceLocator(),
      ),
    );
}

void _initLeague() {
  serviceLocator
    // data sources
    ..registerFactory<LeagueRemoteDataSource>(
      () => LeagueRemoteDataSourceImpl(
        supabaseClient: serviceLocator(),
        appUserCubit: serviceLocator(),
        uuid: serviceLocator(),
      ),
    )

    // repository
    ..registerFactory<LeagueRepository>(
      () => LeagueRepositoryImpl(remoteDataSource: serviceLocator()),
    )

    // use cases
    ..registerFactory(() => CreateLeague(leagueRepository: serviceLocator()))
    ..registerFactory(() => GetLeague(leagueRepository: serviceLocator()))
    ..registerFactory(() => JoinLeague(leagueRepository: serviceLocator()))
    ..registerFactory(() => ExitLeague(leagueRepository: serviceLocator()))
    ..registerFactory(() => UpdateTeamName(leagueRepository: serviceLocator()))
    ..registerFactory(() => AddEvent(leagueRepository: serviceLocator()))
    ..registerFactory(() => AddMemory(leagueRepository: serviceLocator()))
    ..registerFactory(() => GetRules(leagueRepository: serviceLocator()))

    // bloc
    ..registerFactory(
      () => LeagueBloc(
        createLeague: serviceLocator(),
        getLeague: serviceLocator(),
        joinLeague: serviceLocator(),
        exitLeague: serviceLocator(),
        updateTeamName: serviceLocator(),
        addEvent: serviceLocator(),
        addMemory: serviceLocator(),
        getRules: serviceLocator(),
        supabaseClient: serviceLocator(),
      ),
    );
}
