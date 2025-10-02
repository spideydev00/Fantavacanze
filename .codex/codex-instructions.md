# Fantavacanze - AI Assistant Instructions

## Project Overview
Fantavacanze is a competitive social gaming Flutter app using **Clean Architecture** with Supabase backend, Firebase messaging, and offline-first caching. The app enables users to create/join leagues, complete daily challenges, play real-time multiplayer games, and participate in temporary Fantaserata leagues.

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

### Fantaserata Feature (`lib/features/fantaserata/`)
Temporary daily competitive leagues that auto-destruct at 7:00 AM:

**Core Concept**:
- **Limited Duration**: Leagues automatically destroy every morning at 7:00 AM
- **Individual Only**: No teams, only individual participants compete
- **Simplified Structure**: Similar to leagues but streamlined for daily competition
- **Night-Specific Leagues**: Special league types based on `FsNightType` enum

**Database Structure**:
- **Single Table**: `fs_leagues` contains all data using JSONB for nested entities
- **Auto-Cleanup**: Scheduled deletion at 7:00 AM daily
- **RLS Policies**: Similar to leagues with `is_fs_league_member` function for individual participants only

**Key Entities** in `lib/features/fantaserata/domain/entities/`:
- `fs_league.dart`: Main entity with embedded participants, events, memories
- `fs_participant.dart`: Individual competitors only (no team structure)
- `fs_memory.dart`: Photo memories with media type detection
- `fs_notification.dart`: Event-based notifications extending base `Notification`
- `fs_rule.dart`: Scoring rules with bonus/malus types (`FsRuleType`)

**Models** in `lib/features/fantaserata/data/models/`:
- `league/fs_league_model.dart`: JSON serialization for main league entity
- `participant/fs_participant_model.dart`: Individual participant with scoring
- `rule/fs_rule_model.dart`: Fantaserata-specific rules with simplified structure

**Use Cases** in `lib/features/fantaserata/domain/use_cases/`:

**FS League Management**:
- `create_fs_league.dart`: Standard daily league creation
- `create_night_specific_fs_league.dart`: Special themed leagues (discoteca, bar, etc.)
- `join_fs_league.dart`: Standard league joining
- `join_night_specific_fs_league.dart`: Themed league joining
- `get_fs_league.dart`: Retrieve user's current league
- `exit_fs_league.dart`: Leave current league
- `delete_fs_league.dart`: Admin-only league deletion
- `clear_fs_cache.dart`: Clear local cached data
- `upload_winner_photo.dart`: Upload victory celebration photo
- `delete_winner_photo.dart`: Remove victory photo

**FS Rules Management**:
- `get_league_rules.dart`: Fetch league-specific rules
- `insert_rules_for_league_from_existing.dart`: Copy rules from existing league
- `set_fs_rule_as_completed.dart`: Mark rule as completed by participant
- `set_fs_rule_as_uncompleted.dart`: Undo rule completion
- `lock_fs_rule.dart`: Prevent further rule modifications
- `unlock_fs_rule.dart`: Allow rule modifications
- `refresh_fs_rule.dart`: Reset rule state

**Default Rules Configuration**:
- `lib/core/constants/fantaserata/simple_fs_rule.dart`: Base rule configurations for quick league setup
- Rules are simpler than main leagues - focused on bonus/malus scoring

**Presentation Architecture**:

**BLoCs**:
- `lib/features/fantaserata/presentation/bloc/fs_league_bloc/`: Main league state management
- `lib/features/fantaserata/presentation/bloc/fs_rules_bloc/`: Rules-specific state management

**Key Pages**:
- `lib/features/fantaserata/presentation/pages/fs_main_page.dart`: Entry point and league selection
- `lib/features/fantaserata/presentation/pages/fs_router_page.dart`: Navigation routing
- `lib/features/fantaserata/presentation/pages/navigation/fs_onboarding/fs_onboarding_screen.dart`: Feature introduction
- `lib/features/fantaserata/presentation/pages/navigation/create_fs_league/create_fs_league_page.dart`: League creation
- `lib/features/fantaserata/presentation/pages/navigation/fs_dashboard/fs_dashboard_page.dart`: Main participant view
- `lib/features/fantaserata/presentation/pages/navigation/fs_leaderboard/fs_leaderboard_page.dart`: Scoring standings
- `lib/features/fantaserata/presentation/pages/navigation/events/fs_events_page.dart`: Event history
- `lib/features/fantaserata/presentation/pages/navigation/manage_fs_league/manage_fs_league.dart`: Admin controls

