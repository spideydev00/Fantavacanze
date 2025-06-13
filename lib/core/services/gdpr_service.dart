import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Un servizio singleton per gestire il consenso GDPR utilizzando
/// l'SDK UMP (User Messaging Platform) di Google.
class GdprService {
  static final GdprService _instance = GdprService._internal();

  factory GdprService() {
    return _instance;
  }

  GdprService._internal();

  bool _isInitializing = false;
  ConsentStatus _consentStatus = ConsentStatus.unknown;
  String? _errorMessage;

  /// Lo stato attuale del consenso.
  ConsentStatus get consentStatus => _consentStatus;

  /// Eventuale messaggio di errore verificatosi durante il processo.
  String? get errorMessage => _errorMessage;

  /// Indica se il servizio sta attualmente eseguendo un'operazione.
  bool get isInitializing => _isInitializing;

  /// Inizializza il servizio, contatta i server di Google per lo stato del consenso
  /// e mostra il modulo se necessario.
  ///
  /// [testIdentifiers] è una lista di ID di dispositivi di test.
  Future<void> initializeAndShowForm({
    List<String> testIdentifiers = const [],
  }) async {
    if (_isInitializing) return;
    _isInitializing = true;
    _errorMessage = null;

    // Impostazioni di debug per testare il flusso in area SEE.
    final debugSettings = ConsentDebugSettings(
      debugGeography: DebugGeography.debugGeographyEea,
      testIdentifiers: testIdentifiers,
    );

    final consentRequestParams = ConsentRequestParameters(
      consentDebugSettings: kDebugMode ? debugSettings : null,
    );

    // Usiamo un Completer per attendere il risultato e mantenere la logica async.
    final completer = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      consentRequestParams,
      () {
        // Successo: il processo può continuare.
        debugPrint('Informazioni sul consenso aggiornate con successo.');
        completer.complete();
      },
      (FormError error) {
        // Fallimento: memorizza l'errore e completa per non bloccare l'app.
        _errorMessage = error.message;
        debugPrint('Errore nell\'aggiornamento del consenso: ${error.message}');
        completer.complete();
      },
    );

    await completer.future;

    // Se il modulo di consenso è disponibile, caricalo e mostralo.
    final isConsentFormAvailable =
        await ConsentInformation.instance.isConsentFormAvailable();
    if (isConsentFormAvailable) {
      await _loadAndShowForm();
    }

    // Aggiorna lo stato del consenso interno dopo il processo.
    await _fetchConsentStatus();

    _isInitializing = false;
  }

  /// Carica e mostra il modulo di consenso se lo stato è 'required'.
  Future<void> _loadAndShowForm() {
    final completer = Completer<void>();
    ConsentForm.loadConsentForm(
      (ConsentForm consentForm) async {
        final status = await ConsentInformation.instance.getConsentStatus();
        if (status == ConsentStatus.required) {
          consentForm.show((FormError? error) {
            if (error != null) _errorMessage = error.message;
            // Completa quando il modulo viene chiuso, indipendentemente dall'errore.
            _fetchConsentStatus().whenComplete(() => completer.complete());
          });
        } else {
          // Il consenso non è richiesto, quindi completa subito.
          completer.complete();
        }
      },
      (FormError? error) {
        _errorMessage = error?.message;
        debugPrint('Errore durante il caricamento del modulo: $error');
        // Completa anche in caso di errore per non bloccare il flusso.
        completer.complete();
      },
    );
    return completer.future;
  }

  /// Aggiorna la variabile interna con lo stato del consenso attuale.
  Future<void> _fetchConsentStatus() async {
    _consentStatus = await ConsentInformation.instance.getConsentStatus();
    debugPrint('Stato del consenso attuale: ${_consentStatus.name}');
  }

  /// Restituisce lo stato del consenso come stringa leggibile.
  Future<String> getConsentStatusString() async {
    await _fetchConsentStatus();
    return _consentStatus.name; // Es. 'required', 'obtained', 'notRequired'
  }

  /// Resetta lo stato del consenso dell'utente.
  /// La prossima volta che `initializeAndShowForm` verrà chiamato,
  /// il modulo di consenso verrà mostrato di nuovo.
  Future<void> resetConsentStatus() async {
    if (_isInitializing) return;
    _isInitializing = true;

    await ConsentInformation.instance.reset();
    await _fetchConsentStatus(); // Aggiorna lo stato dopo il reset

    _isInitializing = false;
  }
}
