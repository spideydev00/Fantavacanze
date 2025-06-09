part of 'truth_or_dare_bloc.dart';

sealed class TruthOrDareState extends Equatable {
  const TruthOrDareState();

  @override
  List<Object?> get props => [];
}

final class TruthOrDareInitial extends TruthOrDareState {}

final class TruthOrDareLoading extends TruthOrDareState {}

final class TruthOrDareGameReady extends TruthOrDareState {
  final GameSession session;
  final List<GamePlayer> players;
  final List<TruthOrDareQuestion> allQuestions;
  final TruthOrDareQuestion? currentQuestion;
  final bool isAdmin;
  final bool canChangeCurrentQuestion;

  const TruthOrDareGameReady({
    required this.session,
    required this.players,
    required this.allQuestions,
    this.currentQuestion,
    required this.isAdmin,
    this.canChangeCurrentQuestion = true,
  });

  @override
  List<Object?> get props => [
        session,
        players,
        allQuestions,
        currentQuestion,
        isAdmin,
        canChangeCurrentQuestion,
      ];

  TruthOrDareGameReady copyWith({
    GameSession? session,
    List<GamePlayer>? players,
    List<TruthOrDareQuestion>? allQuestions,
    TruthOrDareQuestion? currentQuestion,
    bool? isAdmin,
    bool? canChangeCurrentQuestion,
    bool clearCurrentQuestion = false,
  }) {
    return TruthOrDareGameReady(
      session: session ?? this.session,
      players: players ?? this.players,
      allQuestions: allQuestions ?? this.allQuestions,
      currentQuestion: clearCurrentQuestion
          ? null
          : (currentQuestion ?? this.currentQuestion),
      isAdmin: isAdmin ?? this.isAdmin,
      canChangeCurrentQuestion:
          canChangeCurrentQuestion ?? this.canChangeCurrentQuestion,
    );
  }
}

final class TruthOrDareError extends TruthOrDareState {
  final String message;
  const TruthOrDareError(this.message);

  @override
  List<Object?> get props => [message];
}
