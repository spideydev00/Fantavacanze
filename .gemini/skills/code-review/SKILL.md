---
name: code-review
description: "Review Flutter/Dart code against a structured checklist. Use when asked to review a PR, a branch, or a diff. Covers correctness, Clean Architecture boundaries, Either-based error handling, dependency injection, generated files, Italian UI strings, Supabase/Firebase responsibilities, and performance."
---

# Code Review Skill

Perform structured, objective code reviews for this Flutter project.

## When to Use

Use this skill when:

* Asked to review a pull request, branch, or diff.
* Evaluating changed files for correctness and quality.
* Checking whether new code meets project standards.

---

## Review Workflow

### Step 1 — Understand the change set

1. List all changed, added, and deleted files.
2. Identify which feature/layer each change belongs to.
3. Never assume a change is correct without investigating the implementation.

### Step 2 — Review each file

For every changed file, verify:

| Area | What to check |
|---|---|
| **Location** | File is in the correct layer/folder following Clean Architecture |
| **Naming** | File and class names follow project conventions |
| **Responsibility** | The file's responsibility is clear; no layer mixing |
| **Logic & correctness** | No logic errors or missing edge cases |
| **Error handling** | `Either<Failure, Success>` preserved; no raw exceptions leaking to UI |
| **Security** | No secrets committed; no input validation gaps |
| **Performance** | No unnecessary rebuilds, redundant Supabase calls, or unbounded lists |
| **Generated files** | `.g.dart` files updated and not manually modified; `build_runner` run if needed |
| **Style** | Follows Effective Dart and project conventions |

---

## Project-Specific Checks

### Clean Architecture boundaries

```
// BAD — UI page calls Supabase directly
final leagues = await supabaseClient.from('individual_leagues').select();

// GOOD — UI dispatches event → BLoC → UseCase → Repository → DataSource
context.read<LeagueBloc>().add(const GetLeagueEvent(leagueId));
```

Verify:
- [ ] Presentation never accesses `supabaseClient` or Hive directly.
- [ ] Use cases are called from BLoCs, not from pages.
- [ ] Entities contain no serialization logic.
- [ ] Models contain no business logic.
- [ ] Datasources never return `Either` — they throw exceptions.
- [ ] Repositories always return `Either<Failure, Success>`.

### Either-based error handling

```dart
// BAD — exception escaping repository
Future<List<League>> getUserLeagues() async {
  return await _remoteDataSource.getUserLeagues(); // throws on error, no mapping
}

// GOOD
Future<Either<Failure, List<League>>> getUserLeagues() async {
  try {
    final leagues = await _remoteDataSource.getUserLeagues();
    return right(leagues);
  } on ServerException catch (e) {
    return left(Failure(e.message));
  }
}
```

Verify:
- [ ] All repository methods return `Either<Failure, Success>`.
- [ ] The BLoC folds the `Either` result (handles both `left` and `right`).
- [ ] No raw exceptions propagate above the repository layer.

### Dependency injection

Verify:
- [ ] Every new datasource, repository, use case, BLoC, or cubit is registered in `lib/init_dependencies/init_dependencies.main.dart`.
- [ ] BLoCs registered as `registerFactory`.
- [ ] Global cubits registered as `registerLazySingleton`.
- [ ] No `serviceLocator<T>()` call before `T` is registered.

### Generated files

Verify:
- [ ] If a model with `@HiveType` / `@JsonSerializable` was modified, the corresponding `.g.dart` was regenerated.
- [ ] `build_runner` output is clean (`--delete-conflicting-outputs`).

### Offline-first and caching

Verify:
- [ ] `ConnectionChecker` is used before remote operations in offline-first repositories.
- [ ] Successful remote responses are cached when the existing pattern expects it.
- [ ] Cache is invalidated appropriately after mutations.
- [ ] Hive box names match the existing conventions (`leagues_box`, `notes_box`, `challenges_box`, `notifications_box`, `rules_box`).

### Supabase / Firebase responsibilities

```
Supabase: auth, database, RPC calls, storage, realtime
Firebase: FCM push notification delivery ONLY
```

Verify:
- [ ] No Firebase Auth usage (project uses Supabase Auth).
- [ ] No Firestore / Firebase Database usage.
- [ ] FCM token is synced to `profiles.fcm_token` on login; cleared on logout.
- [ ] RPC calls use the correct function names (check `docs/ai/supabase.md`).
- [ ] No raw table writes for league JSONB data — use RPCs.

### BLoC lifecycle

Verify:
- [ ] Feature BLoCs are `registerFactory`, not singletons (known exception: `AuthBloc` is intentionally a `registerLazySingleton`).
- [ ] Global cubits (`AppUserCubit`, `AppLeagueCubit`, etc.) are not re-created per page.
- [ ] BLoC events are named `[Action][Entity]Event`.
- [ ] BLoC states are named `[Entity]Initial/Loading/Loaded/Error`.

### UI and localization

Verify:
- [ ] All user-facing strings are in **Italian**.
- [ ] No English error messages passed directly to the UI.
- [ ] UI widgets contain no business logic.
- [ ] `BlocListener` is used for side effects (navigation, snackbars, dialogs) — not `BlocBuilder`.

### Flutter-specific checks

```dart
// BAD — rebuilds entire screen on every state change
BlocBuilder<LeagueBloc, LeagueState>(
  builder: (context, state) => EntireScreen(state: state),
);

// GOOD — scope rebuilds to the widget that actually needs to change
BlocSelector<LeagueBloc, LeagueState, List<League>>(
  selector: (state) => state is LeagueLoaded ? state.leagues : [],
  builder: (context, leagues) => LeagueList(leagues: leagues),
);
```

- [ ] `const` constructors used where possible.
- [ ] `dispose()` called for controllers, streams, and animation controllers.
- [ ] `Key` used where dynamically generated lists are rendered.
- [ ] No `context.read` in `build` — only in callbacks.

---

### Step 3 — Evaluate the overall change set

1. Is the change set **focused** on a single purpose? No unrelated changes.
2. Is the change **backward-compatible** with existing cache structures and Supabase schemas?
3. Are there **notification or FCM side effects** that need to be checked?
4. Are there **daily challenge** state transitions affected? (see `docs/ai/daily-challenges.md`)

---

## Final Checklist Before Approving

- [ ] Clean Architecture boundaries respected
- [ ] `Either<Failure, Success>` preserved throughout
- [ ] All new dependencies registered in `init_dependencies.main.dart`
- [ ] Generated files updated if models changed
- [ ] Cache behavior still valid after mutations
- [ ] Global state (`AppUserCubit`, `AppLeagueCubit`) synchronized if needed
- [ ] User-facing strings in Italian
- [ ] Supabase and Firebase responsibilities respected
- [ ] Unrelated files untouched
