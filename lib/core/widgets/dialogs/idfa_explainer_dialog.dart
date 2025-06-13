import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/settings/privacy_policy.dart';
import 'package:flutter/material.dart';

/// Un dialogo personalizzato per spiegare all'utente perché l'app
/// sta per richiedere il permesso di tracciamento (ATT/IDFA).
///
/// L'obiettivo è contestualizzare la richiesta di sistema di Apple,
/// aumentando la probabilità che l'utente accetti.
class IdfaExplainerDialog extends StatelessWidget {
  /// La funzione da eseguire quando l'utente preme "Continua".
  /// È qui che dovresti chiamare `AppTrackingTransparency.requestTrackingAuthorization()`.
  final VoidCallback onContinue;

  const IdfaExplainerDialog({
    super.key,
    required this.onContinue,
  });

  /// Metodo statico per mostrare il dialogo in modo semplice.
  ///
  /// Richiede un [BuildContext] valido e la callback [onContinue].
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onContinue,
  }) {
    return showDialog(
      context: context,
      // L'utente deve fare una scelta esplicita per chiudere il dialogo.
      barrierDismissible: false,
      builder: (_) => IdfaExplainerDialog(onContinue: onContinue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.md),
      ),
      // Icona a tema privacy per rassicurare l'utente.
      icon: Icon(
        Icons.privacy_tip_outlined,
        size: 48,
        color: Color.fromARGB(255, 30, 137, 231),
      ),
      title: Text(
        'Un aiuto per la tua app',
        textAlign: TextAlign.center,
        style:
            context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Fantavacanze è gratuita grazie al supporto della pubblicità.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Per continuare a offrirtela senza costi, stiamo per chiederti il permesso di "tracciare" la tua attività. Questo ci aiuta a mostrarti annunci più utili e pertinenti, invece di pubblicità casuali.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'I tuoi dati restano anonimi e vengono trattati nel pieno rispetto della tua privacy.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall
                  ?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      // I bottoni sono impilati per una migliore leggibilità su mobile.
      actions: [
        SizedBox(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 30, 137, 231),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                ),
                onPressed: () {
                  // 1. Chiudi questo dialogo di spiegazione.
                  Navigator.of(context).pop();
                  // 2. Esegui la callback per mostrare il dialogo di sistema ATT.
                  onContinue();
                },
                child: const Text('Ho capito, continua'),
              ),
              TextButton(
                onPressed: () {
                  // Permetti all'utente di approfondire leggendo la privacy policy.
                  Navigator.of(context).push(PrivacyPolicyPage.route);
                },
                child: Text(
                  'Leggi la Privacy Policy',
                  style: TextStyle(color: Color.fromARGB(255, 30, 137, 231)),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
