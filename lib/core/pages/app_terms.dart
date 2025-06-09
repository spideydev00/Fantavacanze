import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:flutter/material.dart';

class AppTermsPage extends StatelessWidget {
  static const String routeName = '/app_terms';

  static get route => MaterialPageRoute(
        builder: (context) => const AppTermsPage(),
        settings: const RouteSettings(name: routeName),
      );

  const AppTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Termini e Condizioni',
          style: context.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Termini e Condizioni',
                style: context.textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: ThemeSizes.md),
            Center(
              child: Text(
                'Ultimo aggiornamento: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: context.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: ThemeSizes.xl),

            // 1. Introduzione
            GradientSectionDivider(
              text: 'Introduzione',
              sectionNumber: 1,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Benvenuti nell\'app Fantavacanze. Utilizzando la nostra applicazione, accetti i seguenti termini e condizioni che regolano l\'uso del nostro servizio.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 2. Requisiti di Età
            GradientSectionDivider(
              text: 'Requisiti di Età',
              sectionNumber: 2,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Fantavacanze è un\'app destinata esclusivamente a utenti che hanno almeno 18 anni di età. Accedendo e utilizzando questa app, dichiari e garantisci di avere almeno 18 anni. L\'app include contenuti e funzionalità appropriate solo per adulti.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 3. Privacy e Dati Personali
            GradientSectionDivider(
              text: 'Privacy e Dati Personali',
              sectionNumber: 3,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'La nostra Informativa sulla Privacy descrive come raccogliamo, utilizziamo e condividiamo i tuoi dati personali. Utilizzando Fantavacanze, acconsenti alle pratiche descritte nella nostra Informativa sulla Privacy.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 4. Codice di Condotta
            GradientSectionDivider(
              text: 'Codice di Condotta',
              sectionNumber: 4,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Gli utenti sono tenuti a comportarsi in modo rispettoso verso gli altri partecipanti. Non è consentito l\'utilizzo di linguaggio offensivo, molesto o discriminatorio. Ci riserviamo il diritto di rimuovere utenti che violano il codice di condotta.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 5. Contenuti dell'Utente
            GradientSectionDivider(
              text: 'Contenuti dell\'Utente',
              sectionNumber: 5,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Gli utenti possono caricare contenuti come foto e commenti. Caricando contenuti, garantisci di avere i diritti necessari su tali contenuti e concedi a Fantavacanze una licenza non esclusiva per utilizzarli in relazione ai servizi offerti. Ci riserviamo il diritto di rimuovere contenuti inappropriati o che violano questi termini.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 6. Proprietà Intellettuale
            GradientSectionDivider(
              text: 'Proprietà Intellettuale',
              sectionNumber: 6,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Tutti i diritti di proprietà intellettuale relativi all\'app e ai suoi contenuti (esclusi i contenuti generati dagli utenti) appartengono a Fantavacanze o ai suoi licenziatari. Non è consentito utilizzare, copiare o distribuire qualsiasi parte dell\'app senza autorizzazione.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 7. Limitazione di Responsabilità
            GradientSectionDivider(
              text: 'Limitazione di Responsabilità',
              sectionNumber: 7,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Fantavacanze non è responsabile per danni diretti, indiretti, incidentali, conseguenti o punitivi derivanti dall\'uso o dall\'impossibilità di utilizzare l\'app. L\'app è fornita "così com\'è" senza garanzie di alcun tipo.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 8. Modifiche ai Termini
            GradientSectionDivider(
              text: 'Modifiche ai Termini',
              sectionNumber: 8,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Ci riserviamo il diritto di modificare questi Termini in qualsiasi momento. Le modifiche saranno efficaci dopo la pubblicazione dei Termini aggiornati nell\'app. L\'uso continuato dell\'app dopo tali modifiche costituisce accettazione dei nuovi Termini.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 9. Legge Applicabile
            GradientSectionDivider(
              text: 'Legge Applicabile',
              sectionNumber: 9,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Questi Termini sono regolati e interpretati in conformità con le leggi italiane, senza riguardo ai principi di conflitto di leggi.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 10. Contatti
            GradientSectionDivider(
              text: 'Contatti',
              sectionNumber: 10,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Per domande o dubbi sui nostri Termini e Condizioni, contattaci all\'indirizzo email: supporto@fantavacanze.it',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.xxl),
          ],
        ),
      ),
    );
  }
}
