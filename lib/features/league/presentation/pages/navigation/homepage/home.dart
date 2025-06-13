import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/core/widgets/events/events_list_widget.dart';
import 'package:fantavacanze_official/features/blog/presentation/widgets/article_page.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/create_league/create_league_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/events/add_event_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/homepage/widgets/action_buttons_row.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/homepage/widgets/admin_action_card.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/homepage/widgets/articles_list.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/homepage/widgets/daily_goals.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/join_league/search_league_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppLeagueCubit, AppLeagueState>(
      builder: (context, state) {
        // User has leagues and a selected league
        if (state is AppLeagueExists) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: _buildParticipantContent(context, state.selectedLeague),
          );
        }

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: _buildNonParticipantContent(context),
        );
      },
    );
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

  Widget _buildParticipantContent(BuildContext context, League league) {
    final isAdmin = context.read<LeagueBloc>().isAdmin();

    return Column(
      children: [
        DailyGoals(),

        // Admin section for creating events
        if (isAdmin) ...[
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
            child: CustomDivider(text: 'Nuovo Evento'),
          ),
          const SizedBox(height: 15),
          _buildAdminActions(context),
        ],

        // Latest events section (visible to everyone)
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
          child: CustomDivider(text: 'Ultimi Eventi'),
        ),
        const SizedBox(height: 15),

        // Use our new reusable component
        EventsListWidget(
          league: league,
          limit: 5,
          showAllEvents: true,
          onEventTap: (event) {
            // Handle event tap if needed
          },
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
        imagePath: 'assets/images/add-event-bg.jpg',
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
          imagePath: 'assets/images/tutorial.jpg',
          title: 'Come funziona il FantaVacanze?',
          readingTime: '3 minuti',
          redirectPage: ArticlePage(
            imagePath: 'assets/images/tutorial.jpg',
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

7. Divertimento Extra: Giochi Alcolici!\n
E per chi vuole aggiungere un pizzico di allegria in più, FantaVacanze include una sezione dedicata ai "Giochi Alcolici"!
- Come Usarli: Troverai idee e regole per giochi da fare in gruppo, perfetti per le serate in compagnia.
- Dentro e Fuori le Leghe: Questi giochi possono essere usati per creare eventi divertenti all'interno delle vostre leghe (magari con punti bonus!) oppure semplicemente per passare il tempo e divertirsi, anche al di fuori delle competizioni ufficiali.

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
Siamo Alex e Luca, due amici che hanno creato FantaVacanze con tanto entusiasmo e un pizzico di follia. Grazie per averci dedicato un momento del vostro tempo per conoscerci meglio!

1. La Scintilla di un'Idea\n
Tutto è iniziato durante una semplice grigliata estiva. Eravamo lì, tra amici, birre in mano e risate, quando ci siamo messi a ricordare le nostre vacanze passate. Tra aneddoti divertenti e storie assurde, è nata una domanda: "Non sarebbe fantastico avere un modo per rendere le vacanze ancora più divertenti e memorabili?"

Ed ecco l'illuminazione: un'app che trasforma la vacanza in un gioco, con sfide, punti e tanta competizione amichevole!

2. Solo Noi Due, Un Sogno Grande\n
Da quel momento, siamo stati solo noi due: Alex e Luca. Non una grande azienda, non un team di sviluppatori, non investitori alle spalle. Solo due ragazzi con un'idea e tanta, tanta voglia di realizzarla.

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
Alex e Luca
Il (piccolo ma appassionato) Team di FantaVacanze
            ''',
          ),
        ),
      ],
    );
  }
}
