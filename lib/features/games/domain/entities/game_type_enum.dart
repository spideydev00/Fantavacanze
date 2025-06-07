enum GameType {
  truthOrDare,
  wordBombGhost,
  // Add other game types here
}

String gameTypeToString(GameType type) {
  switch (type) {
    case GameType.truthOrDare:
      return 'truth_or_dare';
    case GameType.wordBombGhost:
      return 'word_bomb_ghost';
  }
}

GameType gameTypeFromString(String type) {
  switch (type) {
    case 'truth_or_dare':
      return GameType.truthOrDare;
    case 'word_bomb_ghost':
      return GameType.wordBombGhost;
    default:
      throw ArgumentError('Unknown game type string: $type');
  }
}
