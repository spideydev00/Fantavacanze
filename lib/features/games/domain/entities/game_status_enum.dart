enum GameStatus {
  waiting,
  inProgress,
  paused,
  finished,
  // Add other statuses here
}

String gameStatusToString(GameStatus status) {
  switch (status) {
    case GameStatus.waiting:
      return 'waiting';
    case GameStatus.inProgress:
      return 'in_progress';
    case GameStatus.paused:
      return 'paused';
    case GameStatus.finished:
      return 'finished';
  }
}

GameStatus gameStatusFromString(String status) {
  switch (status) {
    case 'waiting':
      return GameStatus.waiting;
    case 'in_progress':
      return GameStatus.inProgress;
    case 'paused':
      return GameStatus.paused;
    case 'finished':
      return GameStatus.finished;
    default:
      throw ArgumentError('Unknown game status string: $status');
  }
}