**Widget Structure**:
- `lib/features/fantaserata/presentation/widgets/fs_dashboard/`: Dashboard components including objectives and navigation
- `lib/features/fantaserata/presentation/widgets/create_fs_league/`: League creation flow widgets
- `lib/features/fantaserata/presentation/widgets/fs_leaderboard/`: Leaderboard display components
- `lib/features/fantaserata/presentation/widgets/events/`: Event cards and information displays
- `lib/features/fantaserata/presentation/widgets/fs_onboarding/`: Onboarding content widgets
- `lib/features/fantaserata/presentation/widgets/manage_fs_league/`: Admin management widgets including winner photo handling

**Data Layer**:

**DataSources**:
- `lib/features/fantaserata/data/datasources/remote/fs_remote_data_source.dart`: Supabase integration for league operations
- `lib/features/fantaserata/data/datasources/remote/fs_rules_remote_data_source.dart`: Rules-specific remote operations
- `lib/features/fantaserata/data/datasources/local/fs_local_data_source.dart`: Hive box caching for offline support
- `lib/features/fantaserata/data/datasources/local/fs_rules_local_data_source.dart`: Local rules caching

**Repositories**:
- `lib/features/fantaserata/data/repository/fs_repository_impl.dart`: Main repository implementation with offline-first pattern
- `lib/features/fantaserata/data/repository/fs_rules_repository_impl.dart`: Rules repository with caching strategy

**Utilities**:
- `lib/features/fantaserata/data/utils/winner_photo_util.dart`: Helper functions for victory photo management

**Night-Specific Leagues**:
Fantaserata supports themed leagues based on venue type via `lib/core/entities/fs_league/fs_night_type.dart`:
- Different rule sets based on venue (discoteca, bar, casa, etc.)
- Customized UI themes and objectives
- Venue-appropriate default rules and challenges

**Integration Points**:
- Follows same Clean Architecture as leagues
- Uses offline-first caching strategy with `fsLeaguesBox` Hive box
- Real-time updates via Supabase subscriptions
- FCM notifications for events and admin actions
- Integration with `AppFsLeagueCubit` for global state management
- Navigation managed by `FsNavigationCubit` for section-specific routing

**Key Differences from Regular Leagues**:
1. **Simplified Structure**: No teams, only individual participants
2. **Auto-Destruction**: Leagues automatically deleted at 7:00 AM
3. **Streamlined Rules**: Simplified bonus/malus system
4. **Night Themes**: Venue-specific customization
5. **Single Table**: All data stored in one JSONB table vs. normalized structure
6. **Daily Reset**: Fresh competition every day
7. **Winner Photos**: Victory celebration feature unique to Fantaserata

### Core Global State (`lib/core/cubits/`)
Six singleton cubits manage app-wide state:

1. **`lib/core/cubits/app_user/app_user_cubit.dart`**: Current user authentication state
2. **`lib/core/cubits/app_league/app_league_cubit.dart`**: User's league memberships, loaded after auth
3. **`lib/core/cubits/app_navigation/app_navigation_cubit.dart`**: Bottom navigation index management  
4. **`lib/core/cubits/app_theme/app_theme_cubit.dart`**: Dark/light theme with SharedPreferences persistence
5. **`lib/core/cubits/app_fs_league/app_fs_league_cubit.dart`**: User's Fantaserata league membership state
6. **`lib/core/cubits/seasonal_event/seasonal_event_cubit.dart`**: Special seasonal events and promotions management

**Navigation Cubits**:
- `lib/core/cubits/fs_navigation/fs_navigation_cubit.dart` - Fantaserata section navigation index management

