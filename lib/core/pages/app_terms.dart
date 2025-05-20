import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class AppTermsPage extends StatelessWidget {
  static get route => MaterialPageRoute(
        builder: (context) => AppTermsPage(),
      );

  const AppTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termini e Condizioni'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Termini e Condizioni',
              style: context.textTheme.headlineMedium,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Ultimo aggiornamento: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: context.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: ThemeSizes.xl),

            // 1. Introduzione
            Text(
              '1. Introduzione',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: ThemeSizes.sm),
            Text(
              'Benvenuti nell\'app Fantavacanze. Utilizzando la nostra applicazione, accetti i seguenti termini e condizioni che regolano l\'uso del nostro servizio.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 2. Requisiti di Età
            Text(
              '2. Requisiti di Età',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: ThemeSizes.sm),
            Text(
              'Fantavacanze è un\'app destinata esclusivamente a utenti che hanno almeno 18 anni di età. Accedendo e utilizzando questa app, dichiari e garantisci di avere almeno 18 anni. L\'app include contenuti e funzionalità appropriate solo per adulti.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 3. Privacy e Dati Personali
            Text(
              '3. Privacy e Dati Personali',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: ThemeSizes.sm),
            Text(
              'La nostra Informativa sulla Privacy descrive come raccogliamo, utilizziamo e condividiamo i tuoi dati personali. Utilizzando Fantavacanze, acconsenti alle pratiche descritte nella nostra Informativa sulla Privacy.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 4. Codice di Condotta
            Text(
              '4. Codice di Condotta',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: ThemeSizes.sm),
            Text(
              'Gli utenti sono tenuti a comportarsi in modo rispettoso verso gli altri partecipanti. Non è consentito l\'utilizzo di linguaggio offensivo, molesto o discriminatorio. Ci riserviamo il diritto di rimuovere utenti che violano il codice di condotta.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 5. Limitazione di Responsabilità
            Text(
              '5. Limitazione di Responsabilità',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: ThemeSizes.sm),
            Text(
              'Fantavacanze non è responsabile per danni diretti, indiretti, incidentali, conseguenti o punitivi derivanti dall\'uso o dall\'impossibilità di utilizzare l\'app.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 6. Modifiche ai Termini
            Text(
              '6. Modifiche ai Termini',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: ThemeSizes.sm),
            Text(
              'Ci riserviamo il diritto di modificare questi Termini in qualsiasi momento. Le modifiche saranno efficaci dopo la pubblicazione dei Termini aggiornati nell\'app.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.xxl),
          ],
        ),
      ),
    );
  }
}
