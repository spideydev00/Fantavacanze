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
- **Dependency Injection**: `get_it` service locator pattern in `lib/init_dependencies/init_dependencies.main.dart`
- **Functional Programming**: `fpdart` for `Either<Failure, Success>` return types
- **Local Storage**: `hive` boxes for offline-first caching strategy
- **Network**: `internet_connection_checker_plus` to determine cache vs remote data

### Use Case Pattern

All business logic follows the UseCase pattern defined in `lib/core/use-case/usecase.dart`:

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

All data operations follow offline-first pattern using `lib/core/network/connection_checker.dart`:

- Check local cache first via `LocalDataSource`
- If network available and cache empty/stale, fetch from remote
- Always cache successful remote responses
- Use `ConnectionChecker` to determine data source

**Daily Challenges Cache Logic**:

```dart
// In lib/features/league/data/repository/league_repository_impl.dart
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

- `lib/features/auth/data/datasources/auth_remote_data_source.dart` handles Supabase OAuth (Google/Apple) and email/password
- `lib/features/auth/data/models/user_model.dart` extends domain `User` entity with serialization methods
- `lib/features/auth/data/repository/auth_repository_impl.dart` uses `ConnectionChecker` for offline/online handling

**Domain Layer**:

- Pure `lib/features/auth/domain/entities/user.dart` entity without serialization logic
- `lib/features/auth/domain/repository/auth_repository.dart` interface defines contract
- Individual use cases in `lib/features/auth/domain/use-cases/` like `get_current_user.dart` implement `Usecase<Success, Params>`

**Presentation Layer**:

- `lib/features/auth/presentation/bloc/auth_bloc.dart` manages authentication state with events/states pattern
- UI theming via `lib/core/extensions/context_extension.dart`, `lib/core/extensions/colors_extension.dart`, `lib/core/theme/sizes.dart`
- Global state sync: `_emitAuthSuccess()` updates `AppUserCubit` for app-wide user state

**Key Pages**:

- `lib/features/auth/presentation/pages/onboarding.dart` - Initial app onboarding
- `lib/features/auth/presentation/pages/social_login.dart` - OAuth authentication
- `lib/features/auth/presentation/pages/standard_login.dart` - Email/password login
- `lib/features/auth/presentation/pages/signup.dart` - Account creation

**Initialization Flow**:

```dart
// lib/main.dart startup
Future<void> _initializeApp() async {
  await context.read<AppUserCubit>().getCurrentUser();
}
```

### League Feature (`lib/features/league/`)

Core feature managing competitive leagues with complex domain models:

**Key Models & Relationships**:

- `lib/features/league/data/models/league_model/league_model.dart`: Central entity containing all other objects, created by admin
- `lib/features/league/data/models/participant_model/participant_model.dart`: Base class for:
  - `lib/features/league/data/models/individual_participant_model/individual_participant_model.dart`: Solo competitors
  - `lib/features/league/data/models/team_participant_model/team_participant_model.dart`: Groups with `SimpleParticipantModel` members + captain
- `lib/features/league/data/models/event_model/event_model.dart`: Scoring objectives based on rules or manual admin input
- `lib/features/league/data/models/rule_model/rule_model.dart`: League-specific scoring rules set during creation
- `lib/features/league/data/models/memory_model/memory_model.dart`: Photo memories in `lib/features/league/presentation/pages/navigation/memories/memories_page.dart`
- `lib/features/league/data/models/note_model/note_model.dart`: Personal reminders cached locally via Hive

**Daily Challenges System**:
Complex workflow involving multiple components in `lib/features/league/domain/use_cases/remote/daily_challenges/`:

1. **Generation**: Daily at 7:00 AM, `user_daily_challenges` table reset
   - 6 challenges per user (3 primary + 3 backup)
   - Premium users see all, free users see 1
   - Generated on-demand via RPC `get_daily_challenges`

2. **Completion Flow**:

   ```dart
   // lib/features/league/domain/use_cases/remote/daily_challenges/mark_challenge_as_completed.dart
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
   - Non-admin completions trigger `lib/features/league/domain/use_cases/remote/notifications/send_challenge_notification.dart`
   - Supabase webhook calls `supabase/functions/daily-challenge-notification/index.ts`
   - FCM pushes to all league admins
   - Admins can use `lib/features/league/domain/use_cases/remote/daily_challenges/approve_daily_challenge.dart` or `reject_daily_challenge.dart`

