part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  try {
    // SUPABASE
    final supabase = await Supabase.initialize(
      anonKey: AppSecrets.supabaseKey,
      url: AppSecrets.supabaseUrl,
    );

    serviceLocator.registerLazySingleton(() => supabase.client);

    // FIREBASE
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    serviceLocator.registerLazySingleton<FirebaseMessaging>(
      () => FirebaseMessaging.instance,
    );

    // HIVE
    await _initializeHive();

    serviceLocator.registerFactory(
      () => InternetConnection(),
    );

    // Initialize SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    serviceLocator.registerSingleton<SharedPreferences>(sharedPreferences);

    // Register InAppReview instance
    serviceLocator.registerLazySingleton<InAppReview>(
      () => InAppReview.instance,
    );

    // Register ReviewService as a singleton
    serviceLocator.registerLazySingleton<ReviewService>(
      () => ReviewService(
        preferences: serviceLocator<SharedPreferences>(),
        inAppReview: serviceLocator<InAppReview>(),
      ),
    );

    _initAuth();
    _initLeague();
    _initGames();

    // Register UUID generator
    serviceLocator.registerLazySingleton(() => const Uuid());

    // Register InAppPurchase
    serviceLocator.registerLazySingleton<InAppPurchase>(
      () => InAppPurchase.instance,
    );

    // core cubits
    serviceLocator
      //1. user cubit
      ..registerLazySingleton(
        () => AppUserCubit(
          getCurrentUser: serviceLocator(),
          signOut: serviceLocator(),
          updateDisplayName: serviceLocator(),
          updatePassword: serviceLocator(),
          deleteAccount: serviceLocator(),
          updateGender: serviceLocator(),
          removeConsents: serviceLocator(),
          becomePremium: serviceLocator(),
          markReviewLeft: serviceLocator(),
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
          // clearLocalCache: serviceLocator(),
          prefs: serviceLocator<SharedPreferences>(),
          appUserCubit: serviceLocator(),
          clearLocalCache: serviceLocator<ClearLocalCache>(),
        ),
      )
      //5. notification count cubit
      ..registerLazySingleton(
        () => NotificationCountCubit(),
      )
      //6. connection checker
      ..registerFactory<ConnectionChecker>(
        () => ConnectionCheckerImpl(
          serviceLocator(),
        ),
      );

    await _initRevenueCat();
    _initSubscription();

    debugPrint("⬆ Dipendenze inizializzate correttamente con get_it");
  } catch (e) {
    debugPrint("Errore di inizializzazione delle dipendenze: $e");
    // Rethrow to be caught by main()
    rethrow;
  }
}

Future<void> _initRevenueCat() async {
  try {
    // Initialize RevenueCat with your API keys
    await Purchases.setLogLevel(LogLevel.debug);

    // Get user ID if available
    String? appUserId;

    final appUserState = serviceLocator<AppUserCubit>().state;

    if (appUserState is AppUserIsLoggedIn) {
      appUserId = appUserState.user.id;
    }

    // Use the appropriate API key based on platform
    if (Platform.isAndroid) {
      await Purchases.configure(
          PurchasesConfiguration(AppSecrets.revenueCatAndroidApiKey)
            ..appUserID = appUserId);
    } else if (Platform.isIOS) {
      await Purchases.configure(
          PurchasesConfiguration(AppSecrets.revenueCatIosApiKey)
            ..appUserID = appUserId);
    }

    debugPrint("✅ RevenueCat initialized successfully");
  } catch (e) {
    debugPrint("Error initializing RevenueCat: $e");
    rethrow;
  }
}

// Add this function to register subscription dependencies
void _initSubscription() {
  // DataSources
  serviceLocator.registerLazySingleton<SubscriptionRemoteDataSource>(
    () => SubscriptionRemoteDataSourceImpl(
      supabaseClient: serviceLocator(),
    ),
  );

  // Repositories
  serviceLocator.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(
      remoteDataSource: serviceLocator(),
      connectionChecker: serviceLocator(),
    ),
  );

  // Use cases
  serviceLocator.registerLazySingleton(
    () => GetProducts(repository: serviceLocator()),
  );

  serviceLocator.registerLazySingleton(
    () => PurchaseProduct(repository: serviceLocator()),
  );

  serviceLocator.registerLazySingleton(
    () => RestorePurchases(repository: serviceLocator()),
  );

  serviceLocator.registerLazySingleton(
    () => CheckPremiumStatus(repository: serviceLocator()),
  );

  // Bloc
  serviceLocator.registerFactory(
    () => SubscriptionBloc(
      getProducts: serviceLocator(),
      purchaseProduct: serviceLocator(),
      restorePurchases: serviceLocator(),
      checkPremiumStatus: serviceLocator(),
      appUserCubit: serviceLocator(),
    ),
  );
}

/// Initialize Hive with proper error handling
Future<void> _initializeHive() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);

    // Register adapters with error handling
    _registerHiveAdapters();

    // Open boxes with proper error handling
    await _openHiveBoxes();

    debugPrint("✅ Hive inizializzato correttamente");
  } catch (e) {
    debugPrint("Errore nell'inizializzazione di Hive: $e");
    rethrow;
  }
}

