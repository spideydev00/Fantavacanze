---
name: bloc
description: "Implement Flutter state management using the bloc and flutter_bloc libraries. Use when creating a new Cubit or Bloc, modeling state, wiring BlocBuilder/BlocListener/BlocConsumer in widgets, writing bloc unit tests, or deciding between Cubit and Bloc."
---

# Bloc Skill

Design, implement, and test state management using the [bloc](https://pub.dev/packages/bloc) and [flutter_bloc](https://pub.dev/packages/flutter_bloc) libraries.

## When to Use

Use this skill when:

* Creating a new Cubit or Bloc for a feature.
* Modeling state (choosing between sealed classes and a single state class with status enum).
* Wiring `BlocBuilder`, `BlocListener`, `BlocConsumer`, or `BlocProvider` in the widget tree.
* Writing unit tests for a Cubit or Bloc.
* Deciding between Cubit and Bloc.

---

## 1. Cubit vs Bloc

| Situation | Use |
|---|---|
| Simple app-wide state, few transitions | `Cubit` |
| Feature-specific flows with multiple events | `Bloc` |
| Advanced event processing (debounce, throttle) | `Bloc` with event transformers |

**Global app state → `Cubit` registered as singleton. Feature-specific → `Bloc` registered as factory.**

---

## 2. Naming Conventions

### Events (Bloc)

Named as **imperative actions** — not past tense:

```
[Action][Entity]Event

GetLeagueEvent
CreateLeagueEvent
UpdateLeagueEvent
DeleteLeagueEvent
GetDailyChallengesEvent
MarkChallengeAsCompletedEvent
```

Base event class: `[Feature]Event` (e.g., `LeagueEvent`).

### States

Named as **nouns describing the current snapshot**:

```
[Entity]Initial
[Entity]Loading
[Entity]Loaded
[Entity]Error
```

Examples: `LeagueInitial`, `LeagueLoading`, `LeagueLoaded`, `LeagueError`.

---

## 3. Modeling State

### Sealed classes (preferred for feature BLoCs)

Use when states are mutually exclusive and carry different payloads:

```dart
@immutable
sealed class LeagueState extends Equatable {
  const LeagueState();
}

final class LeagueInitial extends LeagueState {
  @override
  List<Object?> get props => [];
}

final class LeagueLoading extends LeagueState {
  @override
  List<Object?> get props => [];
}

final class LeagueLoaded extends LeagueState {
  const LeagueLoaded(this.leagues);
  final List<League> leagues;

  @override
  List<Object?> get props => [leagues];
}

final class LeagueError extends LeagueState {
  const LeagueError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
```

Handle exhaustively in the UI:

```dart
switch (state) {
  case LeagueInitial():  return const SizedBox.shrink();
  case LeagueLoading():  return const CircularProgressIndicator();
  case LeagueLoaded(:final leagues): return LeagueList(leagues: leagues);
  case LeagueError(:final message):  return Text(message);
}
```

### Single class with status enum (for global cubits or simple state)

Preferred when many fields are shared across states:

```dart
enum LeagueStatus { initial, loading, loaded, error }

@immutable
class LeagueState extends Equatable {
  const LeagueState({
    this.status = LeagueStatus.initial,
    this.leagues = const [],
    this.errorMessage,
  });

  final LeagueStatus status;
  final List<League> leagues;
  final String? errorMessage;

  LeagueState copyWith({
    LeagueStatus? status,
    List<League>? leagues,
    String? errorMessage,
  }) => LeagueState(
    status: status ?? this.status,
    leagues: leagues ?? this.leagues,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, leagues, errorMessage];
}
```

---

## 4. Bloc Implementation

Blocs receive use cases via constructor and call them, folding the `Either<Failure, Success>` result:

```dart
sealed class LeagueEvent {}
final class GetLeagueEvent extends LeagueEvent {
  const GetLeagueEvent(this.leagueId);
  final String leagueId;
}

class LeagueBloc extends Bloc<LeagueEvent, LeagueState> {
  LeagueBloc({required GetLeague getLeague})
      : _getLeague = getLeague,
        super(LeagueInitial()) {
    on<GetLeagueEvent>(_onGetLeague);
  }

  final GetLeague _getLeague;

  Future<void> _onGetLeague(
    GetLeagueEvent event,
    Emitter<LeagueState> emit,
  ) async {
    emit(LeagueLoading());
    final result = await _getLeague(GetLeagueParams(leagueId: event.leagueId));
    result.fold(
      (failure) => emit(LeagueError(failure.message)),
      (league)  => emit(LeagueLoaded([league])),
    );
  }
}
```

Rules:
- Always fold `Either` results — never ignore `Left`.
- Keep handler methods private (`_onEventName`).
- Inject use cases via constructor, not `serviceLocator` directly.
- Trigger state changes via `bloc.add(Event())`, not public methods.

---

## 5. Cubit Implementation

```dart
class AppLeagueCubit extends Cubit<AppLeagueState> {
  AppLeagueCubit({required GetUserLeagues getUserLeagues})
      : _getUserLeagues = getUserLeagues,
        super(AppLeagueInitial());

  final GetUserLeagues _getUserLeagues;

  Future<void> loadLeagues() async {
    emit(AppLeagueLoading());
    final result = await _getUserLeagues(NoParams());
    result.fold(
      (failure) => emit(AppLeagueError(failure.message)),
      (leagues) => emit(AppLeagueLoaded(leagues)),
    );
  }
}
```

---

## 6. Lifecycle and Registration

```dart
// feature BLoC → factory (fresh instance per page)
serviceLocator.registerFactory(
  () => LeagueBloc(getLeague: serviceLocator()),
);

// global cubit → lazy singleton (app-wide, created once)
serviceLocator.registerLazySingleton(
  () => AppLeagueCubit(getUserLeagues: serviceLocator()),
);
```

Convention in this project:
- **Feature BLoCs** → `registerFactory`: `LeagueBloc`, `DailyChallengesBloc`, `NotificationsBloc`, `SubscriptionBloc`, `LobbyBloc`, `TruthOrDareBloc`.
- **Global cubits** → `registerLazySingleton`: `AppUserCubit`, `AppLeagueCubit`, `AppNavigationCubit`, `AppStatusCubit`, `AppVersionCubit`, `AppThemeCubit`, `NotificationCountCubit`, `ShareButtonAnimationCubit`.

**As a rule, never register a feature BLoC as a singleton** — it preserves stale state across navigations.

**Exception:** `AuthBloc` is intentionally registered as `registerLazySingleton` because authentication state is effectively app-global and must persist for the whole session. Apply this only to genuinely app-wide blocs; default to factory for everything else.

---

## 7. Flutter Bloc Widgets

| Widget | Use |
|---|---|
| `BlocProvider` | Provide a bloc/cubit to a subtree |
| `MultiBlocProvider` | Provide multiple blocs without nesting |
| `BlocBuilder` | Rebuild UI on state change |
| `BlocListener` | Side effects only (navigation, snackbars, dialogs) |
| `MultiBlocListener` | Listen to multiple blocs without nesting |
| `BlocConsumer` | Rebuild + side effects together |
| `BlocSelector` | Rebuild only when a selected slice of state changes |

```dart
BlocProvider(
  create: (context) => serviceLocator<LeagueBloc>()..add(GetLeagueEvent(leagueId)),
  child: const LeaguePage(),
);

BlocBuilder<LeagueBloc, LeagueState>(
  builder: (context, state) => switch (state) {
    LeagueInitial()          => const SizedBox.shrink(),
    LeagueLoading()          => const CircularProgressIndicator(),
    LeagueLoaded(:final leagues) => LeagueList(leagues: leagues),
    LeagueError(:final message)  => Text(message),
  },
);

BlocListener<LeagueBloc, LeagueState>(
  listener: (context, state) {
    if (state is LeagueError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: const LeagueBody(),
);
```

Rules:
- Use `context.read<T>()` inside callbacks; prefer `BlocBuilder` over `context.watch` in `build`.
- Handle **all** possible states in the UI.
- Do not check bloc state directly from UI — use `BlocListener`/`BlocBuilder`.

---

## 8. Testing

Use `bloc_test` package. Mock dependencies with `mocktail`.

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:test/test.dart';

class MockGetLeague extends Mock implements GetLeague {}

void main() {
  group('LeagueBloc', () {
    late GetLeague getLeague;
    late LeagueBloc leagueBloc;

    setUp(() {
      getLeague = MockGetLeague();
      leagueBloc = LeagueBloc(getLeague: getLeague);
    });

    tearDown(() => leagueBloc.close());

    blocTest<LeagueBloc, LeagueState>(
      'emits [LeagueLoading, LeagueLoaded] when GetLeagueEvent succeeds',
      build: () {
        when(() => getLeague(any())).thenAnswer((_) async => right(fakeLeague));
        return leagueBloc;
      },
      act: (bloc) => bloc.add(const GetLeagueEvent('league-id')),
      expect: () => [
        isA<LeagueLoading>(),
        isA<LeagueLoaded>(),
      ],
    );

    blocTest<LeagueBloc, LeagueState>(
      'emits [LeagueLoading, LeagueError] when GetLeagueEvent fails',
      build: () {
        when(() => getLeague(any()))
            .thenAnswer((_) async => left(Failure('Errore')));
        return leagueBloc;
      },
      act: (bloc) => bloc.add(const GetLeagueEvent('league-id')),
      expect: () => [
        isA<LeagueLoading>(),
        isA<LeagueError>(),
      ],
    );
  });
}
```

Rules:
- Always call `tearDown(() => bloc.close())`.
- Use `blocTest` for state emission assertions.
- Mock use cases (not repositories) at the BLoC test level.
- Name test cases descriptively with the event name and expected outcome.
- Register fallback values for custom types: `registerFallbackValue(GetLeagueParams(...))`.

---

## 9. Common Pitfalls

| Pitfall | Fix |
|---|---|
| Emitting the same state instance twice | Always create new state objects; `Equatable` deduplicates. |
| Forgetting to fold `Either` | Always handle both `left` (failure) and `right` (success). |
| Forgetting `Equatable` props | Add every field to `props`; missing fields cause silent update bugs. |
| Mutable state fields | Keep state `@immutable`; use `copyWith` or sealed subclasses. |
| Business logic in widgets | Move all logic into the Bloc/Cubit; widgets only dispatch events. |
| Feature BLoC registered as singleton | Register as factory — stale state leaks between screens. |
