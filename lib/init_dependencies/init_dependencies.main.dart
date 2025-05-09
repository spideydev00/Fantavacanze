part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  try {
    final supabase = await Supabase.initialize(
      anonKey: AppSecrets.supabaseKey,
      url: AppSecrets.supabaseUrl,
    );

    serviceLocator.registerLazySingleton(() => supabase.client);

    // Initialize Hive
    final dir = await getApplicationDocumentsDirectory();
    Hive.defaultDirectory = dir.path;

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

    // Initialize SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    serviceLocator.registerSingleton<SharedPreferences>(sharedPreferences);

    _initAuth();
    _initLeague();

    // Register UUID generator
    serviceLocator.registerLazySingleton(() => const Uuid());

    // core cubits
    serviceLocator
      //1. user cubit
      ..registerLazySingleton(
        () => AppUserCubit(
          getCurrentUser: serviceLocator(),
          signOut: serviceLocator(),
        ),
      )
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
      //4. league cubit - now with SharedPreferences
      ..registerLazySingleton(
        () => AppLeagueCubit(
          getUserLeagues: serviceLocator(),
          prefs: serviceLocator<SharedPreferences>(),
        ),
      )
      //5. connection checker
      ..registerFactory<ConnectionChecker>(
        () => ConnectionCheckerImpl(
          serviceLocator(),
        ),
      );
    debugPrint("Dependencies initialized successfully with get_it");
  } catch (e) {
    debugPrint("Error initializing dependencies: $e");
    // Rethrow to be caught by main()
    rethrow;
  }
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
    ..registerFactory(
      () => SignOut(authRepository: serviceLocator()),
    )
    ..registerFactory(
      () => ChangeIsOnboardedValue(authRepository: serviceLocator()),
    )
    //bloc
    ..registerLazySingleton(
      () => AuthBloc(
        googleSignIn: serviceLocator(),
        appleSignIn: serviceLocator(),
        appUserCubit: serviceLocator(),
        emailSignIn: serviceLocator(),
        emailSignUp: serviceLocator(),
        signOut: serviceLocator(),
        appLeagueCubit: serviceLocator(),
        changeIsOnboardedValue: serviceLocator(),
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
    ..registerFactory(
      () => CreateLeague(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => GetLeague(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => GetUserLeagues(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => JoinLeague(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => ExitLeague(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => UpdateTeamName(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => AddEvent(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => AddMemory(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => RemoveMemory(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => GetRules(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => UpdateRule(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => AddRule(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => DeleteRule(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => GetUsersDetails(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => RemoveTeamParticipants(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => SearchLeague(leagueRepository: serviceLocator()),
    )

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
        removeMemory: serviceLocator(),
        getRules: serviceLocator(),
        updateRule: serviceLocator(),
        addRule: serviceLocator(),
        deleteRule: serviceLocator(),
        appUserCubit: serviceLocator(),
        appLeagueCubit: serviceLocator(),
        getUsersDetails: serviceLocator(),
        removeTeamParticipants: serviceLocator(),
        searchLeague: serviceLocator(),
      ),
    );
}
