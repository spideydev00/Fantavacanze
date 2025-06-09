part of 'never_have_i_ever_bloc.dart';

sealed class NeverHaveIEverState extends Equatable {
  const NeverHaveIEverState();

  @override
  List<Object?> get props => [];
}

final class NeverHaveIEverInitial extends NeverHaveIEverState {}

final class NeverHaveIEverLoading extends NeverHaveIEverState {}

final class NeverHaveIEverGameReady extends NeverHaveIEverState {
  final GameSession session;
  final List<GamePlayer> players;
  final List<NeverHaveIEverQuestion> allQuestions;
  final NeverHaveIEverQuestion? currentQuestion;
  final bool isAdmin;
  final String? currentPlayerName;

  const NeverHaveIEverGameReady({
    required this.session,
    required this.players,
    required this.allQuestions,
    this.currentQuestion,
    required this.isAdmin,
    this.currentPlayerName,
  });

  NeverHaveIEverGameReady copyWith({
    GameSession? session,
    List<GamePlayer>? players,
    List<NeverHaveIEverQuestion>? allQuestions,
    NeverHaveIEverQuestion? currentQuestion,
    bool? isAdmin,
    String? currentPlayerName,
    bool clearCurrentQuestion = false,
  }) {
    return NeverHaveIEverGameReady(
      session: session ?? this.session,
      players: players ?? this.players,
      allQuestions: allQuestions ?? this.allQuestions,
      currentQuestion:
          clearCurrentQuestion ? null : currentQuestion ?? this.currentQuestion,
      isAdmin: isAdmin ?? this.isAdmin,
      currentPlayerName: currentPlayerName ?? this.currentPlayerName,
    );
  }

  @override
  List<Object?> get props => [
        session,
        players,
        allQuestions,
        currentQuestion,
        isAdmin,
        currentPlayerName,
      ];
}

final class NeverHaveIEverError extends NeverHaveIEverState {
  final String message;
  const NeverHaveIEverError(this.message);

  @override
  List<Object?> get props => [message];
}
