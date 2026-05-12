# Fantavacanze - Agent Instructions

> File letto automaticamente da Codex CLI (e da altri agenti che seguono la
> convenzione AGENTS.md). Riflette le stesse linee guida di `CLAUDE.md`,
> con focus sui pattern del progetto e sulle gotchas piu' frequenti.

## Project Overview

Fantavacanze e' un'app Flutter di gaming sociale competitivo costruita con
**Clean Architecture**. Backend: Supabase (Postgres + Auth + Storage +
Realtime + Edge Functions). Push: Firebase FCM. Caching offline-first via
Hive. La feature core e' la gestione delle leghe (individual / team) con
classifiche, daily challenges, memories, mini-giochi multiplayer.

## Architettura e pattern core

### Struttura per feature (Clean Architecture)

- **Data layer**: `lib/features/[feature]/data/` -- models, repositories,
  datasources (remote/local)
- **Domain layer**: `lib/features/[feature]/domain/` -- entities, use
  cases, repository interface
- **Presentation layer**: `lib/features/[feature]/presentation/` -- UI,
  BLoC/Cubit, pages

### Dipendenze chiave

- **State management**: `flutter_bloc` (Cubit per stato globale in
  `lib/core/cubits/`, BLoC per stato di feature)
- **DI**: `get_it` come service locator, configurato in
  `lib/init_dependencies/init_dependencies.main.dart`
- **Functional**: `fpdart` per `Either<Failure, Success>` come return
  type dei repository
- **Local storage**: `hive` (boxes: `leaguesBox`, `rulesBox`, `notesBox`,
  `challengesBox`, `notificationsBox`)
