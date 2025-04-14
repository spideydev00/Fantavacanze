part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  final supabase = await Supabase.initialize(
    anonKey: AppSecrets.supabaseKey,
    url: AppSecrets.supabaseUrl,
  );

  serviceLocator.registerLazySingleton(() => supabase.client);

  _initAuth();
  _initLeague();
  _initDashboard();

  // Initialize Hive
  final dir = await getApplicationDocumentsDirectory();
  Hive.defaultDirectory = dir.path;

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register UUID generator
  serviceLocator.registerLazySingleton(() => const Uuid());

  //hive boxes
  serviceLocator
    ..registerLazySingleton<Box<Map<dynamic, dynamic>>>(
      () => Hive.box<Map<dynamic, dynamic>>(),
      instanceName: 'leagues_box',
    )
    ..registerLazySingleton<Box<Map<dynamic, dynamic>>>(
      () => Hive.box<Map<dynamic, dynamic>>(),
      instanceName: 'rules_box',
    );

  serviceLocator.registerFactory(
    () => InternetConnection(),
  );

  // core cubits
  serviceLocator
    //1. user cubit
    ..registerLazySingleton(
        () => AppUserCubit(getCurrentUser: serviceLocator()))
    //2. navigation cubit
    ..registerLazySingleton(
      () => AppNavigationCubit(),
    )
    //3. theme cubit
    ..registerLazySingleton<AppThemeCubit>(
      () => AppThemeCubit(
        prefs: serviceLocator<SharedPreferences>(),
      ),
    )
    //4. league cubit
    ..registerLazySingleton(
      () => AppLeagueCubit(
        getUserLeagues: serviceLocator(),
      ),
    )
    //5. connection checker
    ..registerFactory<ConnectionChecker>(
      () => ConnectionCheckerImpl(
        serviceLocator(),
      ),
    );
}

void _initAuth() {
  serviceLocator
    //datasource
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(supabaseClient: serviceLocator()),
    )
    //repository
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        authRemoteDataSource: serviceLocator(),
        connectionChecker: serviceLocator(),
      ),
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
    ..registerFactory<LeagueLocalDataSource>(
      () => LeagueLocalDataSourceImpl(
        leaguesBox: serviceLocator<Box<Map<dynamic, dynamic>>>(
            instanceName: 'leagues_box'),
        rulesBox: serviceLocator<Box<Map<dynamic, dynamic>>>(
            instanceName: 'rules_box'),
      ),
    )

    // repository
    ..registerFactory<LeagueRepository>(
      () => LeagueRepositoryImpl(
        remoteDataSource: serviceLocator(),
        localDataSource: serviceLocator(),
        connectionChecker: serviceLocator(),
      ),
    )

    // use cases
    ..registerFactory(() => CreateLeague(leagueRepository: serviceLocator()))
    ..registerFactory(() => GetLeague(leagueRepository: serviceLocator()))
    ..registerFactory(() => GetUserLeagues(leagueRepository: serviceLocator()))
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
        getUserLeagues: serviceLocator(),
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

void _initDashboard() {
  serviceLocator
    // data sources
    ..registerFactory<DashboardRemoteDataSource>(
      () => DashboardRemoteDataSourceImpl(
        appLeagueCubit: serviceLocator(),
      ),
    )
    // repository
    ..registerFactory<DashboardRepository>(
      () => DashboardRepositoryImpl(
        dashboardRemoteDataSource: serviceLocator(),
      ),
    )

    // use case
    ..registerFactory<GetDashboardData>(
      () => GetDashboardData(serviceLocator<DashboardRepository>()),
    )

    // bloc
    ..registerFactory<DashboardBloc>(
      () => DashboardBloc(
        getDashboardData: serviceLocator<GetDashboardData>(),
      ),
    );
}
