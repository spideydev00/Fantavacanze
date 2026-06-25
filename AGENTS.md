# Fantavacanze - Codex Instructions

## Project overview

Fantavacanze is a competitive social gaming Flutter app built with Clean Architecture.
The app lets users create or join leagues, complete challenges, manage scores, receive notifications, and interact with real-time or offline-first features.

The backend is based mainly on Supabase. Firebase is used for push notifications. Hive is used for local/offline caching.

## Tech stack

* Flutter / Dart
* Clean Architecture
* flutter_bloc for state management
* get_it for dependency injection
* fpdart for Either-based error handling
* Supabase for auth, database, RPCs, storage, and realtime features (incl. realtime multiplayer games)
* Firebase Cloud Messaging for push notifications (sent server-side via Supabase Edge Functions)
* Hive for local caching
* internet_connection_checker_plus for network checks
* bloc_test + mocktail for tests (no code generation for mocks)

## Architecture rules

The project follows feature-based Clean Architecture. Features: `auth`, `league` (the core), `games`, `app`, `blog`.

Typical structure:

```txt
lib/features/[feature]/
  data/
    datasources/
      remote/
      local/                     # only if offline-first
    models/
      [entity]_model/
    repository/
  domain/
    entities/
    repository/
    use_cases/
      remote/
      local/
  presentation/
    bloc/
      [feature]_bloc/            # blocs are grouped per concern
    pages/
```

See `.codex/skills/clean-architecture/SKILL.md` for the full pattern, and `docs/ai/` for feature deep-dives.

Core shared logic lives in:

```txt
lib/core/
lib/init_dependencies/
```

Keep the existing architecture consistent. Do not introduce alternative patterns unless explicitly requested.

## Development rules

* Reuse existing patterns before creating new ones.
* Keep entities pure and free from serialization logic.
* Put JSON serialization in data models.
* Repository methods should return `Either<Failure, Success>`.
* Remote datasources may throw `ServerException`.
* Local datasources may throw `CacheException`.
* Register all new datasources, repositories, use cases, BLoCs, and cubits in `lib/init_dependencies/init_dependencies.main.dart`.
* Use feature BLoCs as factories and global cubits as lazy singletons, following the current setup (known exception: `AuthBloc` is a lazy singleton because auth state is app-global).
* Do not add new dependencies unless needed.
* Do not make large unrelated refactors during focused tasks.
* Do not commit secrets, API keys, or Supabase credentials.

## Common commands

```bash
flutter pub get
flutter analyze
flutter test
dart run build_runner build --delete-conflicting-outputs
```

Run `build_runner` after changing generated models or files that rely on generated code.

## Offline-first and caching

The app uses an offline-first approach.

When working on repository logic:

* check local cache when appropriate
* use `ConnectionChecker` before remote operations
* cache successful remote responses when relevant
* preserve existing Hive box conventions

## Supabase and SQL rules

When generating SQL, place files according to their purpose:

```txt
supabase/schemas/         table schemas, enums, RLS policies
supabase/db_functions/    RPC and PL/pgSQL functions
supabase/db_triggers/     triggers
supabase/rls/             row level security policies for given tables
supabase/buckets/         buckets' rls
supabase/edge_functions/  edge functions     
```
Before performing database operations always ask to the user. Each time something changes in the database update the corresponding code in /supabase.

## Workflow

You are a worker, so your job is to implement the detailed plan I'm passing you.

Before writing any code, do this in order:

1. If the prompt has a `SKILL:` line, load every skill it names from `.codex/skills/<name>/SKILL.md` and follow it.
2. Whether or not a `SKILL:` line is present, map the task to the Skills table below and load any other matching skill — skill selection is mandatory, not optional.
3. Implement following those skills' rules (Clean Architecture, `Either`, Italian strings, etc.).
4. In your final output, state which skill(s) you applied.

### Plan-driven execution (`docs/superpowers/`)

Detailed implementation plans live in `docs/superpowers/plans/`. When a prompt points you at one of these files:

* Treat each `## Task N` heading as a **separate, self-contained unit of work**. Implement **only the single task** named in the prompt — never run multiple tasks in one pass, even if they look related, sequential, or trivial.
* Each task carries its own `SKILL:` line — load exactly those skills (plus any matching the Skills table) before coding.
* Follow the task's Steps in order (TDD where present: failing test → implement → passing test → commit). Honour the task's `Files`, `Interfaces`, and `Acceptance criteria` verbatim, and respect the plan's `## Global Constraints`.
* Stop at the end of the task, after its commit. Do **not** start the next task — the architect reviews and tests your output first, then sends the next task as a new prompt.