4. **Refresh Mechanism**:
   - Each challenge can be refreshed once (swapped with backup)
   - `lib/features/league/domain/use_cases/remote/daily_challenges/update_challenge_refresh_status.dart` manages state transitions

**Key Pages**:

- `lib/features/league/presentation/pages/dashboard/sections/dashboard.dart` - App shell with navigation
- `lib/features/league/presentation/pages/navigation/homepage/home.dart` - Main dashboard
- `lib/features/league/presentation/pages/navigation/create_league/create_league_page.dart` - League creation
- `lib/features/league/presentation/pages/navigation/leaderboard/leaderboard_page.dart` - Standings
- `lib/features/league/presentation/pages/navigation/admin/admin_page.dart` - Admin controls

**Navigation Architecture**:

```dart
// lib/features/league/presentation/pages/dashboard/sections/dashboard.dart - App shell with navigation
BlocBuilder<AppNavigationCubit, int>(
  builder: (context, selectedIndex) {
    final navItems = hasLeagues ? participantNavbarItems : nonParticipantNavbarItems;
    // Dynamic navigation based on league membership
  }
)
```

### Core Global State (`lib/core/cubits/`)

Five singleton cubits manage app-wide state:

1. **`lib/core/cubits/app_user/app_user_cubit.dart`**: Current user authentication state
2. **`lib/core/cubits/app_league/app_league_cubit.dart`**: User's league memberships, loaded after auth
3. **`lib/core/cubits/app_navigation/app_navigation_cubit.dart`**: Bottom navigation index management
4. **`lib/core/cubits/app_theme/app_theme_cubit.dart`**: Dark/light theme with SharedPreferences persistence
5. **`lib/core/cubits/seasonal_event/seasonal_event_cubit.dart`**: Special seasonal events and promotions management

**Additional Utilities**:

- `lib/core/cubits/floating_button_animation/floating_button_animation_cubit.dart` - FAB animations
- `lib/core/cubits/notification_count/notification_count_cubit.dart` - Notification badge counts

### Seasonal Events System (`lib/core/cubits/seasonal_event/`)

Manages special events, promotions, and seasonal content:

**Core Service** (`lib/core/services/seasonal_event_service.dart`):

- Handles seasonal promotions and special events
- Integrates with app theming and content delivery
- Manages time-based event activation/deactivation

**Use Cases**:

- Holiday-themed UI modifications
- Special promotional content
- Time-limited features activation
- Seasonal rule sets for leagues

## Key Integration Points

### Authentication Flow

- Supabase Auth handles OAuth (Google/Apple) and email/password
- User state managed by `AppUserCubit` singleton
- FCM token automatically synced on auth state changes
- RevenueCat integration for premium subscriptions via `lib/features/league/domain/use_cases/remote/subscription/`

### Real-time Features

- **Notifications**: Firebase FCM + Supabase realtime subscriptions
- **Games**: Supabase realtime for multiplayer lobby/game sessions with live player updates
- **Daily Challenges**: Server-side functions trigger push notifications
- **Game Synchronization**: Real-time state updates for timers, turns, and player actions
- **Seasonal Events**: Time-based content delivery and feature activation

### Data Synchronization

- **Hive Boxes**: Used by `lib/features/league/data/datasources/local/local_data_source.dart`
  - `leaguesBox`, `rulesBox`, `notesBox`, `challengesBox`, `notificationsBox`
- **Cache Management**: Automatic cleanup of old notifications (max 100 cached)
- **Offline Support**: All core features work offline with cached data

### UI Components & Theming