/// Register all Hive adapters
void _registerHiveAdapters() {
  Hive.registerAdapter(DailyChallengeModelAdapter());
  Hive.registerAdapter(EventModelAdapter());
  Hive.registerAdapter(IndividualParticipantModelAdapter());
  Hive.registerAdapter(LeagueModelAdapter());
  Hive.registerAdapter(MemoryModelAdapter());
  Hive.registerAdapter(NoteModelAdapter());
  Hive.registerAdapter(DailyChallengeNotificationModelAdapter());
  Hive.registerAdapter(NotificationModelAdapter());
  Hive.registerAdapter(RuleModelAdapter());
  Hive.registerAdapter(SimpleParticipantModelAdapter());
  Hive.registerAdapter(TeamParticipantModelAdapter());
  Hive.registerAdapter(RuleTypeAdapter());

  debugPrint("🔌 Tutti gli adapter di Hive registrati correttamente");
}

/// Open all Hive boxes
Future<void> _openHiveBoxes() async {
  try {
    // Open boxes one by one with error handling
    final leaguesBox = await Hive.openBox<LeagueModel>('leagues_box');

    final rulesBox = await Hive.openBox<List<RuleModel>>('rules_box');

    final notesBox = await Hive.openBox<NoteModel>('notes_box');

    final challengesBox =
        await Hive.openBox<DailyChallengeModel>('challenges_box');

    await challengesBox.clear();

    final notificationsBox =
        await Hive.openBox<NotificationModel>('notifications_box');

    await notificationsBox.clear();

    // Register boxes in GetIt
    serviceLocator
      ..registerLazySingleton(() => leaguesBox)
      ..registerLazySingleton(() => rulesBox)
      ..registerLazySingleton(() => notesBox)
      ..registerLazySingleton(() => challengesBox)
      ..registerLazySingleton(() => notificationsBox);

    debugPrint("📦 Tutti i box di Hive aperti correttamente");
  } catch (e) {
    debugPrint("Errore nell'apertura dei box di Hive: $e");
    rethrow;
  }
}