**Additional Utilities**:
- `lib/core/cubits/floating_button_animation/floating_button_animation_cubit.dart` - FAB animations
- `lib/core/cubits/notification_count/notification_count_cubit.dart` - Notification badge counts

### Fantaserata State Management (`lib/core/cubits/app_fs_league/`)
Manages user's participation in temporary daily Fantaserata leagues:

**Key Methods**:
```dart
// Check if user has active Fantaserata league
Future<void> checkFsLeague()

// Set league state when user creates/joins
void setFsLeagueExists(FsLeague league)
void setFsLeagueNotExists()

// Check current state
bool hasFsLeague()
FsLeague? getCurrentFsLeague()

// Clear cached data
Future<void> clearCache()
```

**State Flow**:
- `AppFsLeagueInitial`: Starting state before checking
- `AppFsLeagueExists(FsLeague league)`: User has active Fantaserata league
- `AppFsLeagueNotExists`: User has no active league

**Integration with Auth**:
- Depends on `AppUserCubit` for authentication state
- Automatically resets when user logs out
- Called after successful authentication to check existing league

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
- **Fantaserata Integration**: `AppFsLeagueCubit` checks for active Fantaserata league after authentication

### Real-time Features
- **Notifications**: Firebase FCM + Supabase realtime subscriptions
- **Games**: Supabase realtime for multiplayer lobby/game sessions with live player updates
- **Daily Challenges**: Server-side functions trigger push notifications
- **Game Synchronization**: Real-time state updates for timers, turns, and player actions
- **Fantaserata**: Real-time updates for events, participant changes, and memory sharing
- **Seasonal Events**: Time-based content delivery and feature activation

### Data Synchronization
- **Hive Boxes**: Used by `lib/features/league/data/datasources/local/local_data_source.dart`
  - `leaguesBox`, `rulesBox`, `notesBox`, `challengesBox`, `notificationsBox`, `fsLeaguesBox`
- **Cache Management**: Automatic cleanup of old notifications (max 100 cached)
- **Offline Support**: All core features work offline with cached data
- **Auto-Cleanup**: Fantaserata leagues automatically deleted at 7:00 AM daily
- **Fantaserata Caching**: Separate caching strategy for temporary leagues in `fsLeaguesBox`

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
- `[Action][Entity]Event` for mutations (e.g., `CreateLeagueEvent`, `CreateFsLeagueEvent`)
- State classes follow `[Entity]Loading/Loaded/Error` pattern

### File Organization
- Models use `.fromJson()/.toJson()` for Supabase serialization
- Entities are pure domain objects without serialization
- Use `part` files for large dependency injection configurations
- Constants organized by feature in `lib/core/constants/`
- **Fantaserata Constants**: Simplified rules in `lib/core/constants/fantaserata/simple_fs_rule.dart`
- **Night Types**: Enum definitions in `lib/core/entities/fs_league/fs_night_type.dart`

## Common Gotchas

1. **Service Locator**: Always register dependencies before accessing with `serviceLocator<T>()`
2. **Hive Initialization**: Ensure `_initializeHive()` completes before using boxes
3. **BLoC Dependencies**: Cubits are singletons, BLoCs are factories for proper lifecycle
4. **Firebase Setup**: Both Firebase AND Supabase are used - Firebase for FCM, Supabase for data
5. **Connection Handling**: Always check `connectionChecker.isConnected` before remote operations
6. **Italian Localization**: UI text and error messages are in Italian
7. **Fantaserata Timing**: Remember that fs_leagues auto-delete at 7:00 AM - handle cleanup gracefully in UI
8. **Constants Organization**: Feature-specific constants are in `lib/core/constants/[feature]/`
9. **Model Generation**: Remember to run `build_runner` after modifying models with `.g.dart` files
10. **Fantaserata State Management**: Always check `AppFsLeagueCubit.hasFsLeague()` before accessing Fantaserata features
11. **Night-Specific Logic**: Handle different `FsNightType` values for themed league experiences
12. **Seasonal Events**: Consider seasonal event state when displaying time-sensitive content

Focus on maintaining the established patterns rather than introducing new approaches. The codebase prioritizes consistency and follows proven Clean Architecture principles throughout.
