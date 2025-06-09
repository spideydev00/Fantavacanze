import 'dart:async';
import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart'
    as auth_user;
import 'package:fantavacanze_official/features/games/domain/entities/game_player.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_session.dart';
import 'package:fantavacanze_official/features/games/domain/entities/game_status_enum.dart';
import 'package:fantavacanze_official/features/games/domain/entities/never_have_i_ever_question.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/get_never_have_i_ever_cards.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/stream_game_session.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/stream_lobby_players.dart';
import 'package:fantavacanze_official/features/games/domain/usecases/update_game_state.dart';

part 'never_have_i_ever_event.dart';
part 'never_have_i_ever_state.dart';

class NeverHaveIEverBloc
    extends Bloc<NeverHaveIEverEvent, NeverHaveIEverState> {
  // =====================================================================
  // PROPERTIES
  // =====================================================================
  final GetNeverHaveIEverCards _getNeverHaveIEverCards;
  final StreamGameSession _streamGameSession;
  final StreamLobbyPlayers _streamLobbyPlayers;
  final UpdateGameState _updateGameState;
  final AppUserCubit _appUserCubit;

  StreamSubscription<dynamic>? _sessionSubscription;
  StreamSubscription<dynamic>? _playersSubscription;
  List<NeverHaveIEverQuestion> _allQuestionsList = [];
  List<GamePlayer> _currentPlayersList = [];

  // =====================================================================
  // GETTERS
  // =====================================================================
  auth_user.User? get _currentUser {
    final userState = _appUserCubit.state;
    if (userState is AppUserIsLoggedIn) {
      return userState.user;
    }
    return null;
  }

  // =====================================================================
  // HELPER METHODS (INSTANCE)
  // =====================================================================
  bool _isAdmin(GameSession? session) =>
      session != null && _currentUser?.id == session.adminId;

  // =====================================================================
  // CONSTRUCTOR
  // =====================================================================
  NeverHaveIEverBloc({
    required GetNeverHaveIEverCards getNeverHaveIEverCards,
    required StreamGameSession streamGameSession,
    required StreamLobbyPlayers streamLobbyPlayers,
    required UpdateGameState updateGameState,
    required AppUserCubit appUserCubit,
  })  : _getNeverHaveIEverCards = getNeverHaveIEverCards,
        _streamGameSession = streamGameSession,
        _streamLobbyPlayers = streamLobbyPlayers,
        _updateGameState = updateGameState,
        _appUserCubit = appUserCubit,
        super(NeverHaveIEverInitial()) {
    on<InitializeNeverHaveIEverGame>(_onInitializeNeverHaveIEverGame);
    on<NextQuestionRequested>(_onNextQuestionRequested);
    on<_NeverHaveIEverSessionUpdated>(_onSessionUpdated);
    on<_NeverHaveIEverPlayersUpdated>(_onPlayersUpdated);
    on<_NeverHaveIEverStreamErrorOccurred>(_onStreamErrorOccurred);
  }

  // =====================================================================
  // EVENT HANDLERS
  // =====================================================================

  // ------------------ ON INITIALIZE NEVER HAVE I EVER GAME ------------------ //
  Future<void> _onInitializeNeverHaveIEverGame(
    InitializeNeverHaveIEverGame event,
    Emitter<NeverHaveIEverState> emit,
  ) async {
    emit(NeverHaveIEverLoading());
    _startStreams(event.initialSession.id);

    final playersEither =
        await _streamLobbyPlayers(event.initialSession.id).first;

    await playersEither.fold(
      (fail) async {
        emit(NeverHaveIEverError(
            "Errore nel caricamento dei partecipanti: ${fail.message}"));
      },
      (initialPlayers) async {
        _currentPlayersList = initialPlayers;

        final questionsResult = await _getNeverHaveIEverCards(
          GetNeverHaveIEverCardsParams(sessionId: event.initialSession.id),
        );

        await questionsResult.fold(
          (failure) async {
            emit(
              NeverHaveIEverError(
                  "Errore nel caricamento delle domande: ${failure.message}"),
            );
          },
          (questions) async {
            _allQuestionsList = questions;

            if (_allQuestionsList.isEmpty && _isAdmin(event.initialSession)) {
              emit(NeverHaveIEverError(
                "Nessuna domanda trovata per iniziare la partita.",
              ));
              return;
            }

            if (_isAdmin(event.initialSession) &&
                (event.initialSession.gameState == null ||
                    event.initialSession.gameState!['current_question_id'] ==
                        null) &&
                _allQuestionsList.isNotEmpty) {
              final firstQuestion =
                  _allQuestionsList[Random().nextInt(_allQuestionsList.length)];

              final newGameState = {
                'current_question_id': firstQuestion.id,
              };

              final updateResult = await _updateGameState(UpdateGameStateParams(
                sessionId: event.initialSession.id,
                newGameState: newGameState,
              ));

              updateResult.fold(
                (failure) => emit(NeverHaveIEverError(
                    "Impossibile trovare le domande iniziali: ${failure.message}")),
                (_) {
                  final updatedSession =
                      event.initialSession.copyWith(gameState: newGameState);
                  emit(_buildGameReadyState(
                      updatedSession, _currentPlayersList));
                },
              );
            } else {
              emit(_buildGameReadyState(
                  event.initialSession, _currentPlayersList));
            }
          },
        );
      },
    );
  }

  // ------------------ ON NEXT QUESTION REQUESTED ------------------ //
  Future<void> _onNextQuestionRequested(
      NextQuestionRequested event, Emitter<NeverHaveIEverState> emit) async {
    if (state is! NeverHaveIEverGameReady) return;

    final currentReadyState = state as NeverHaveIEverGameReady;
    if (!_isAdmin(currentReadyState.session)) return;

    if (_allQuestionsList.isEmpty) {
      emit(const NeverHaveIEverError(
          "Lista domande non disponibile. Attendi o riprova."));
      return;
    }

    final randomQuestion =
        _allQuestionsList[Random().nextInt(_allQuestionsList.length)];

    final newGameState = {
      ...currentReadyState.session.gameState ?? {},
      'current_question_id': randomQuestion.id,
    };

    final result = await _updateGameState(UpdateGameStateParams(
      sessionId: currentReadyState.session.id,
      newGameState: newGameState,
    ));

    result.fold(
      (failure) {
        emit(NeverHaveIEverError(
            "Errore nel cambiare domanda: ${failure.message}"));
      },
      (_) {
        // Success, stream will propagate the change.
      },
    );
  }

  // =====================================================================
  // INTERNAL EVENT HANDLERS / STREAM UPDATERS
  // =====================================================================

  // ------------------ ON SESSION UPDATED ------------------ //
  void _onSessionUpdated(
    _NeverHaveIEverSessionUpdated event,
    Emitter<NeverHaveIEverState> emit,
  ) {
    if (event.session.status != GameStatus.inProgress) {
      _cancelSubscriptions();
      emit(NeverHaveIEverInitial());
      return;
    }

    if (_allQuestionsList.isEmpty && state is! NeverHaveIEverLoading) {
      // Questions might not have loaded during init.
    }

    emit(_buildGameReadyState(event.session, _currentPlayersList));
  }

  // ------------------ ON PLAYERS UPDATED ------------------ //
  void _onPlayersUpdated(
      _NeverHaveIEverPlayersUpdated event, Emitter<NeverHaveIEverState> emit) {
    _currentPlayersList = event.players;
    if (state is NeverHaveIEverGameReady) {
      final currentReadyState = state as NeverHaveIEverGameReady;
      emit(
          _buildGameReadyState(currentReadyState.session, _currentPlayersList));
    } else if (state is NeverHaveIEverLoading) {
      // Players updated while BLoC is loading.
    }
  }

  // ------------------ ON STREAM ERROR OCCURRED ------------------ //
  void _onStreamErrorOccurred(_NeverHaveIEverStreamErrorOccurred event,
      Emitter<NeverHaveIEverState> emit) {
    emit(NeverHaveIEverError(event.message));
    _cancelSubscriptions();
  }

  // =====================================================================
  // UTILITY METHODS
  // =====================================================================

  // ------------------ BUILD GAME READY STATE ------------------ //
  NeverHaveIEverGameReady _buildGameReadyState(
    GameSession session,
    List<GamePlayer> players,
  ) {
    NeverHaveIEverQuestion? currentQuestion;
    if (session.gameState != null &&
        session.gameState!['current_question_id'] != null) {
      final questionId = session.gameState!['current_question_id'] as String;

      if (_allQuestionsList.isNotEmpty) {
        currentQuestion =
            _allQuestionsList.firstWhere((q) => q.id == questionId);
      }
    }

    return NeverHaveIEverGameReady(
      session: session,
      players: players,
      allQuestions: _allQuestionsList,
      isAdmin: _isAdmin(session),
      currentQuestion: currentQuestion,
      currentPlayerName: _getPlayerName(session.currentTurnUserId, players),
    );
  }

  // ------------------ START STREAMS ------------------ //
  void _startStreams(String sessionId) {
    _cancelSubscriptions();

    _sessionSubscription = _streamGameSession(sessionId).listen(
      (eitherSession) => eitherSession.fold(
        (failure) => add(_NeverHaveIEverStreamErrorOccurred(
            'Errore sessione: ${failure.message}')),
        (session) => add(_NeverHaveIEverSessionUpdated(session)),
      ),
      onError: (error) => add(
          _NeverHaveIEverStreamErrorOccurred('Errore stream sessione: $error')),
    );

    _playersSubscription = _streamLobbyPlayers(sessionId).listen(
      (eitherPlayers) => eitherPlayers.fold(
        (failure) => add(_NeverHaveIEverStreamErrorOccurred(
            'Errore giocatori: ${failure.message}')),
        (players) => add(_NeverHaveIEverPlayersUpdated(players)),
      ),
      onError: (error) => add(_NeverHaveIEverStreamErrorOccurred(
          'Errore stream giocatori: $error')),
    );
  }

  // ------------------ GET PLAYER NAME ------------------ //
  String? _getPlayerName(String? userId, List<GamePlayer> players) {
    if (userId == null) return null;
    try {
      return players.firstWhere((p) => p.userId == userId).userName;
    } catch (e) {
      return null;
    }
  }

  // ------------------ CANCEL SUBSCRIPTIONS ------------------ //
  void _cancelSubscriptions() {
    _sessionSubscription?.cancel();
    _sessionSubscription = null;
    _playersSubscription?.cancel();
    _playersSubscription = null;
  }

  // =====================================================================
  // LIFECYCLE METHODS
  // =====================================================================

  // ------------------ CLOSE ------------------ //
  @override
  Future<void> close() {
    _cancelSubscriptions();
    return super.close();
  }
}