## Skills

Project-specific skills live in `.codex/skills/`. Loading the matching skill before coding is **mandatory** — match the task to the table and follow that `SKILL.md`.

| Skill | Use it when |
|---|---|
| [fantavacanze-dev-orchestrator](.codex/skills/fantavacanze-dev-orchestrator/SKILL.md) | Coordinating non-trivial or multi-step development tasks, routing to project skills, preserving `_workspace` handoffs, or validating/reviewing a broad change. |
| [harness](.codex/skills/harness/SKILL.md) | Designing portable, repo-local agent harnesses with reusable skills, team specs, and deterministic handoff artifacts. |
| [clean-architecture](.codex/skills/clean-architecture/SKILL.md) | Creating a feature, adding a use case/entity/repository/datasource, wiring `get_it` DI, deciding which layer owns logic, or implementing offline-first caching. |
| [bloc](.codex/skills/bloc/SKILL.md) | Creating a Cubit/Bloc, modeling state, naming events/states, wiring `BlocBuilder`/`BlocListener`, or folding `Either` results in a bloc. |
| [testing](.codex/skills/testing/SKILL.md) | Writing or reviewing unit tests, use case tests, repository tests, or `bloc_test` cases. |
| [mocktail](.codex/skills/mocktail/SKILL.md) | Creating mocks/fakes, stubbing, verifying interactions, or registering fallback values in tests. |
| [code-review](.codex/skills/code-review/SKILL.md) | Reviewing a PR, branch, or diff against the project checklist (CA boundaries, `Either`, DI, Italian strings, Supabase/Firebase split). |
| [effective-dart](.codex/skills/effective-dart/SKILL.md) | Writing or refactoring Dart for idiomatic style, naming, type annotations, or comment discipline. |
| [dart-3-updates](.codex/skills/dart-3-updates/SKILL.md) | Writing/refactoring `switch` or `if-else` chains, patterns, sealed classes, records, or destructuring. |
| [firebase-messaging](.codex/skills/firebase-messaging/SKILL.md) | Handling FCM permissions, tokens, foreground/background/terminated messages, or notification tap routing (client-side only; sending is server-side via Supabase Edge Functions). |
| [flutter-errors](.codex/skills/flutter-errors/SKILL.md) | Diagnosing layout/scroll/`setState`-during-build runtime errors (RenderFlex overflow, unbounded constraints, etc.). |
| [flutter-ui-ux](.codex/skills/flutter-ui-ux/SKILL.md) | Building a screen or widget, theming with the app color/size system, adding animations, or extracting a reusable widget into `core/widgets` (bloc-driven, Italian copy). |
| [flutter-responsive-ui](.codex/skills/flutter-responsive-ui/SKILL.md) | Making a layout adapt across phone sizes/tablet, avoiding overflow on small devices, or constraining content width on large ones (`LayoutBuilder`, `Expanded`, `ThemeSizes`). |

## Additional documentation

For deeper project context, consult the documentation files under `docs/ai/` when relevant.

| Document | Covers |
|---|---|
| [docs/ai/architecture.md](docs/ai/architecture.md) | Layers, feature list (`auth`, `league`, `games`, `app`, `blog`), use case pattern, DI, global cubits. |
| [docs/ai/features/auth.md](docs/ai/features/auth.md) | Auth feature: `User`/`UserModel` fields, use cases, pages, FCM token sync, `AppUserCubit`. |
| [docs/ai/features/league.md](docs/ai/features/league.md) | League feature: models, pages, the 4 BLoCs, navigation shell, subscriptions. |
| [docs/ai/daily-challenges.md](docs/ai/daily-challenges.md) | Daily challenges: generation, `is_unlocked`/positions, premium/free, refresh, admin approval, RPCs/edge functions. |
| [docs/ai/supabase.md](docs/ai/supabase.md) | Backend map: tables, enums, RPCs (client vs internal), triggers, edge functions, RLS, buckets, client integration. |
| [docs/ai/caching.md](docs/ai/caching.md) | Offline-first flow, `ConnectionChecker`, Hive boxes and their stored types, notification cache caps. |
| [docs/ai/gotchas.md](docs/ai/gotchas.md) | Recurring pitfalls checklist (DI, Hive init, CA boundaries, Italian strings, no seasonal cubit, SQL folders). |
