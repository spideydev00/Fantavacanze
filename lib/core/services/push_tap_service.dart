import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Gestisce il tap su una notifica push.
///
/// Unico effetto previsto: se il payload porta un `url` valido, aprire il
/// browser esterno. Ogni altra notifica — comprese quelle delle daily
/// challenge — non produce alcun effetto qui.
class PushTapService {
  /// Domini a cui una notifica può portare.
  ///
  /// Non difende da chi ha già le chiavi del database: difende dall'errore di
  /// battitura in un payload_data scritto a mano che manderebbe migliaia di
  /// utenti su un dominio sbagliato.
  static const _allowedHosts = {
    'fvstore.it',
    'www.fvstore.it',
    'fantavacanze.it',
    'www.fantavacanze.it',
  };

  /// Restituisce l'URL da aprire, o `null` se il payload non ne porta uno valido.
  static Uri? resolveUrl(Map<String, dynamic>? data) {
    final raw = data?['url'];
    if (raw is! String || raw.isEmpty) return null;

    final uri = Uri.tryParse(raw);
    if (uri == null) return null;
    if (uri.scheme != 'https') return null;
    if (!_allowedHosts.contains(uri.host)) return null;

    return uri;
  }

  /// Registra gli handler del tap. Da chiamare una volta sola all'avvio.
  static void register() {
    FirebaseMessaging.onMessageOpenedApp.listen(_handle);
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _handle(message);
    });
  }

  static Future<void> _handle(RemoteMessage message) async {
    final uri = resolveUrl(message.data);
    if (uri == null) return;

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error) {
      debugPrint('PushTapService: impossibile aprire $uri — $error');
    }
  }
}
