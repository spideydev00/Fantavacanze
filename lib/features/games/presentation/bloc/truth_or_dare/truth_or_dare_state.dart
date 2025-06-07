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
  final List<TruthOrDareQuestion> allQuestions; // All loaded questions
  final TruthOrDareQuestion? currentQuestion;
  final List<GamePlayer> players; // For displaying whose turn it is, etc.
  final bool isAdmin;

  const TruthOrDareGameReady({
    required this.session,
    required this.allQuestions,
    this.currentQuestion,
    required this.players,
    required this.isAdmin,
  });

  @override
  List<Object?> get props =>
      [session, allQuestions, currentQuestion, players, isAdmin];

  TruthOrDareGameReady copyWith({
    GameSession? session,
    List<TruthOrDareQuestion>? allQuestions,
    TruthOrDareQuestion? currentQuestion,
    List<GamePlayer>? players,
    bool? isAdmin,
    bool clearCurrentQuestion = false, // Helper to nullify currentQuestion
  }) {
    return TruthOrDareGameReady(
      session: session ?? this.session,
      allQuestions: allQuestions ?? this.allQuestions,
      currentQuestion: clearCurrentQuestion
          ? null
          : (currentQuestion ?? this.currentQuestion),
      players: players ?? this.players,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

final class TruthOrDareError extends TruthOrDareState {
  final String message;
  const TruthOrDareError(this.message);
  @override
  List<Object?> get props => [message];
}
