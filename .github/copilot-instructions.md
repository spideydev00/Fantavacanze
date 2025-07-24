# Fantavacanze - AI Assistant Instructions

## Project Overview
Fantavacanze is a competitive social gaming Flutter app using **Clean Architecture** with Supabase backend, Firebase messaging, and offline-first caching. The app enables users to create/join leagues, complete daily challenges, and play real-time multiplayer games.

## Architecture & Core Patterns

### Clean Architecture Structure
- **Data Layer**: `lib/features/[feature]/data/` - models, repositories, datasources
- **Domain Layer**: `lib/features/[feature]/domain/` - entities, use cases, repository interfaces  
- **Presentation Layer**: `lib/features/[feature]/presentation/` - UI, BLoC, pages

### Key Dependencies & Patterns
- **State Management**: `flutter_bloc` with global cubits in `lib/core/cubits/`
- **Dependency Injection**: `get_it` service locator pattern in `lib/init_dependencies/`
- **Functional Programming**: `fpdart` for `Either<Failure, Success>` return types
- **Local Storage**: `hive` boxes for offline-first caching strategy
- **Network**: `internet_connection_checker_plus` to determine cache vs remote data

### Use Case Pattern
All business logic follows the UseCase pattern:
```dart
abstract interface class Usecase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}
```

## Critical Development Workflows

### Dependency Registration
All dependencies must be registered in `lib/init_dependencies/init_dependencies.main.dart`:
1. DataSources (remote/local) as factories
2. Repositories as factories  
3. Use cases as factories
4. BLoCs as factories
5. Global cubits as singletons

### Adding New Features
1. Create feature folder structure under `lib/features/[feature_name]/`
2. Define entities in `domain/entities/`
3. Create repository interface in `domain/repository/`
4. Implement data models extending entities in `data/models/`
5. Implement remote/local datasources in `data/datasources/`
6. Implement repository in `data/repository/`
7. Create use cases in `domain/use_cases/`
8. Register all dependencies in `init_dependencies.main.dart`
9. Create BLoC in `presentation/bloc/`
10. Build UI in `presentation/pages/`

### Caching Strategy
All data operations follow offline-first pattern:
- Check local cache first via `LeagueLocalDataSource` 
- If network available and cache empty/stale, fetch from remote
- Always cache successful remote responses
- Use `ConnectionChecker` to determine data source

**Daily Challenges Cache Logic**:
```dart
// In league_repository_impl.dart
getDailyChallenges() {
  // 1. Try cache first
  final cached = await localDataSource.getCachedDailyChallenges();
  
  // 2. If cache needs refresh, call remote
  if (needsRefresh) {
    final remote = await remoteDataSource.getDailyChallenges();
    await localDataSource.cacheDailyChallenges(remote);
  }
  
  return cached;
}
```

## Feature Deep Dive

### Auth Feature (`lib/features/auth/`)
Complete authentication system following Clean Architecture:

**Data Layer**: 
- `AuthRemoteDataSource` handles Supabase OAuth (Google/Apple) and email/password
- `UserModel` extends domain `User` entity with serialization methods
- `AuthRepositoryImpl` uses `ConnectionChecker` for offline/online handling

**Domain Layer**:
- Pure `User` entity without serialization logic
- `AuthRepository` interface defines contract
- Individual use cases like `GetCurrentUser` implement `Usecase<Success, Params>`

**Presentation Layer**:
- `AuthBloc` manages authentication state with events/states pattern
- UI theming via `context_extension.dart`, `colors_extension.dart`, `sizes.dart`
- Global state sync: `_emitAuthSuccess()` updates `AppUserCubit` for app-wide user state

**Initialization Flow**:
```dart
// main.dart startup
Future<void> _initializeApp() async {
  await context.read<AppUserCubit>().getCurrentUser();
}
```

### League Feature (`lib/features/league/`)
Core feature managing competitive leagues with complex domain models:

**Key Models & Relationships**:
- `LeagueModel`: Central entity containing all other objects, created by admin
- `ParticipantModel`: Base class for:
  - `IndividualParticipantModel`: Solo competitors  
  - `TeamParticipantModel`: Groups with `SimpleParticipantModel` members + captain
- `EventModel`: Scoring objectives based on rules or manual admin input
- `RuleModel`: League-specific scoring rules set during creation
- `MemoryModel`: Photo memories in `memories_page.dart`
- `NoteModel`: Personal reminders cached locally via Hive

**Daily Challenges System**:
Complex workflow involving multiple components:

1. **Generation**: Daily at 7:00 AM, `user_daily_challenges` table reset
   - 6 challenges per user (3 primary + 3 backup)
   - Premium users see all, free users see 1
   - Generated on-demand via RPC `get_daily_challenges`

2. **Completion Flow**:
   ```dart
   markChallengeAsCompleted() {
     if (user.isAdmin) {
       // Direct event creation
     } else {
       // Send notification to admins for approval
       // Set is_pending_approval = true
     }
   }
   ```

3. **Admin Approval System**:
   - Non-admin completions trigger `sendChallengeNotification`
   - Supabase webhook calls `daily-challenge-notification/index.ts`
   - FCM pushes to all league admins
   - Admins can `approveDailyChallenge` or `rejectDailyChallenge`

4. **Refresh Mechanism**:
   - Each challenge can be refreshed once (swapped with backup)
   - `updateChallengeRefreshStatus` manages state transitions

**Navigation Architecture**:
```dart
// Dashboard.dart - App shell with navigation
BlocBuilder<AppNavigationCubit, int>(
  builder: (context, selectedIndex) {
    final navItems = hasLeagues ? participantNavbarItems : nonParticipantNavbarItems;
    // Dynamic navigation based on league membership
  }
)
```

