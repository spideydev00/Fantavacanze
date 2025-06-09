enum GameType {
  truthOrDare,
  wordBomb,
  neverHaveIEver,
}

String gameTypeToString(GameType type) {
  switch (type) {
    case GameType.truthOrDare:
      return 'truth_or_dare';
    case GameType.neverHaveIEver:
      return 'never_have_i_ever';
    case GameType.wordBomb:
      return 'word_bomb';
  }
}

GameType gameTypeFromString(String type) {
  switch (type) {
    case 'truth_or_dare':
      return GameType.truthOrDare;
    case 'never_have_i_ever':
      return GameType.neverHaveIEver;
    case 'word_bomb':
      return GameType.wordBomb;
    default:
      throw ArgumentError('Unknown game type string: $type');
  }
}
