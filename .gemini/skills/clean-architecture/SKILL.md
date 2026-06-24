---
name: clean-architecture
description: "Structure Flutter features using Clean Architecture with a mandatory domain layer. Use when creating a new feature, adding a use case, implementing a repository, wiring datasources, registering dependencies in get_it, or deciding which layer owns a piece of logic. Covers entities, use cases, repository interfaces and implementations, remote/local datasources, and BLoC wiring."
---

# Clean Architecture Skill

This skill defines the mandatory architecture pattern used throughout this project.

Clean Architecture is always used — the domain layer is never optional. Every feature has `data/`, `domain/`, and `presentation/` sub-layers.

## When to Use

Use this skill when:

* Creating a new feature folder.
* Adding a new use case, entity, or repository.
* Implementing a remote or local datasource.
* Wiring dependency injection in `lib/init_dependencies/init_dependencies.main.dart`.
* Deciding which layer owns a given piece of logic.
* Adding or fixing caching or offline-first behavior.

---

## 1. Layers

```
┌─────────────────────────────────────────────────────┐
│  Presentation  │  Pages, Widgets, BLoC/Cubit        │
├─────────────────────────────────────────────────────┤
│  Domain        │  Entities, Use Cases, Repository   │
│                │  interfaces                         │
├─────────────────────────────────────────────────────┤
│  Data          │  Models, RemoteDataSource,          │
│                │  LocalDataSource, RepositoryImpl    │
└─────────────────────────────────────────────────────┘
```

Rules:
- Presentation → Domain only. Presentation never touches Data directly.
- Domain is pure Dart: no Flutter imports, no Supabase, no Hive.
- Data implements Domain interfaces. Models extend or map to entities.
- All repository methods return `Either<Failure, Success>` (fpdart).

---

## 2. Feature Folder Structure

```
lib/features/<feature_name>/
  data/
    datasources/
      remote/<feature>_remote_data_source.dart
      local/<feature>_local_data_source.dart     # only if offline-first
    models/
      <entity>_model/
        <entity>_model.dart
    repository/
      <feature>_repository_impl.dart
  domain/
    entities/
      <entity>.dart
    repository/
      <feature>_repository.dart                  # abstract interface
    use_cases/
      remote/
        <action>_<entity>.dart
      local/                                     # only if needed
        <action>_<entity>.dart
  presentation/
    bloc/
      <feature>_bloc/
        <feature>_bloc.dart
        <feature>_event.dart
        <feature>_state.dart
    pages/
      <page_name>/
        <page_name>.dart
        widgets/
```

---

## 3. Entity

Pure domain object. No serialization, no Supabase, no Hive.

```dart
class League extends Equatable {
  final String id;
  final String name;
  final List<String> admins;

  const League({
    required this.id,
    required this.name,
    required this.admins,
  });

  @override
  List<Object?> get props => [id, name, admins];
}
```

---

## 4. Model

Extends or maps to the entity. Contains serialization logic for Supabase (`.fromJson()` / `.toJson()`) and optionally Hive adapters.

```dart
class LeagueModel extends League {
  const LeagueModel({
    required super.id,
    required super.name,
    required super.admins,
  });

  factory LeagueModel.fromJson(Map<String, dynamic> map) {
    return LeagueModel(
      id: map['id'] as String,
      name: map['name'] as String,
      admins: List<String>.from(map['admins'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'admins': admins,
  };
}
```

---

## 5. Use Case Pattern

Every business action is a use case. Use the shared abstraction:

```dart
// lib/core/use-case/usecase.dart
abstract interface class Usecase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

// For realtime streams (e.g. game sessions, notification listeners)
abstract class StreamUsecase<SuccessType, Params> {
  Stream<Either<Failure, SuccessType>> call(Params params);
}

class NoParams {}
```

Use `Usecase` for one-shot async actions and `StreamUsecase` for realtime subscriptions. Use `NoParams` when the action needs no input.