- **Core Widgets**: `lib/core/widgets/` - Reusable UI components
- **Theme System**: `lib/core/theme/` - Colors, sizes, and theme definitions
- **Extensions**: `lib/core/extensions/` - Context and color extensions
- **Navigation**: `lib/core/constants/navigation_items.dart` - App navigation structure

### Error Handling & Utilities

- **Errors**: `lib/core/errors/` - Exception and failure handling
- **Utils**: `lib/core/utils/` - Helper functions for dates, media, routing, etc.
- **Services**: `lib/core/services/` - Ad management, GDPR, reviews

## Project-Specific Conventions

### UserModel Structure

Located in `lib/features/auth/data/models/user_model.dart`:

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

All repositories use consistent offline/online handling via `lib/core/network/connection_checker.dart`:

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

- All repository methods return `Either<Failure, Success>` using types from `lib/core/errors/`
- Remote datasources throw `ServerException`
- Local datasources throw `CacheException`
- Use `_tryDatabaseOperation()` wrapper for consistent error handling

### BLoC Event Naming

- `Get[Entity]Event` for data fetching
- `[Action][Entity]Event` for mutations (e.g., `CreateLeagueEvent`, `UpdateLeagueEvent`)
- State classes follow `[Entity]Loading/Loaded/Error` pattern

### File Organization

- Models use `.fromJson()/.toJson()` for Supabase serialization
- Entities are pure domain objects without serialization
- Use `part` files for large dependency injection configurations
- Constants organized by feature in `lib/core/constants/`

### SQL File Organization

Whenever you generate new SQL, place it in the matching `supabase/` folder
based on what it is:

- **Table schemas** (CREATE TABLE, enums, RLS policies on the table) →
  `supabase/schemas/` as the "target state" of that object.
- **RPC / PL/pgSQL functions** (CREATE OR REPLACE FUNCTION) →
  `supabase/db_functions/`.
- **Triggers** (CREATE TRIGGER) → `supabase/db_triggers/`.

If the SQL is **not** the declarative final shape but something that has to
run later against the live DB (data migrations, FK swaps, seeds, ALTER TABLE,
DROP TABLE, trigger attachments, etc.), place it under
`supabase/to-do/[descriptive_subfolder]/` with numeric prefixes
(`01_*.sql`, `02_*.sql`, ...) reflecting execution order. These scripts are
run manually on Supabase at the next deploy.

Conventions for `to-do/` scripts:

- Idempotent: use `CREATE ... IF NOT EXISTS`, `DROP ... IF EXISTS`,
  `ON CONFLICT DO ...`, `DO $$ ... EXCEPTION WHEN duplicate_object THEN null
  END $$;` for enums, etc., so they can be safely re-run.
- Each subfolder should contain a short `README.md` explaining the goal and
  the real execution order if the numeric prefix is misleading
  (dependencies sometimes force `01 → 02 → 04 → 03`).
- Italian comments, concise, no emoji, no accents — match the style of the
  files already in `supabase/`.

Note: `/supabase` is gitignored. These files live in the local repo but are
not versioned via Git; backup is handled separately.

## Common Gotchas

1. **Service Locator**: Always register dependencies before accessing with `serviceLocator<T>()`
2. **Hive Initialization**: Ensure `_initializeHive()` completes before using boxes
3. **BLoC Dependencies**: Cubits are singletons, BLoCs are factories for proper lifecycle
4. **Firebase Setup**: Both Firebase AND Supabase are used - Firebase for FCM, Supabase for data
5. **Connection Handling**: Always check `connectionChecker.isConnected` before remote operations
6. **Italian Localization**: UI text and error messages are in Italian
7. **Constants Organization**: Feature-specific constants are in `lib/core/constants/[feature]/`
8. **Model Generation**: Remember to run `build_runner` after modifying models with `.g.dart` files
9. **Seasonal Events**: Consider seasonal event state when displaying time-sensitive content

Focus on maintaining the established patterns rather than introducing new approaches. The codebase prioritizes consistency and follows proven Clean Architecture principles throughout.