- **Network probe**: `internet_connection_checker_plus` via
  `ConnectionChecker` (vedi gotcha #2)
- **HTTP/Auth**: `supabase_flutter` (PostgREST + Auth + Storage)
- **Push**: `firebase_messaging` (FCM)
- **Paywall**: `purchases_flutter` (RevenueCat)

### UseCase pattern

Tutta la business logic implementa `Usecase<SuccessType, Params>` definita
in `lib/core/use-case/usecase.dart`:

```dart
abstract interface class Usecase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}
```

Use case = una sola operazione, parametri raggruppati in una classe
`*Params` accanto al file del use case stesso.

## Workflow per aggiungere una feature

1. Crea la cartella `lib/features/[feature_name]/` con sotto-struttura
   data/domain/presentation
2. Entity pure (no serializzazione) in `domain/entities/`
3. Repository interface in `domain/repository/`
4. Model che extends l'entity in `data/models/` con `.fromJson()` /
   `.toJson()`
5. Datasource remote (Supabase) e local (Hive) in `data/datasources/`
6. Repository impl in `data/repository/` con pattern
   ConnectionChecker -> cache | remote -> Either
7. Use case in `domain/use-cases/` o `domain/use_cases/remote|local/`
8. Registrazione in `lib/init_dependencies/init_dependencies.main.dart`
   nell'ordine: datasources (factory) -> repository (factory) -> use
   case (factory) -> BLoC (factory) -> cubit globale (singleton)
9. BLoC in `presentation/bloc/`
10. UI in `presentation/pages/`

## Cubit globali (singleton)

In `lib/core/cubits/`:

1. **`app_user/`** -- stato di autenticazione (User loggato, premium,
   onboarding, ecc.)
2. **`app_league/`** -- leghe dell'utente, lega selezionata, mappa
   cached `Map<String, MemberProfile>` per le foto profilo dei membri
3. **`app_navigation/`** -- indice della bottom nav
4. **`app_theme/`** -- light/dark/system con persistenza
   SharedPreferences

Cubit globali sono **singleton** in DI; BLoC di feature sono **factory**
(lifecycle gestito dal widget tree).

## Pattern caching offline-first

Tutti i repository seguono lo stesso schema (esempio daily challenges):

```dart
getDailyChallenges() {
  final cached = await localDataSource.getCachedDailyChallenges();
  if (needsRefresh) {
    final remote = await remoteDataSource.getDailyChallenges();
    await localDataSource.cacheDailyChallenges(remote);
  }
  return cached;
}
```

Se offline: ritorna la cache. Se online + cache stale: refresh dal
remote, cache, ritorna. **Eccezione**: query "live-essenziali" come
`getProfileImagesForUsers` NON usano connectionChecker -- vedi gotcha #2.

## Daily challenges system

Sistema complesso documentato in
`lib/features/league/domain/use_cases/remote/daily_challenges/`.

1. **Generation**: ogni giorno alle 7:00 (cron Supabase) `user_daily_
challenges` viene resettata. 6 challenges per utente (3 primarie + 3
   backup). Free user vede solo 1, premium tutte.
2. **Completion**: se admin -> evento creato direttamente. Se non
   admin -> `is_pending_approval = true` + notifica push agli admin via
   Edge Function `daily-challenge-notification`.
3. **Approval/Rejection**: admin chiama RPC
   `approve_daily_challenge` o `reject_daily_challenge`.
4. **Refresh**: ogni challenge swappabile una volta (RPC
   `update_challenge_refresh_status`).

## Convenzioni di progetto

### Nomi BLoC events / states

- `Get[Entity]Event`, `Create[Entity]Event`, `Update[Entity]Event`,
  `Delete[Entity]Event`
- States: `[Entity]Loading`, `[Entity]Loaded`, `[Entity]Error`
- Per stati globali transitori: `AuthProfileImageLoading`, ecc.

### Error handling

- Repository ritorna `Either<Failure, Success>` (mai eccezione
  che propaga oltre il layer)
- Remote datasource throwa `ServerException`
- Local datasource throwa `CacheException`
- Wrap database operations in `_tryDatabaseOperation()` helper per
  consistenza

### File / asset

- Models con `.g.dart` -> dopo modifica eseguire
  `flutter pub run build_runner build --delete-conflicting-outputs`
- UI text in italiano (l'app e' italian-only)
- Constants per feature in `lib/core/constants/[feature]/`
- Asset images registrate in `pubspec.yaml`

### Supabase SQL

Tutto il lavoro DB e' in `/supabase` (gitignored, backup separato).
Convention strutturale:

- **Schemi tabelle** (CREATE TABLE, enum, RLS sulla tabella) ->
  `supabase/schemas/` come "stato target"
- **Funzioni RPC / PL/pgSQL** (CREATE OR REPLACE FUNCTION) ->
  `supabase/db_functions/`
- **Triggers** (CREATE TRIGGER) -> `supabase/db_triggers/`
- **Migrazioni / ALTER / seed** -> `supabase/to-do/[descrittiva]/`
  con prefisso numerico (`01_*.sql`, `02_*.sql`) per ordine di
  esecuzione

Convenzioni per `to-do/`:

- **Idempotenti**: `CREATE ... IF NOT EXISTS`, `DROP ... IF EXISTS`,
  `ON CONFLICT DO ...`, `DO $$ ... EXCEPTION WHEN duplicate_object
THEN null END $$;`
- Ogni sottocartella ha `README.md` con scopo e ordine di esecuzione
  reale (a volte la dipendenza forza `01 -> 02 -> 04 -> 03`)
- Commenti in italiano, niente emoji, niente accentate

### Funzioni Supabase: best practices imparate

- **`SET search_path = public, auth, extensions`** su ogni funzione --
  `extensions` e' load-bearing per `uuid_generate_v4()`, `digest()`,
  `crypt()`, ecc. Senza, fallimenti con `42883 undefined_function`
  che PostgREST mappa a HTTP 404 confondente.
- **`SECURITY DEFINER`** quando la funzione tocca `auth.users` o
  schemi privilegiati. Aggiungere sempre `SET search_path` per evitare
  hijacking.
- **`#variable_conflict use_variable`** se la funzione dichiara
  variabili omonime a colonne di tabelle che tocca (es. `user_id`).
- **REVOKE EXECUTE FROM PUBLIC + GRANT esplicito a authenticated**
  per RPC SECURITY DEFINER esposte al client (`delete_user_account`,
  `reject_daily_challenge`). Anon resta fuori.
- **Trigger functions / webhook helpers**: REVOKE EXECUTE da tutti i
  ruoli applicativi -- girano via trigger engine / pg_net e non
  hanno bisogno di EXECUTE per il caller.

### Storage Supabase

3 bucket attivi:

- `user-logos/<userId>/<filename>` -- foto profilo
- `team-logos/<leagueId>/<filename>` -- logo squadra
- `memories/<leagueId>/<filename>` -- foto delle memories

RLS in `supabase/buckets/<bucket>/{insert,select,update,delete}_rls.sql`.
Pattern: `(split_part(name, '/', 1))::uuid` come prefix-folder che
identifica l'owner della scrittura.

**NB**: `DELETE FROM storage.objects` da ruoli non-storage e' bloccato
da Supabase anche con SECURITY DEFINER. Il cleanup va fatto lato
client via `supabaseClient.storage.from('...').remove([...])`.

## Gotchas (problemi che mordono)

1. **Service locator**: registrare le dipendenze in
   `init_dependencies.main.dart` PRIMA di usarle, altrimenti
   `serviceLocator<T>()` throws.
2. **ConnectionChecker al cold start**: il primo ping di
   `InternetConnection.hasInternetAccess` puo' tornare `false` per
   alcune centinaia di ms. Repository che fanno `if (!await
isConnected) return Right(...)` rischiano di svuotare cache senza
   accorgersene. Per query "live-only" (no fallback offline)
   semplificare con `try { await remote() } catch (_) { Left(...) }`.
3. **BLoC dispose**: i cubit globali NON si dismettono; i BLoC di
   feature si' (registrati come factory in DI).
4. **Hive init**: `_initializeHive()` deve completarsi prima di usare
   qualsiasi box.
5. **Firebase + Supabase**: entrambi presenti -- Firebase solo per
   FCM, Supabase per tutto il resto (auth, DB, storage, realtime).
6. **Italian everywhere**: tutto il testo UI e i messaggi di errore
   sono in italiano. Snackbar inclusi.
7. **build_runner dopo edit di model**: `.fromJson()/.toJson()`
   generati. Rigenerare con
   `flutter pub run build_runner build --delete-conflicting-outputs`.
8. **Rive 0.14 lifecycle**: `RiveWidgetController` non si auto-reload
   su cambio `path`. Il base widget `RiveAsset`
   (`lib/core/widgets/rive_asset.dart`) ha gia' la dispose+reload
   logic in `didUpdateWidget` -- se crei un nuovo consumer, eredita
   da quella classe.
9. **Seasonal default rules**: `lib/core/constants/rules/
seasonal_default_rules.dart` decide automaticamente
   winter/summer in base al mese (4-9 = summer). Niente deploy
   stagionale.
10. **Auth flow init**: `lib/main.dart` chiama
    `context.read<AppUserCubit>().getCurrentUser()` prima di
    qualsiasi screen. Dopo `_emitAuthSuccess` (in AuthBloc) viene
    propagato lo user a `AppUserCubit` per sync globale.

## File chiave da conoscere

- `lib/main.dart` -- entry point, init Firebase + Supabase + DI
- `lib/init_dependencies/init_dependencies.main.dart` -- DI graph
- `lib/core/cubits/app_user/app_user_cubit.dart` -- user state
- `lib/core/cubits/app_league/app_league_cubit.dart` -- league state +
  MemberProfile map
- `lib/features/auth/data/datasources/auth_remote_data_source.dart` --
  tutte le chiamate Supabase auth/storage
- `lib/features/league/data/repository/league_repository_impl.dart` --
  pattern cache + remote
- `lib/core/constants/navigation_items.dart` -- struttura navbar
- `supabase/db_functions/delete_user_account.sql` -- esempio di RPC
  SECURITY DEFINER ben fatta (search_path, variable_conflict,
  fasi numerate, FK consideration)

## Note operative

- **`/supabase` gitignored**: il lavoro DB non e' versionato in git.
  Backup separato. Quando aggiungi/modifichi SQL, salva sempre nel
  posto giusto (schemas / db_functions / db_triggers / to-do).
- **`previous-session.txt` gitignored**: scratchpad locale tra
  sessioni di lavoro con agenti.
- **AdMob in debug**: `lib/core/services/ad_helper.dart` ha
  `if (true) return testInterstitialAdUnitId`. Rimuovere prima del
  deploy.
- **Android debug build**: `android/app/build.gradle:65` ha
  `applicationIdSuffix ".debug"`. Causa PRODUCT_NOT_FOUND su IAP in
  debug build (in release il package id e' giusto).
- **Play Console 16 KB**: scadenza 31/05/2026. Script di check in
  `tools/check_16kb_alignment.sh`.
- **Git tag `archive/fantaserata-before-removal`**: codice del
  fantaserata rimosso, riferimento storico per pattern simili.

## Quando in dubbio

Mantieni i pattern esistenti. Il codebase prioritizza consistenza e
segue Clean Architecture. Non introdurre nuove librerie o nuovi
pattern senza ragione esplicita.