Implementation:

```dart
class GetLeague implements Usecase<League, GetLeagueParams> {
  final LeagueRepository _repository;

  GetLeague(this._repository);

  @override
  Future<Either<Failure, League>> call(GetLeagueParams params) {
    return _repository.getLeague(params.leagueId);
  }
}

class GetLeagueParams {
  final String leagueId;
  const GetLeagueParams({required this.leagueId});
}
```

---

## 6. Repository Interface (Domain)

Defines the contract; purely domain types in the signature.

```dart
abstract interface class LeagueRepository {
  Future<Either<Failure, League>> getLeague(String leagueId);
  Future<Either<Failure, List<League>>> getUserLeagues();
  Future<Either<Failure, Unit>> createLeague(CreateLeagueParams params);
}
```

---

## 7. Repository Implementation (Data)

Coordinates remote/local datasources, checks connectivity, maps exceptions to failures. The project uses **inline `try` / `on ServerException` / `on CacheException` blocks** in each method (there is no shared `_tryDatabaseOperation` wrapper). Error messages returned to the UI are in Italian.

Two offline-first strategies coexist, pick the one matching the data:

**Cache-first** (data that rarely changes / must work offline immediately):

```dart
@override
Future<Either<Failure, League>> getLeague(String leagueId) async {
  try {
    if (!await connectionChecker.isConnected) {
      final cached = await localDataSource.getCachedLeague(leagueId);
      if (cached != null) return Right(cached);
      return Left(Failure("Nessuna connessione e nessun dato nella cache."));
    }

    final league = await remoteDataSource.getLeague(leagueId);
    await localDataSource.cacheLeague(league);
    return Right(league);
  } on ServerException catch (e) {
    final cached = await localDataSource.getCachedLeague(leagueId);
    if (cached != null) return Right(cached);
    return Left(Failure(e.message));
  } on CacheException catch (e) {
    return Left(Failure('Errore nella cache: ${e.message}'));
  }
}
```

**Remote-first with cache fallback** (data where server truth matters; the cold-start connectivity probe can be unreliable, so the remote call is the real online check):

```dart
@override
Future<Either<Failure, List<League>>> getUserLeagues() async {
  try {
    try {
      final leagues = await remoteDataSource.getUserLeagues();
      await localDataSource.cacheLeagues(leagues);
      return Right(leagues);
    } on ServerException {
      // fall through to cache when remote is actually unavailable
    }

    final cached = await localDataSource.getCachedLeagues();
    return Right(cached);
  } on ServerException catch (e) {
    return Left(Failure(e.message));
  } on CacheException catch (e) {
    return Left(Failure('Errore nella cache: ${e.message}'));
  }
}
```

Constructor injects datasources + `ConnectionChecker` via named params:

```dart
class LeagueRepositoryImpl implements LeagueRepository {
  final LeagueRemoteDataSource remoteDataSource;
  final LeagueLocalDataSource localDataSource;
  final ConnectionChecker connectionChecker;

  LeagueRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectionChecker,
  });
}
```

---

## 8. Remote DataSource

Wraps Supabase calls. Throws `ServerException` on failure — never returns `Either`.

```dart
abstract interface class LeagueRemoteDataSource {
  Future<List<LeagueModel>> getUserLeagues();
}

class LeagueRemoteDataSourceImpl implements LeagueRemoteDataSource {
  final SupabaseClient _supabaseClient;

  LeagueRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<List<LeagueModel>> getUserLeagues() async {
    try {
      final response = await _supabaseClient.rpc('get_user_leagues');
      return (response as List)
          .map((e) => LeagueModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
```

---

## 9. Local DataSource (Offline-First)

Wraps Hive boxes. Throws `CacheException` on failure.

