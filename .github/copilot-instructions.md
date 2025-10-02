---
applyTo: '**'
---

# Fantavacanze - AI Assistant Instructions

## Project Overview
Fantavacanze is a competitive social gaming Flutter app using **Clean Architecture** with Supabase backend, Firebase messaging, and offline-first caching. Features include leagues, daily challenges, real-time multiplayer games, and temporary Fantaserata leagues.

## Architecture & Key Packages

### Clean Architecture Structure
- **Data Layer**: `lib/features/[feature]/data/` - models, repositories, datasources
- **Domain Layer**: `lib/features/[feature]/domain/` - entities, use cases, repository interfaces  
- **Presentation Layer**: `lib/features/[feature]/presentation/` - UI, BLoC, pages

### Essential Dependencies
- **State Management**: `flutter_bloc` with global cubits in `lib/core/cubits/`
- **Dependency Injection**: `get_it` service locator in `lib/init_dependencies/init_dependencies.main.dart`
- **Functional Programming**: `fpdart` for `Either<Failure, Success>` return types
- **Local Storage**: `hive` boxes for offline-first caching
- **Network**: `internet_connection_checker_plus` to determine cache vs remote data
- **Backend**: Supabase for database, auth, real-time subscriptions
- **Push Notifications**: Firebase FCM integration
- **Subscriptions**: RevenueCat for premium features

## Implementation Guidelines

### 1. UI Modifications
- Reusable components in `lib/core/widgets/`
- Feature-specific widgets in `lib/features/[feature]/presentation/widgets/`
- Use established theme system: `context.theme.colorScheme`, `Sizes.p16`
- Key patterns: `GradientCardContainer`, `ModernIconButton`, `EmptyState`, `Loader`
- All UI text in Italian

### 2. Client-Server Communication
- Always follow offline-first pattern: check cache first, then remote if connected
- Repository pattern with `ConnectionChecker` for online/offline handling
- Remote datasources throw `ServerException`, local throw `CacheException`
- Use Cases implement `Usecase<SuccessType, Params>` interface
- Supabase integration via remote datasources with RPC functions and real-time subscriptions

### 3. State Management
- BLoC pattern: Events named `[Action][Entity]Event`, States named `[Entity][Status]State`
- Global state cubits: `AppUserCubit`, `AppLeagueCubit`, `AppFsLeagueCubit`, `AppNavigationCubit`, `SeasonalEventCubit`
- Feature-specific navigation: `FsNavigationCubit` for Fantaserata section
- Always check user authentication state before operations

## Key Features

### Core Features
- **Auth**: Complete OAuth (Google/Apple) and email/password system
- **League**: Main competitive leagues with teams/individuals, daily challenges, admin approval system
- **Fantaserata**: Temporary daily leagues (auto-delete at 7:00 AM), individual-only, venue-themed
- **Games**: Real-time multiplayer (Truth or Dare, Word Bomb, Never Have I Ever)

### Data Management
- **Hive Boxes**: `leaguesBox`, `fsLeaguesBox`, `notificationsBox`, `challengesBox`, `rulesBox`, `notesBox`
- **Cache Strategy**: Max 100 notifications, automatic cleanup, offline support for all features
- **Real-time**: Supabase subscriptions for live updates, Firebase FCM for push notifications

## File Organization Rules

### Feature Structure
Follow Clean Architecture with data/domain/presentation layers. All dependencies registered in `init_dependencies.main.dart` as factories (data sources, repositories, use cases, BLoCs) or singletons (global cubits).

### Important Configurations
- **Dependency Registration**: DataSources and repositories as factories, global cubits as singletons
- **Error Handling**: All repositories return `Either<Failure, Success>`
- **Caching**: Offline-first with Hive boxes, connection checking before remote calls
- **Navigation**: Dynamic navigation based on league membership
- **Localization**: Italian text throughout app

## Critical Notes
- Fantaserata leagues auto-delete at 7:00 AM daily - handle gracefully in UI
- Always check `AppFsLeagueCubit.hasFsLeague()` before Fantaserata operations
- Premium users see all 6 daily challenges, free users see 1
- Use `ConnectionChecker` before all remote operations
- Remember to run `build_runner` after modifying models with `.g.dart` files

## Project Structure Update Requirement
**After implementing any new files, always update `project-structure.md` with:**
1. New file paths in correct tree structure
2. Maintain alphabetical ordering within directories  
3. Include file extensions
4. Follow existing formatting patterns
5. Add brief description for major new features
6. Check existing structure to avoid duplicates
