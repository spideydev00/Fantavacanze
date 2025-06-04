enum GameMode { broCode, baddies, allTogether, custom }

extension GameModeExtension on GameMode {
  String get label {
    switch (this) {
      case GameMode.broCode:
        return 'Bro-code';
      case GameMode.baddies:
        return 'Baddies';
      case GameMode.allTogether:
        return 'All Together';
      case GameMode.custom:
        return 'Personalizzato';
    }
  }

  String get description {
    switch (this) {
      case GameMode.broCode:
        return 'Regole per gruppi di soli maschi';
      case GameMode.baddies:
        return 'Regole per gruppi di sole ragazze';
      case GameMode.allTogether:
        return 'Set di regole per gruppi misti';
      case GameMode.custom:
        return 'Crea le tue regole da zero';
    }
  }

  String get apiMode {
    switch (this) {
      case GameMode.broCode:
        return 'male';
      case GameMode.baddies:
        return 'female';
      case GameMode.allTogether:
        return 'mixed';
      case GameMode.custom:
        return 'custom';
    }
  }
}