```dart
abstract interface class LeagueLocalDataSource {
  Future<List<LeagueModel>> getCachedLeagues();
  Future<void> cacheLeagues(List<LeagueModel> leagues);
}

class LeagueLocalDataSourceImpl implements LeagueLocalDataSource {
  final Box<LeagueModel> leaguesBox;

  LeagueLocalDataSourceImpl({required this.leaguesBox});

  @override
  Future<List<LeagueModel>> getCachedLeagues() async {
    try {
      return leaguesBox.values.toList();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheLeagues(List<LeagueModel> leagues) async {
    try {
      for (final league in leagues) {
        await leaguesBox.put(league.id, league);
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
```

---

## 10. ConnectionChecker

Always check connectivity before remote operations.

```dart
// lib/core/network/connection_checker.dart
abstract interface class ConnectionChecker {
  Future<bool> get isConnected;
}
```

Use it in the repository before every remote call when offline-first behavior is needed.

---

## 11. Dependency Injection

Register all new components in order in `lib/init_dependencies/init_dependencies.main.dart`:

```dart
// 1. DataSources
serviceLocator.registerFactory<LeagueRemoteDataSource>(
  () => LeagueRemoteDataSourceImpl(serviceLocator()),
);
serviceLocator.registerFactory<LeagueLocalDataSource>(
  () => LeagueLocalDataSourceImpl(leaguesBox: serviceLocator()),
);

// 2. Repository
serviceLocator.registerFactory<LeagueRepository>(
  () => LeagueRepositoryImpl(
    remoteDataSource: serviceLocator(),
    localDataSource: serviceLocator(),
    connectionChecker: serviceLocator(),
  ),
);

// 3. Use Cases
serviceLocator.registerFactory(() => GetLeague(serviceLocator()));
serviceLocator.registerFactory(() => CreateLeague(serviceLocator()));

// 4. BLoC (factory)
serviceLocator.registerFactory(
  () => LeagueBloc(getLeague: serviceLocator(), createLeague: serviceLocator()),
);

// Global cubits: registerLazySingleton
```

Lifecycle convention:
- **BLoCs** → `registerFactory` (fresh instance per page)
- **Global cubits** → `registerLazySingleton` (app-wide singletons)
- **Repositories / datasources / use cases** → `registerFactory`

---

## 12. BLoC Wiring

The BLoC receives use cases via constructor, calls them, and folds the `Either` result:

```dart
Future<void> _onGetLeague(
  GetLeagueEvent event,
  Emitter<LeagueState> emit,
) async {
  emit(LeagueLoading());
  final result = await _getLeague(GetLeagueParams(leagueId: event.leagueId));
  result.fold(
    (failure) => emit(LeagueError(failure.message)),
    (league) => emit(LeagueLoaded(league)),
  );
}
```

---

## 13. Feature Creation Checklist

1. Create `lib/features/<name>/` with `data/`, `domain/`, `presentation/`
2. Define domain entity in `domain/entities/`
3. Define repository interface in `domain/repository/`
4. Create data models extending entities in `data/models/`
5. Implement remote datasource in `data/datasources/remote/`
6. Implement local datasource in `data/datasources/local/` (if offline-first)
7. Implement repository in `data/repository/`
8. Create use cases in `domain/use_cases/remote/` (and `local/` if needed)
9. Create BLoC events, states, and bloc in `presentation/bloc/`
10. Build pages in `presentation/pages/`
11. Register all dependencies in `init_dependencies.main.dart`
12. Run `dart run build_runner build --delete-conflicting-outputs` if models have generated code

---

## Common Gotchas

* Do not return raw exceptions from repositories — always map to `Failure`.
* Do not put Supabase calls inside domain entities or use cases — only in datasources.
* Do not bypass use cases from the UI — always go through BLoC → UseCase → Repository.
* Always check `connectionChecker.isConnected` before remote calls in offline-first repos.
* Always register dependencies before using `serviceLocator<T>()`.
* Run `build_runner` after modifying models that have `.g.dart` generated files.
* UI text and user-facing error messages are in Italian.
