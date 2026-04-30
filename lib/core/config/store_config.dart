import 'dart:io';

import 'package:fantavacanze_official/core/secrets/app_secrets.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Identifier dell'entitlement premium su RevenueCat dashboard.
/// Centralizzato qui per non avere stringhe magiche sparse nel codice.
const String kPremiumEntitlementId = 'premium_benefit';

/// Singleton che incapsula la configurazione dello store di acquisti
/// (Apple App Store / Google Play). Allineato all'esempio ufficiale
/// RevenueCat MagicWeather.
class StoreConfig {
  final Store store;
  final String apiKey;

  static StoreConfig? _instance;

  factory StoreConfig({required Store store, required String apiKey}) {
    _instance ??= StoreConfig._internal(store, apiKey);
    return _instance!;
  }

  StoreConfig._internal(this.store, this.apiKey);

  static StoreConfig get instance {
    final i = _instance;
    if (i == null) {
      throw StateError(
        'StoreConfig non inizializzato. Chiama StoreConfig.initFromPlatform() prima.',
      );
    }
    return i;
  }

  static bool get isForAppleStore => instance.store == Store.appStore;
  static bool get isForGooglePlay => instance.store == Store.playStore;

  /// Inizializza il singleton in base alla piattaforma corrente.
  /// Idempotente: chiamate successive non sovrascrivono l'istanza.
  static void initFromPlatform() {
    if (_instance != null) return;

    if (Platform.isIOS || Platform.isMacOS) {
      StoreConfig(
        store: Store.appStore,
        apiKey: AppSecrets.revenueCatIosApiKey,
      );
    } else if (Platform.isAndroid) {
      StoreConfig(
        store: Store.playStore,
        apiKey: AppSecrets.revenueCatAndroidApiKey,
      );
    }
  }
}
