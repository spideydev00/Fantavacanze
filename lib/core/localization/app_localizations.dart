import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Helper method
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Delegate che gestisce il caricamento delle localizzazioni
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Lista dei delegate supportati da aggiungere in MaterialApp
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  // Le lingue supportate dall'app
  static const List<Locale> supportedLocales = [
    Locale('it'), // Italiano (principale)
    Locale('en'), // Inglese (fallback)
  ];

  // Traduzioni statiche
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Fantavacanze',
      'welcomeMessage': 'Welcome to Fantavacanze!',
      // Aggiungi qui altre stringhe...
    },
    'it': {
      'appTitle': 'Fantavacanze',
      'welcomeMessage': 'Benvenuto su Fantavacanze!',
      // Aggiungi qui altre stringhe...
    },
  };

  // Metodo per ottenere una stringa localizzata
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? 
           _localizedValues['it']?[key] ??  // Fallback all'italiano
           key; // Ultimo fallback alla chiave stessa
  }
}

// Delegate per caricare le localizzazioni
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['it', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension per accedere più facilmente alle stringhe localizzate
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  
  String tr(String key) => l10n.translate(key);
}
