# Fantavacanze

Fantavacanze è un'app in Flutter pensata per competere in modo divertente mentre si è in vacanza o, semplicemente, durante una serata in discoteca 🪩 ♥️.

## Tecnologie Utilizzate

Il progetto è implementato usando la **CLEAN Architecture**. Per riferimento guardare l'introduzione (circa 1 ora) del seguente [VIDEO](https://www.youtube.com/watch?v=ELFORM9fmss).

- 💾 Il database usato per l'autenticazione e come storage è **Supabase**. Tramite un cubit (**flutter_bloc**) si verifica se nella corrente sessione esiste un utente (quindi c'è un token di accesso attivo) e, in tal caso, si reindirizza direttamente alla home page. Altrimenti bisgna effettuare il login.

- 🚀 Utilizzato il package di flutter **get_it** per la _"dependency injection"_

- 📦 Utilizzato **hive** per la creazione di _"box"_ per il salvataggio locale dei dati (**caching**). Il tutto assieme al package **internet_connection_checker_plus** per la verifica della connessione internet sul dispositivo e per scegliere da dove caricare i dati.

- Utilizzato **fpdart** per la _"programmazione funzionale"_.

## Architettura del Progetto

### Clean Architecture Structure

- **Data Layer**: `lib/features/[feature]/data/` - modelli, repository, datasources
- **Domain Layer**: `lib/features/[feature]/domain/` - entità, use cases, interfacce repository
- **Presentation Layer**: `lib/features/[feature]/presentation/` - UI, BLoC, pagine

### State Management Globale (`lib/core/cubits/`)

Cubits singleton gestiscono lo stato globale dell'app:

1. **`app_user/`**: Stato di autenticazione dell'utente corrente
2. **`app_league/`**: Appartenenze alle leghe dell'utente
3. **`app_navigation/`**: Gestione indice navigazione bottom
4. **`app_theme/`**: Tema scuro/chiaro con persistenza SharedPreferences
5. **`app_status/`**: Flag manutenzione letto da Supabase (`application_status`)
6. **`app_version/`**: Force update gate basato su `app_version_config` per piattaforma
7. **`seasonal_event/`**: Gestione eventi stagionali e promozioni speciali

### Features Principali

#### Auth Feature (`lib/features/auth/`)

Sistema di autenticazione completo:

- OAuth (Google/Apple) e email/password tramite Supabase
- Gestione stato utente globale
- Integrazione RevenueCat per abbonamenti premium

#### League Feature (`lib/features/league/`)

Funzionalità core per gestire leghe competitive:

- Leghe personalizzabili con partecipanti individuali o squadre
- Sistema sfide giornaliere con approvazione admin
- Gestione eventi, regole, ricordi e note
- Sistema notifiche in tempo reale

#### App Feature (`lib/features/app/`)

Gate globali a livello applicazione, controllati da Supabase:

- **App status**: schermata di manutenzione (`AppUnavailablePage`) attivabile
  via flag su `application_status`
- **Force update**: blocco aggiornamento (`ForceUpdatePage`) quando la versione
  locale è inferiore a `min_supported_version` su `app_version_config`. Il
  confronto usa `pub_semver`; il bottone "Aggiorna ora" apre lo store via
  `url_launcher`

#### Games Feature (`lib/features/games/`)

Sistema gaming multiplayer in tempo reale:

- Truth or Dare, Word Bomb, Never Have I Ever
- Gestione lobby e sessioni di gioco
- Sincronizzazione real-time tramite Supabase

### Struttura File Principali

```
lib/
├── core/
│   ├── constants/           # Costanti per feature
│   ├── cubits/             # State management globale
│   ├── entities/           # Entità condivise
│   ├── services/           # Servizi core (ads, GDPR, review, share)
│   ├── theme/              # Sistema temi e colori
│   └── widgets/            # Componenti UI riutilizzabili
├── features/
│   ├── app/                # Gate globali (manutenzione, force update)
│   ├── auth/               # Autenticazione
│   ├── league/             # Leghe e sfide giornaliere
│   └── games/              # Giochi multiplayer
└── init_dependencies/      # Dependency injection setup
```

### Backend Supabase (`supabase/`, gitignored)

Schemi tabelle in `supabase/schemas/`, funzioni RPC in `supabase/db_functions/`,
trigger in `supabase/db_triggers/`. Le migrazioni / script da eseguire al
prossimo deploy vivono in `supabase/to-do/[sottocartella]/` numerati per
ordine di esecuzione e idempotenti.

## Il concept

L'idea è quella di creare un gioco per stimolare le interazioni sociali nella vita reale. L'app è così strutturata:

- ✅ **Leghe personalizzabili**: Possibilità di creare una lega con i propri amici o unirsi ad una già esistente. Supporta partecipanti individuali o squadre con capitano.

- ✅ **Bonus e malus**: Ogni azione conta! Si possono guadagnare punti bonus per le conquiste amorose e perdere punti attraverso i malus. Si può usare un set di regole predefinite e personalizzate, oppure utilizzare solamente le proprie regole.

- ✅ **Sezione Ricordi**: Ogni foto-ricordo sarà una testimonianza di un momento indimenticabile, inseribile all'interno di cartelle personalizzate. Supporta foto e video con gestione eventi collegati.

- ✅ **Giochi alcolici**: Sfide e passatempi UNICI che renderanno ogni momento ancora più speciale. Include Truth or Dare, Word Bomb e Never Have I Ever con modalità multiplayer real-time.

- 🎉 **Eventi stagionali**: Contenuti speciali, promozioni e funzionalità a tempo limitato che rendono l'app sempre fresca e coinvolgente durante le festività e occasioni speciali.

- 📱 **Sfide giornaliere**: Sistema complesso di sfide quotidiane con generazione automatica, sistema di approvazione admin e notifiche push. Premium users vedono tutte le 6 sfide, free users ne vedono 1.

- 🔔 **Notifiche real-time**: Integrazione Firebase FCM + Supabase realtime per aggiornamenti istantanei su eventi, approvazioni admin e attività di gioco.

## Workflow di Sviluppo

### Aggiunta Nuove Features

1. Creare struttura cartelle sotto `lib/features/[feature_name]/`
2. Definire entità in `domain/entities/`
3. Creare interfaccia repository in `domain/repository/`
4. Implementare modelli in `data/models/` che estendono le entità
5. Implementare datasources remote/local in `data/datasources/`
6. Implementare repository in `data/repository/`
7. Creare use cases in `domain/use_cases/`
8. Registrare tutte le dipendenze in `init_dependencies.main.dart`
9. Creare BLoC in `presentation/bloc/`
10. Costruire UI in `presentation/pages/`

### Comandi Essenziali

```bash
# Genera adattatori Hive
flutter packages pub run build_runner build

# Esegui con debug/release
flutter run --debug
flutter run --release
```

## Copyright e utilizzo del codice

Il codice sorgente di questo progetto è protetto dal diritto d'autore ai sensi della normativa vigente.  
**È vietata la copia, la distribuzione, la modifica o l'utilizzo non autorizzato del codice, anche parziale, senza il consenso esplicito dell'autore.**

Chi viola il copyright può incorrere in conseguenze legali, tra cui:

- Richiesta di rimozione del materiale copiato (take-down)
- Richiesta di risarcimento danni
- Azioni civili e, nei casi più gravi, penali

Per richieste di utilizzo, collaborazione o licenza, contattare l'autore del progetto (alexspideydev@gmail.com).

## Conclusione

L'app è uscita ufficialmente a Giugno 2025, per vivere a pieno i due mesi d'Estate rimanenti!
