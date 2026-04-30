import 'package:fantavacanze_official/core/config/store_config.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Inizializza RevenueCat. Da chiamare una sola volta all'avvio dell'app,
/// dopo Supabase ma prima di runApp.
///
/// [appUserId] = id Supabase dell'utente già loggato all'avvio (se esiste);
/// se null RevenueCat genera un anonymous id e poi lo unisce con
/// [Purchases.logIn] dopo il login.
Future<void> bootstrapPurchases({String? appUserId}) async {
  try {
    StoreConfig.initFromPlatform();

    await Purchases.setLogLevel(
      kReleaseMode ? LogLevel.warn : LogLevel.debug,
    );

    final config = PurchasesConfiguration(StoreConfig.instance.apiKey)
      ..appUserID = appUserId
      ..purchasesAreCompletedBy = const PurchasesAreCompletedByRevenueCat();

    await Purchases.configure(config);

    if (kDebugMode) {
      try {
        final offerings = await Purchases.getOfferings();
        if (offerings.current == null) {
          debugPrint(
            '⚠️  RevenueCat: nessuna current offering. '
            'Controlla dashboard RC, Play Console / App Store Connect e applicationId.',
          );
        } else {
          debugPrint(
            '✅ RevenueCat current offering: ${offerings.current!.identifier} '
            '(${offerings.current!.availablePackages.length} packages)',
          );
        }
      } catch (e) {
        debugPrint('❌ RevenueCat getOfferings error: $e');
      }
    }

    debugPrint('✅ RevenueCat inizializzato correttamente');
  } catch (e) {
    debugPrint('❌ Errore nell\'inizializzazione di RevenueCat: $e');
    rethrow;
  }
}