### Games Feature (`lib/features/games/`)
Multiplayer real-time gaming system with lobby management and three distinct games:

**Architecture Overview**:
- **Lobby System**: Central `LobbyBloc` manages session creation, joining, and player management
- **Game Sessions**: Each game has dedicated BLoC for game-specific logic and real-time state
- **Real-time Communication**: Supabase realtime for live updates between players

**Core Models**:
- `GameSession`: Central entity with `inviteCode`, `adminId`, `gameType`, `status`, and `gameState`
- `GamePlayer`: Player entity with scoring, abilities, and game-specific properties
- `GameType`: Enum supporting `truthOrDare`, `wordBomb`, `neverHaveIEver`
- `GameStatus`: Session states (`waiting`, `inProgress`, `paused`, `finished`)

**Game Types**:

1. **Truth or Dare (`TruthOrDareBloc`)**:
   - Card-based game with `TruthOrDareQuestion` entities
   - Admin controls question flow and player turn management
   - Success/failure tracking for scoring

2. **Word Bomb (`WordBombBloc`)**:
   - Complex timer-based word game with strategic actions
   - Features: pause/resume, ghost protocol, buy time, category changes
   - Real-time timer synchronization across players
   - Premium trial system via `SetWordBombTrialStatus`

3. **Never Have I Ever (`NeverHaveIEverBloc`)**:
   - Question-based social game
   - Tracks asked questions to avoid repetition
   - Admin-controlled question progression

**Lobby Management**:
```dart
// LobbyBloc handles session lifecycle
CreateSessionRequested -> creates game with invite code
JoinSessionRequested -> joins via invite code  
StartGameRequested -> transitions to inProgress status
KillSessionRequested -> admin terminates session
```

**Real-time Synchronization**:
- `StreamGameSession`: Live session state updates
- `StreamLobbyPlayers`: Real-time player list changes
- Admin controls: remove players, edit names, start/end games
- Automatic cleanup when players disconnect

**Premium Integration**:
- Word Bomb requires premium or trial access
- AdMob integration for free access sessions
- RevenueCat subscription validation

### Core Global State (`lib/core/cubits/`)
Four singleton cubits manage app-wide state:

1. **`AppUserCubit`**: Current user authentication state
2. **`AppLeagueCubit`**: User's league memberships, loaded after auth
3. **`AppNavigationCubit`**: Bottom navigation index management  
4. **`AppThemeCubit`**: Dark/light theme with SharedPreferences persistence

## Key Integration Points

### Authentication Flow
- Supabase Auth handles OAuth (Google/Apple) and email/password
- User state managed by `AppUserCubit` singleton
- FCM token automatically synced on auth state changes
- RevenueCat integration for premium subscriptions

### Real-time Features
- **Notifications**: Firebase FCM + Supabase realtime subscriptions
- **Games**: Supabase realtime for multiplayer lobby/game sessions with live player updates
- **Daily Challenges**: Server-side functions trigger push notifications
- **Game Synchronization**: Real-time state updates for timers, turns, and player actions

### Data Synchronization
- **Hive Boxes**: `leaguesBox`, `rulesBox`, `notesBox`, `challengesBox`, `notificationsBox`
- **Cache Management**: Automatic cleanup of old notifications (max 100 cached)
- **Offline Support**: All core features work offline with cached data

## Project-Specific Conventions

### UserModel Structure
```dart
const UserModel({
  required super.id,
  required super.email,
  required super.name,
  super.isPremium = false,
  required super.isOnboarded,
  required super.isAdult,
  required super.isTermsAccepted,
});
```

### Connection Checker Pattern
All repositories use consistent offline/online handling:
```dart
abstract interface class ConnectionChecker {
  Future<bool> get isConnected;
}

class ConnectionCheckerImpl implements ConnectionChecker {
  final InternetConnection internetConnection;
  
  @override
  Future<bool> get isConnected async =>
    await internetConnection.hasInternetAccess;
}
```

### Error Handling
- All repository methods return `Either<Failure, Success>`
- Remote datasources throw `ServerException` 
- Local datasources throw `CacheException`
- Use `_tryDatabaseOperation()` wrapper for consistent error handling

### BLoC Event Naming
- `Get[Entity]Event` for data fetching
- `[Action][Entity]Event` for mutations (e.g., `CreateLeagueEvent`)
- State classes follow `[Entity]Loading/Loaded/Error` pattern

### File Organization
- Models use `.fromJson()/.toJson()` for Supabase serialization
- Entities are pure domain objects without serialization
- Use `part` files for large dependency injection configurations

## Essential Commands & Setup

### Development
```bash
# Generate Hive adapters
flutter packages pub run build_runner build

# Run with specific flavor/platform
flutter run --debug
flutter run --release

# Get Android signing keys (for releases)
./gradlew signingReport
```

### Key Secrets (in `lib/core/secrets/app_secrets.dart`)
- Supabase URL/Key for database operations
- RevenueCat API keys for subscription management  
- AdMob IDs for monetization
- Firebase/Google OAuth client IDs

## Common Gotchas

1. **Service Locator**: Always register dependencies before accessing with `serviceLocator<T>()`
2. **Hive Initialization**: Ensure `_initializeHive()` completes before using boxes
3. **BLoC Dependencies**: Cubits are singletons, BLoCs are factories for proper lifecycle
4. **Firebase Setup**: Both Firebase AND Supabase are used - Firebase for FCM, Supabase for data
5. **Connection Handling**: Always check `connectionChecker.isConnected` before remote operations
6. **Italian Localization**: UI text and error messages are in Italian

Focus on maintaining the established patterns rather than introducing new approaches. The codebase prioritizes consistency and follows proven Clean Architecture principles throughout.