void _initAuth() {
  serviceLocator
    //datasource
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        supabaseClient: serviceLocator(),
      ),
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
    ..registerFactory(
      () => DeleteAccount(authRepository: serviceLocator()),
    )
    ..registerFactory(
      () => UpdateDisplayName(authRepository: serviceLocator()),
    )
    ..registerFactory(
      () => UpdatePassword(authRepository: serviceLocator()),
    )
    ..registerFactory(
      () => RemoveConsents(authRepository: serviceLocator()),
    )
    ..registerFactory(
      () => UpdateConsents(authRepository: serviceLocator()),
    )
    ..registerFactory(
      () => UpdateGender(authRepository: serviceLocator()),
    )
    ..registerFactory(
      () => BecomePremium(authRepository: serviceLocator()),
    )
    ..registerFactory(
      () => MarkReviewLeft(authRepository: serviceLocator()),
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
        updateConsents: serviceLocator(),
        updateGender: serviceLocator(),
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
        leaguesBox: serviceLocator(),
        rulesBox: serviceLocator(),
        notesBox: serviceLocator(),
        challengesBox: serviceLocator(),
        notificationsBox: serviceLocator(),
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
      () => UpdateRule(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => AddRule(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => DeleteRule(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => RemoveTeamParticipants(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => SearchLeague(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => GetNotes(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => SaveNote(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => DeleteNote(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => UploadImage(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => UploadTeamLogo(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => UpdateTeamLogo(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => AddAdministrators(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => UpdateLeagueInfo(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => RemoveParticipants(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => DeleteLeague(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => GetDailyChallenges(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => MarkChallengeAsCompleted(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => UpdateChallengeRefreshStatus(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => ClearLocalCache(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => ListenToNotification(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => ApproveDailyChallenge(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => DeleteNotification(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => GetNotifications(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => MarkNotificationAsRead(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => RejectDailyChallenge(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => SendChallengeNotification(leagueRepository: serviceLocator()),
    )
    ..registerFactory(
      () => UnlockDailyChallenge(leagueRepository: serviceLocator()),
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
        updateRule: serviceLocator(),
        addRule: serviceLocator(),
        deleteRule: serviceLocator(),
        appUserCubit: serviceLocator(),
        appLeagueCubit: serviceLocator(),
        notificationCountCubit: serviceLocator(),
        removeTeamParticipants: serviceLocator(),
        searchLeague: serviceLocator(),
        getNotes: serviceLocator(),
        saveNote: serviceLocator(),
        deleteNote: serviceLocator(),
        uploadImage: serviceLocator(),
        uploadTeamLogo: serviceLocator(),
        updateTeamLogo: serviceLocator(),
        addAdministrators: serviceLocator(),
        removeParticipants: serviceLocator(),
        updateLeagueInfo: serviceLocator(),
        deleteLeague: serviceLocator(),
        getDailyChallenges: serviceLocator(),
        unlockDailyChallenge: serviceLocator(),
        markChallengeAsCompleted: serviceLocator(),
        updateChallengeRefreshStatus: serviceLocator(),
        listenToNotification: serviceLocator(),
        getNotifications: serviceLocator(),
        markNotificationAsRead: serviceLocator(),
        deleteNotification: serviceLocator(),
        approveDailyChallenge: serviceLocator(),
        rejectDailyChallenge: serviceLocator(),
      ),
    );
}

// Add this new function
void _initGames() {
  // DataSources
  serviceLocator
    ..registerFactory<GameRemoteDataSource>(
        () => GameRemoteDataSourceImpl(supabaseClient: serviceLocator()))
    ..registerFactory<TruthOrDareRemoteDataSource>(
        () => TruthOrDareRemoteDataSourceImpl(supabaseClient: serviceLocator()))
    ..registerFactory<WordBombRemoteDataSource>(
        () => WordBombRemoteDataSourceImpl(supabaseClient: serviceLocator()))
    ..registerFactory<NeverHaveIEverRemoteDataSource>(() =>
        NeverHaveIEverRemoteDataSourceImpl(supabaseClient: serviceLocator()));

  // Repositories
  serviceLocator
    ..registerFactory<GameRepository>(
      () => GameRepositoryImpl(
        remoteDataSource: serviceLocator(),
        connectionChecker: serviceLocator(),
      ),
    )
    ..registerFactory<TruthOrDareRepository>(
      () => TruthOrDareRepositoryImpl(
        remoteDataSource: serviceLocator(),
        connectionChecker: serviceLocator(),
      ),
    )
    ..registerFactory<WordBombRepository>(
      () => WordBombRepositoryImpl(
        remoteDataSource: serviceLocator(),
        connectionChecker: serviceLocator(),
      ),
    )
    ..registerFactory<NeverHaveIEverRepository>(
      () => NeverHaveIEverRepositoryImpl(
        remoteDataSource: serviceLocator(),
        connectionChecker: serviceLocator(),
      ),
    );

  // UseCases - Generic Game
  serviceLocator
    ..registerFactory(() => CreateGameSession(serviceLocator()))
    ..registerFactory(() => JoinGameSession(serviceLocator()))
    ..registerFactory(() => LeaveGameSession(serviceLocator()))
    ..registerFactory(() => StreamGameSession(serviceLocator()))
    ..registerFactory(() => StreamLobbyPlayers(serviceLocator()))
    ..registerFactory(() => UpdateGameState(serviceLocator()))
    ..registerFactory(() => UpdateGamePlayer(serviceLocator()))
    ..registerFactory(() => KillGameSession(serviceLocator()))
    ..registerFactory(() => UpdateGamePlayerNameInLobby(serviceLocator()))
    ..registerFactory(() => RemoveGamePlayerFromLobby(serviceLocator()));

  serviceLocator
    // UseCases - Truth Or Dare
    ..registerFactory(
      () => GetTruthOrDareCards(
        serviceLocator(),
      ),
    )
    // UseCases - Word Bomb (add these new ones)
    ..registerFactory(
      () => SetWordBombTrialStatus(
        serviceLocator(),
      ),
    )
    // UseCases - Never Have I Ever
    ..registerFactory(
      () => GetNeverHaveIEverCards(
        serviceLocator(),
      ),
    );

  // BLoCs
  serviceLocator
    ..registerFactory(() => LobbyBloc(
          createGameSession: serviceLocator(),
          joinGameSession: serviceLocator(),
          leaveGameSession: serviceLocator(),
          killGameSession: serviceLocator(),
          streamGameSession: serviceLocator(),
          streamLobbyPlayers: serviceLocator(),
          updateGameState: serviceLocator(),
          appUserCubit: serviceLocator(),
          updateGamePlayerNameInLobby: serviceLocator(),
          removeGamePlayerFromLobby: serviceLocator(),
        ))
    // Game-specific BLoCs should be singletons to maintain state during the game session.
    ..registerFactory(() => TruthOrDareBloc(
          getTruthOrDareCards: serviceLocator(),
          updateGameState: serviceLocator(),
          streamGameSession: serviceLocator(),
          streamLobbyPlayers: serviceLocator(),
          appUserCubit: serviceLocator(),
        ))
    ..registerFactory(
      () => WordBombBloc(
        updateGameState: serviceLocator(),
        updateGamePlayer: serviceLocator(),
        streamGameSession: serviceLocator(),
        streamLobbyPlayers: serviceLocator(),
        appUserCubit: serviceLocator(),
        setWordBombTrialStatus: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => NeverHaveIEverBloc(
        getNeverHaveIEverCards: serviceLocator(),
        streamGameSession: serviceLocator(),
        streamLobbyPlayers: serviceLocator(),
        updateGameState: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}
