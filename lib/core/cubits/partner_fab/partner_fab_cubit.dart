import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Visibilita del pulsante partner (InVibe) sulla bottom bar, solo per le
/// leghe default (senza partner). `true` = mostra il pulsante partner promo;
/// `false` = mostra il FAB alternativo "?" che porta alla guida.
///
/// Persistito per-utente in SharedPreferences (chiave
/// `partner_fab_enabled_<userId>`), stessa convenzione di
/// `invibe_bridge_seen_<userId>`. Default: `true`.
class PartnerFabCubit extends Cubit<bool> {
  static const String _keyPrefix = 'partner_fab_enabled_';

  final SharedPreferences _prefs;

  // ponytail: 'guest' finche non arriva un utente loggato; il dashboard chiama
  // loadFor() con l'id reale in initState.
  String _userId = 'guest';

  PartnerFabCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(true);

  String get _key => '$_keyPrefix$_userId';

  /// Carica il valore per l'utente corrente (default true = pulsante mostrato).
  void loadFor(String userId) {
    _userId = userId;
    emit(_prefs.getBool(_key) ?? true);
  }

  /// Inverte e persiste la preferenza per l'utente corrente.
  Future<void> toggle() async {
    final next = !state;
    await _prefs.setBool(_key, next);
    emit(next);
  }
}
