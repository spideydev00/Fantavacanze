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
}
