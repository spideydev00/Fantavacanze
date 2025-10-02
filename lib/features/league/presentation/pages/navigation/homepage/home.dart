import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/cubits/seasonal_event/seasonal_event_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/services/seasonal_event_service.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/core/widgets/events/events_list_widget.dart';
import 'package:fantavacanze_official/features/blog/presentation/widgets/article_page.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/pages/fs_router_page.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/create_league/create_league_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/events/add_event_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/homepage/widgets/action_buttons_row.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/homepage/widgets/admin_action_card.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/homepage/widgets/articles_list.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/homepage/widgets/daily_goals.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/join_league/search_league_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/widgets/bottom_navbar/animated_floating_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AppUserCubit>().state;
    final currentUserId =
        currentUser is AppUserIsLoggedIn ? currentUser.user.id : null;

    // Variable to store the show button callback
    void Function()? showFloatingButton;

    return Scaffold(
      body: GestureDetector(
        // Add gesture detection for showing floating button
        onPanEnd: (DragEndDetails details) {
          // Swipe verso sinistra per mostrare il floating button
          if (details.velocity.pixelsPerSecond.dx < -500) {
            showFloatingButton?.call();
          }
        },
        child: BlocBuilder<AppLeagueCubit, AppLeagueState>(
          builder: (context, state) {
            // User has leagues and a selected league
            if (state is AppLeagueExists) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    _buildParticipantContent(
                        context,
                        state.selectedLeague.admins.contains(currentUserId)
                            ? true
                            : false,
                        state.selectedLeague),
                    // _buildSeasonalTestForm(context),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  _buildNonParticipantContent(context),
                  // _buildSeasonalTestForm(context),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: AnimatedFloatingActionButton(
        onPressed: () => _handleFantaSerataNavigation(context),
        onRegisterShowCallback: (showCallback) {
          // Register the callback to show the button
          showFloatingButton = showCallback;
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _handleFantaSerataNavigation(BuildContext context) async {
    // Naviga direttamente alla pagina router
    Navigator.of(context).pushReplacement(FsRouterPage.route);
  }

  Widget _buildNonParticipantContent(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
          child: CustomDivider(text: "Per Iniziare"),
        ),
        const SizedBox(height: 25),
        _buildActionButtons(context),
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
          child: CustomDivider(text: 'I Nostri Articoli'),
        ),
        _buildArticles(),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildParticipantContent(
      BuildContext context, bool isAdmin, League league) {
    return Column(
      children: [
        DailyGoals(),
        const SizedBox(height: 15),
        // Admin section for creating events
        if (isAdmin) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
            child: CustomDivider(
              text: 'Nuovo Evento',
              hasDropdown: true,
              dropdownText: "Clicca qui per aggiungere un bonus o un malus",
            ),
          ),
          const SizedBox(height: 15),
          _buildAdminActions(context),
        ],

        // Latest events section
        const SizedBox(height: 25),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
          child: CustomDivider(
            text: 'Ultimi Eventi',
            hasDropdown: true,
            dropdownText: isAdmin
                ? 'Fai scroll verso sinistra su un evento per eliminarlo rimuovere i punti associati.'
                : 'Qui puoi consultare gli ultimi eventi.',
          ),
        ),

        const SizedBox(height: 15),

        // Events list with dismiss capability for admins only
        EventsListWidget(
          league: league,
          showAllEvents: true,
          allowDismiss: isAdmin,
          onEventDismiss: isAdmin
              ? (event) {
                  context.read<LeagueBloc>().add(
                        RemoveEventEvent(
                          league: league,
                          eventId: event.id,
                        ),
                      );
                }
              : null,
        ),

        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildAdminActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
      child: AdminActionCard(
        title: 'Aggiungi un nuovo evento',
        imagePath: 'assets/images/add-event-bg-fall-winter.png',
        iconData: Icons.add,
        onTap: () => _navigateToAddEvent(context),
      ),
    );
  }

  void _navigateToAddEvent(BuildContext context) {
    Navigator.push(
      context,
      AddEventPage.route,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ActionButtonsRow(
      buttons: [
        ActionButtonData(
          title: "Crea Lega",
          icon: Icons.add_circle_outline_sharp,
          onPressed: () {
            Navigator.push(
              context,
              CreateLeaguePage.route,
            );
          },
        ),
        ActionButtonData(
          title: "Cerca Lega",
          icon: Icons.search_rounded,
          onPressed: () {
            Navigator.push(
              context,
              SearchLeaguePage.route,
            );
          },
        ),
      ],
    );
  }

  Widget _buildArticles() {
    return ArticlesList(
      articles: [
        ArticleData(
          imagePath: 'assets/images/tutorial-1.png',
          title: 'Come funziona il FantaSerata?',
          readingTime: '3 minuti',
          redirectPage: ArticlePage(
            imagePath: 'assets/images/tutorial-1.png',
            title: 'Come funziona il FantaSerata?',
            author: 'Fantavacanze Team',
            publishDate: '2025-10-02',
            content: '''
Benvenuto in **FantaSerata**, la modalità lampo di Fantavacanze pensata per una sola notte. Si gioca forte, si ride tanto… e alle **7:00 del mattino la lega si autodistrugge**. Pronti a dare tutto entro l’alba?

1. Leghe a Tempo: il brivido della mezzanotte\n
FantaSerata funziona con **leghe temporanee** create al volo con gli amici.
- **Durata**: dalla creazione fino alle **07:00** del giorno successivo. Poi *boom*: si chiude tutto, classifica compresa.
- **Tutti sono Admin**: sì, proprio così. Ognuno può gestire regole, modificare obiettivi, approvare/eliminare eventi e invitare persone. Massima libertà = massima responsabilità.

2. Il set base: Bonus, Malus e Obiettivi Speciali\n
Ogni lega parte con tre blocchi già pronti:
- **5 Bonus fissi** (es. “Arrivo puntuale”, “Giro drink condiviso”, “DJ improvvisato”, “Nuova conoscenza”, “Ballata epica”).
- **5 Malus fissi** (es. “Ritardo da bradipo”, “Messaggi all’ex”, “Bicchiere rovesciato”, “Canzone stoppata”, “Selfie mosso”).
- **3 Obiettivi Speciali**: più “particolari”, più difficili… **e valgono più punti**. Ognuno di questi **è refreshabile una sola volta** se non ti convince (ne arriva un altro al suo posto).

3. Obiettivi Extra: la fantasia al potere\n
Oltre al set base, **ogni utente può aggiungere obiettivi extra** validi per tutta la lega. Esempi:
- “Foto con sconosciuti a tema”, “Portare il gruppo in un locale nuovo”, “Indovinare la canzone in 3 secondi”.
Suggerimento: descrivi bene come si completa e quanti punti vale per evitare discussioni a fine notte.

4. Come si fanno punti (e come si approvano gli eventi)\n
- Quando completi un obiettivo, **crei un evento** dall’app.
- Visto che **tutti sono Admin**, gli eventi possono essere **approvati o eliminati** da chiunque. Se vi fidate, approvate; se è un meme, via.
- Ogni approvazione aggiorna **in tempo reale la classifica**.

5. Classifica Live e Giornale Eventi\n
- **Classifica aggiornata**: vedi chi è in fuga, chi recupera e chi sta “gestendo”.
- **Giornale Eventi**: lo stream di tutto ciò che succede nella lega. Se qualcosa è stato segnato con troppa fantasia… **si può eliminare**.

6. Il Trofeo dell’Alba: foto del vincitore e condivisione\n
Alle **07:00** la lega si chiude e proclama il **vincitore**.
- Il vincitore può **caricare una foto-trofeo** (la “foto dell’alba”) e **condividerla sui social** direttamente dall’app.
- La foto resta come memoria della serata (prima della *auto-distruzione* dei dettagli operativi).

7. Serate Speciali: regole “uniche” che cambiano il gioco\n
In alcuni periodi, FantaSerata attiva **regole speciali** tematiche che sostituiscono/affiancano il set base. Ecco gli highlight:

- **Serata di Halloween**\n
    - Bonus: “Miglior costume”, “Urlo da cinema”, “Dolcetto & Scherzetto completato con sconosciuti”.\n
    - Malus: “Maschera tolta prima di mezzanotte”, “Tema non rispettato”.\n
    - Special: “Foto con personaggio ‘spaventoso’”, “Indizio risolto in una caccia horror”. Punti extra se la foto è *veramente* inquietante.

- **Vigilia (24 dicembre)**\n
    - Bonus: “Canzone natalizia cantata in coro”, “Brindisi con augurio creativo”, “Scambio di mini-regali”.\n
    - Malus: “Interrompere un coro”, “Saltare il brindisi del minuto”.\n
    - Special: “Foto con Babbo improvvisato”, “Panettone vs Pandoro: degustazione imparziale documentata”.

- **Capodanno (31 dicembre)**\n
    - Bonus: “Countdown guidato”, “Primo abbraccio dell’anno”, “Chiamata d’auguri a chilometri”.\n
    - Malus: “Countdown sbagliato”, “Sparizione a mezzanotte senza saluti”.\n
    - Special: “Video del ‘primo ballo dell’anno’”, “Obiettivo ‘Nuovo Anno, Nuovo Meme’ (creazione di meme live)”.

- **Carnevale**\n
    - Bonus: “Maschera di gruppo”, “Coreografia improvvisata in strada”, “Battaglia di coriandoli con sconosciuti”.\n
    - Malus: “Costume incompleto”, “Coriandoli senza sorriso (documentato)”.\n
    - Special: “Scambio maschera per 10 minuti”, “Foto con personaggi storici/fiabeschi”.

- **Après-Ski (da dicembre a fine gennaio)**\n
    - Bonus: “Brindisi in baita”, “Coro sul terrazzo”, “Occhiali da sole anche al tramonto (stile impeccabile)”.\n
    - Malus: “Guanti smarriti”, “Hot chocolate rovesciata”.\n
    - Special: “Selfie con impronta degli scarponi”, “‘Trenino’ documentato al rifugio”. Punti boost se compare la neve nella foto.

8. Fair Play rapido (per evitare drammi alle 03:00)\n
- **Descrivi bene** gli obiettivi extra (criteri chiari = meno discussioni).\n
- In caso di dubbio, **il Giornale Eventi è la verità storica**: si guarda lì e si decide.\n
- Ricorda: **tutti Admin** significa velocità, ma anche buon senso. L’obiettivo è divertirsi, non fare il VAR della movida.

9. Pronti, via: crea la tua FantaSerata\n
- Crea la lega, invita gli amici, scegliete il tema (se festivo, attivate le **regole speciali**), puntate gli obiettivi… e correte verso l’alba.\n
- Alle **07:00** si chiude: **classifica finale**, **foto del vincitore**, condivisione… e appuntamento alla prossima!

Che vinca la notte più epica! 🌙✨
    ''',
          ),
        ),
        ArticleData(
          imagePath: 'assets/images/tutorial.png',
          title: 'Come funziona il FantaVacanze?',
          readingTime: '3 minuti',
          redirectPage: ArticlePage(
            imagePath: 'assets/images/tutorial.png',
            title: 'Come funziona il FantaVacanze?',
            author: 'Fantavacanze Team',
            publishDate: '2025-06-01',
            content: '''
Benvenuto in FantaVacanze, l'app che trasforma la tua vacanza in un'epica competizione social con i tuoi amici! Ecco come funziona:

1. Le Leghe: Il Cuore della Sfida\n
FantaVacanze ruota attorno alle "Leghe". Una lega è un gruppo privato dove tu e i tuoi amici potete sfidarvi.
- Creazione: Qualsiasi utente può creare una lega e ne diventa automaticamente l'amministratore (Admin).
- Amministrazione: Gli Admin gestiscono la lega, possono aggiungere altri Admin, definire le regole iniziali e approvare gli obiettivi.
- Partecipazione: Puoi unirti a leghe esistenti create dai tuoi amici o crearne una tua e invitarli.

2. Chi Partecipa? Tu e i Tuoi Amici!\n
All'interno di una lega, i partecipanti possono essere:
- Individuali: Ogni persona gioca per sé.
- Team: Gruppi di amici possono formare dei team all'interno della lega. Ogni team ha un capitano (solitamente chi lo crea) che può gestire la squadra.

3. Guadagnare Punti: Eventi e Obiettivi\n
Il succo del gioco è accumulare punti completando "Eventi" o "Obiettivi". Questi possono essere:
- Definiti alla Creazione della Lega: L'Admin che crea la lega può stabilire una serie di obiettivi iniziali basati su regole personalizzate.
- Aggiunti Manualmente dagli Admin: Durante la vacanza, gli Admin possono inserire nuovi eventi o sfide per mantenere viva la competizione.

4. Sfide Quotidiane (Daily Challenges): Ogni Giorno una Nuova Avventura!\n
Per rendere le cose ancora più frizzanti, ci sono le "Daily Challenges":
- Cosa Sono: Sfide giornaliere che si resettano automaticamente ogni mattina alle 7:00.
- Quante: Ogni utente riceve 6 sfide al giorno: 3 principali e 3 di riserva.
- Utenti Premium vs. Free: Gli utenti Premium possono vedere tutte e 6 le sfide fin da subito. Gli utenti Free ne vedono una principale alla volta.
- Refresh: Hai a disposizione un refresh per ogni sfida principale. Se usi il refresh, la sfida principale viene sostituita con la sua sfida di riserva corrispondente.
- Completamento e Approvazione:
    - Quando completi una Daily Challenge, lo segnali nell'app.
    - Se sei un Admin della lega, l'obiettivo viene approvato automaticamente e si trasforma in un evento che ti fa guadagnare punti.
    - Se non sei un Admin, viene inviata una notifica a tutti gli Admin della lega. Uno di loro dovrà approvare il tuo completamento (creando l'evento e assegnandoti i punti) o rifiutarlo.

5. Sezione Memories: I Ricordi della Vacanza\n
C'è una sezione speciale chiamata "Memories" dove puoi postare foto ricordo della tua vacanza, creando un album collettivo delle avventure della lega.

6. Note Personali: Non Dimenticare Nulla!\n
Hai bisogno di appuntarti qualcosa al volo? Usa la sezione "Note"! Sono promemoria temporanei, salvati solo sul tuo dispositivo, utili per non scordarti aneddoti divertenti o idee per nuove sfide.

7. Divertimento Extra: Giochi!\n
E per chi vuole aggiungere un pizzico di allegria in più, FantaVacanze include una sezione dedicata a giochi da fare in compagnia!
- Come Usarli: Troverai idee e regole per giochi da fare in gruppo, perfetti per le serate in compagnia.

Inizia la Tua FantaVacanza!\n
Crea la tua lega, invita i tuoi amici, completa obiettivi, supera le Daily Challenges e, soprattutto, divertiti! Che la FantaVacanza migliore vinca!
            ''',
          ),
        ),
        ArticleData(
          imagePath: 'assets/images/about-us.jpg',
          title: 'Chi siamo? Com\'è nata l\'idea?',
          readingTime: '2 minuti',
          redirectPage: ArticlePage(
            imagePath: 'assets/images/about-us.jpg',
            title: 'Chi siamo? Com\'è nata l\'idea?',
            author: 'Fantavacanze Team',
            publishDate: '2025-06-01',
            content: '''
Siamo Alex, Luca e Alessandro, tre amici che hanno creato FantaVacanze con tanto entusiasmo e un pizzico di follia. Grazie per averci dedicato un momento del vostro tempo per conoscerci meglio!

1. La Scintilla di un'Idea\n
Tutto è iniziato durante una semplice grigliata estiva. Eravamo lì, tra amici, birre in mano e risate, quando ci siamo messi a ricordare le nostre vacanze passate. Tra aneddoti divertenti e storie assurde, è nata una domanda: "Non sarebbe fantastico avere un modo per rendere le vacanze ancora più divertenti e memorabili?"

Ed ecco l'illuminazione: un'app che trasforma la vacanza in un gioco, con sfide, punti e tanta competizione amichevole!

2. Solo Noi Tre, Un Sogno Grande\n
Da quel momento, siamo stati solo noi due: Alex, Luca ed Alessandro. Non una grande azienda, non un team di sviluppatori, non investitori alle spalle. Solo tre ragazzi con un'idea e tanta, tanta voglia di realizzarla.

Le notti in bianco a programmare dopo il lavoro, i weekend sacrificati, le innumerevoli pizze ordinate mentre cercavamo di capire come risolvere un bug particolarmente ostinato... è stato un viaggio intenso, a volte estenuante, ma sempre entusiasmante.

3. Perché l'Abbiamo Fatto?\n
Semplice: amiamo divertirci e vogliamo che anche voi possiate farlo! La vita è già abbastanza seria di suo, e le vacanze dovrebbero essere il momento in cui ci si lascia andare completamente.

FantaVacanze è nato con un unico scopo: rendere le vostre vacanze indimenticabili, aggiungendo quel pizzico di competizione che rende tutto più interessante. Che siate in spiaggia, in montagna o in un'altra città, vogliamo che ogni giorno sia un'avventura.

4. Un Grazie di Cuore\n
Se stai leggendo questo, probabilmente hai scaricato la nostra app, e questo significa il mondo per noi. Letteralmente. Ogni singola persona che usa FantaVacanze ci dà la motivazione per continuare a migliorarla.

Sappiamo che ci sono ancora tante cose da perfezionare (e forse qualche bug da correggere... ops!), ma ci stiamo impegnando al massimo per offrirvi la migliore esperienza possibile.

5. Il Futuro di FantaVacanze\n
Abbiamo grandi progetti per il futuro, ma il nostro focus rimane lo stesso: il vostro divertimento. Ogni nuova funzionalità, ogni miglioramento che implementiamo ha come unico scopo quello di rendere le vostre vacanze ancora più memorabili.

Quindi... grazie. Grazie per credere in noi, grazie per usare la nostra app, grazie per essere parte di questa avventura.

Con affetto e gratitudine,\n
Alex, Luca ed Alessandro
Il (piccolo ma appassionato) Team di FantaVacanze
            ''',
          ),
        ),
      ],
    );
  }

  //====================================//
  //SEASONAL TEST FORM//
  //====================================//
  Widget _buildSeasonalTestForm(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(ThemeSizes.lg),
      padding: const EdgeInsets.all(ThemeSizes.md),
      decoration: BoxDecoration(
        color: context.secondaryBgColor,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        border: Border.all(
          color: context.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.science_rounded,
                color: context.primaryColor,
                size: ThemeSizes.iconSm,
              ),
              const SizedBox(width: ThemeSizes.sm),
              Text(
                'Test Stagioni (Solo Sviluppo)',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: ThemeSizes.sm),
          Text(
            'Imposta una data manuale per testare le funzionalità stagionali',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.textSecondaryColor,
            ),
          ),
          const SizedBox(height: ThemeSizes.md),

          // Current status
          BlocBuilder<SeasonalEventCubit, SeasonalEventState>(
            builder: (context, state) {
              final seasonalService = serviceLocator<SeasonalEventService>();

              return Container(
                padding: const EdgeInsets.all(ThemeSizes.sm),
                decoration: BoxDecoration(
                  color: context.bgColor,
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stato Attuale:',
                      style: context.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: ThemeSizes.xs),
                    Text(
                      'Modalità: ${seasonalService.isInTestMode ? "Test" : "Normale"}',
                      style: context.textTheme.bodySmall,
                    ),
                    if (seasonalService.isInTestMode) ...[
                      Text(
                        'Data Test: ${_formatDate(seasonalService.currentTestDate!)}',
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                    Text(
                      'Stagione: ${state.displayName}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: ThemeSizes.md),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _selectTestDate(context),
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: const Text('Imposta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: ThemeSizes.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _clearTestDate(context),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.primaryColor,
                    side: BorderSide(color: context.primaryColor),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: ThemeSizes.sm),

          // Quick date buttons
          Wrap(
            spacing: ThemeSizes.xs,
            runSpacing: ThemeSizes.xs,
            children: [
              _buildQuickDateButton(
                context,
                'Halloween',
                DateTime(2024, 10, 31),
              ),
              _buildQuickDateButton(
                context,
                'Natale',
                DateTime(2024, 12, 24),
              ),
              _buildQuickDateButton(
                context,
                'Capodanno',
                DateTime(2024, 12, 31),
              ),
              _buildQuickDateButton(
                context,
                'Carnevale',
                DateTime(2025, 2, 14),
              ),
              _buildQuickDateButton(
                context,
                'Après Ski',
                DateTime(2024, 12, 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDateButton(
      BuildContext context, String label, DateTime date) {
    return InkWell(
      onTap: () => _setTestDate(context, date),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeSizes.sm,
          vertical: ThemeSizes.xs,
        ),
        decoration: BoxDecoration(
          color: context.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusSm),
          border: Border.all(
            color: context.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _selectTestDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2025, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: context.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && context.mounted) {
      _setTestDate(context, picked);
    }
  }

  void _setTestDate(BuildContext context, DateTime date) {
    final seasonalService = serviceLocator<SeasonalEventService>();
    seasonalService.setTestDate(date);

    // Refresh the seasonal event cubit
    context.read<SeasonalEventCubit>().refreshSeasonalEvent();

    // Show confirmation
    showSnackBar(
      'Data di test impostata: ${_formatDate(date)}',
      color: ColorPalette.warning,
    );
  }

  void _clearTestDate(BuildContext context) {
    final seasonalService = serviceLocator<SeasonalEventService>();
    seasonalService.clearTestDate();

    // Refresh the seasonal event cubit
    context.read<SeasonalEventCubit>().refreshSeasonalEvent();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
