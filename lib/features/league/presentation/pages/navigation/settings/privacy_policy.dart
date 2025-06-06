import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  static const String routeName = '/privacy_policy';

  static get route => MaterialPageRoute(
        builder: (context) => const PrivacyPolicyPage(),
        settings: const RouteSettings(name: routeName),
      );

  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
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
                'Privacy Policy',
                style: context.textTheme.headlineSmall!.copyWith(
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
              'La presente Privacy Policy descrive come raccogliamo, utilizziamo e condividiamo i tuoi dati personali quando utilizzi la nostra applicazione Fantavacanze.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 2. Dati raccolti
            GradientSectionDivider(
              text: 'Dati che raccogliamo',
              sectionNumber: 2,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Raccogliamo i seguenti tipi di informazioni:\n\n'
              '• Informazioni di registrazione: nome, e-mail e password (se utilizzi la registrazione via e-mail).\n'
              '• Informazioni di profilo: nome utente e foto profilo (opzionale).\n'
              '• Contenuti generati dagli utenti: foto, commenti e post che condividi all\'interno delle leghe.\n'
              '• Dati di utilizzo: informazioni su come utilizzi l\'app, quali funzionalità utilizzi e quando.\n'
              '• Informazioni sul dispositivo: sistema operativo, versione dell\'app e identificatori univoci del dispositivo.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 3. Come utilizziamo i dati
            GradientSectionDivider(
              text: 'Come utilizziamo i tuoi dati',
              sectionNumber: 3,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Utilizziamo i tuoi dati per:\n\n'
              '• Fornirti i servizi dell\'app Fantavacanze.\n'
              '• Permetterti di creare e partecipare a leghe, accumulare punti e interagire con altri utenti.\n'
              '• Migliorare e personalizzare l\'esperienza utente.\n'
              '• Risolvere problemi tecnici e migliorare la sicurezza dell\'app.\n'
              '• Comunicare con te riguardo aggiornamenti o modifiche ai nostri servizi.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 4. Condivisione dei dati
            GradientSectionDivider(
              text: 'Condivisione dei dati',
              sectionNumber: 4,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Condividiamo le tue informazioni solo nelle seguenti circostanze:\n\n'
              '• Con altri membri della tua lega, limitatamente alle informazioni necessarie per il funzionamento della lega.\n'
              '• Con fornitori di servizi che ci aiutano a gestire l\'app (come servizi di hosting, analisi e assistenza clienti).\n'
              '• Se richiesto dalla legge o per proteggere i nostri diritti.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 5. Sicurezza
            GradientSectionDivider(
              text: 'Sicurezza dei dati',
              sectionNumber: 5,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Adottiamo misure di sicurezza tecniche e organizzative per proteggere i tuoi dati personali. Tuttavia, nessun sistema è completamente sicuro, quindi non possiamo garantire la sicurezza assoluta dei tuoi dati.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 6. Conservazione dei dati
            GradientSectionDivider(
              text: 'Conservazione dei dati',
              sectionNumber: 6,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Conserviamo i tuoi dati personali solo per il tempo necessario a fornirti i nostri servizi o per soddisfare i requisiti legali. Puoi richiedere la cancellazione del tuo account in qualsiasi momento.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 7. Diritti dell'utente
            GradientSectionDivider(
              text: 'I tuoi diritti',
              sectionNumber: 7,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Hai diritto a:\n\n'
              '• Accedere ai tuoi dati personali.\n'
              '• Correggere dati errati o incompleti.\n'
              '• Cancellare i tuoi dati personali.\n'
              '• Opporti al trattamento dei tuoi dati.\n'
              '• Richiedere la portabilità dei dati.\n\n'
              'Per esercitare questi diritti, contattaci all\'indirizzo email: info@fantavacanze.it',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 8. Modifiche alla Privacy Policy
            GradientSectionDivider(
              text: 'Modifiche alla Privacy Policy',
              sectionNumber: 8,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Possiamo aggiornare questa Privacy Policy periodicamente. Ti informeremo di eventuali modifiche sostanziali attraverso l\'app o via email.',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.lg),

            // 9. Contatti
            GradientSectionDivider(
              text: 'Contatti',
              sectionNumber: 9,
              color: context.primaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Per domande o dubbi sulla nostra Privacy Policy, contattaci all\'indirizzo email: info@fantavacanze.it',
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.xxl),
          ],
        ),
      ),
    );
  }
}
