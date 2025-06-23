import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/daily_challenges/approve_daily_challenge.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/daily_challenges/get_daily_challenges.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/daily_challenges/mark_challenge_as_completed.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/daily_challenges/update_challenge_refresh_status.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/daily_challenges/reject_daily_challenge.dart';
import 'package:fantavacanze_official/features/league/domain/use_cases/remote/daily_challenges/unlock_daily_challenge.dart';

import 'daily_challenges_event.dart';
import 'daily_challenges_state.dart';

class DailyChallengesBloc
    extends Bloc<DailyChallengesEvent, DailyChallengesState> {
  final GetDailyChallenges _getDailyChallenges;
  final MarkChallengeAsCompleted _markChallengeAsCompleted;
  final UpdateChallengeRefreshStatus _updateChallengeRefreshStatus;
  final UnlockDailyChallenge _unlockDailyChallenge;
  final ApproveDailyChallenge _approveDailyChallenge;
  final RejectDailyChallenge _rejectDailyChallenge;
  final AppLeagueCubit _appLeagueCubit;
  final AppUserCubit _appUserCubit;

  StreamSubscription? _userSubscription;
  StreamSubscription? _leagueSubscription;

  DailyChallengesBloc({
    required GetDailyChallenges getDailyChallenges,
    required MarkChallengeAsCompleted markChallengeAsCompleted,
    required UpdateChallengeRefreshStatus updateChallengeRefreshStatus,
    required UnlockDailyChallenge unlockDailyChallenge,
    required ApproveDailyChallenge approveDailyChallenge,
    required RejectDailyChallenge rejectDailyChallenge,
    required AppUserCubit appUserCubit,
    required AppLeagueCubit appLeagueCubit,
  })  : _getDailyChallenges = getDailyChallenges,
        _markChallengeAsCompleted = markChallengeAsCompleted,
        _updateChallengeRefreshStatus = updateChallengeRefreshStatus,
        _unlockDailyChallenge = unlockDailyChallenge,
        _approveDailyChallenge = approveDailyChallenge,
        _rejectDailyChallenge = rejectDailyChallenge,
        _appLeagueCubit = appLeagueCubit,
        _appUserCubit = appUserCubit,
        super(const DailyChallengesInitial()) {
    on<GetDailyChallengesEvent>(_onGetDailyChallenges);
    on<MarkChallengeAsCompletedEvent>(_onMarkChallengeAsCompleted);
    on<RefreshDailyChallengeEvent>(_onRefreshDailyChallenge);
    on<UnlockDailyChallengeEvent>(_onUnlockDailyChallenge);
    on<ApproveDailyChallengeEvent>(_onApproveDailyChallenge);
    on<RejectDailyChallengeEvent>(_onRejectDailyChallenge);
    on<DailyChallengesResetStateEvent>(_onResetState);
    on<UnlockPremiumChallengesEvent>(_onUnlockPremiumChallenges);
    on<LockPremiumChallengesEvent>(_onLockPremiumChallenges);

    // Listen to premium status changes
    _userSubscription = _appUserCubit.stream.listen(_onUserStateChanged);

    // Listen to league changes
    _leagueSubscription = _appLeagueCubit.stream.listen(_onLeagueStateChanged);
  }

  // G E T   D A I L Y   C H A L L E N G E S
  Future<void> _onGetDailyChallenges(
    GetDailyChallengesEvent event,
    Emitter<DailyChallengesState> emit,
  ) async {
    emit(const DailyChallengesLoading());

    final result = await _getDailyChallenges.call(
      GetDailyChallengesParams(
        leagueId: event.leagueId,
        userId: event.userId,
      ),
    );

    result.fold(
      (failure) => emit(DailyChallengesError(message: failure.message)),
      (challenges) {
        emit(DailyChallengesLoaded(
          challenges: challenges,
          leagueId: event.leagueId,
          userId: event.userId,
        ));
      },
    );
  }

  // M A R K   C H A L L E N G E   A S   C O M P L E T E D
  Future<void> _onMarkChallengeAsCompleted(
    MarkChallengeAsCompletedEvent event,
    Emitter<DailyChallengesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DailyChallengesLoaded) return;

    emit(const DailyChallengesLoading());

    // We need to get the league from the AppLeagueCubit
    final leagueState = _appLeagueCubit.state;

    if (leagueState is! AppLeagueExists) {
      emit(const DailyChallengesError(message: 'Nessuna lega selezionata'));
      return;
    }

    final result = await _markChallengeAsCompleted.call(
      MarkChallengeAsCompletedParams(
        challenge: event.challenge,
        userId: event.userId,
        league: leagueState.selectedLeague,
      ),
    );

    result.fold(
      (failure) => emit(DailyChallengesError(message: failure.message)),
      (_) {
        final updatedChallenge = event.challenge.copyWith(
          isCompleted: true,
          completedAt: DateTime.now(),
        );

        // Update the challenges list with the completed challenge
        final updatedChallenges = currentState.challenges.map((c) {
          return c.id == updatedChallenge.id ? updatedChallenge : c;
        }).toList();

        // Emettiamo un unico stato con tutte le informazioni necessarie
        emit(DailyChallengesLoaded(
          challenges: updatedChallenges,
          leagueId: currentState.leagueId,
          userId: currentState.userId,
          operation: 'mark_completed',
        ));

        if (leagueState.selectedLeague.admins.contains(event.userId)) {
          // Fetch updated league data to refresh events
          _appLeagueCubit.getUserLeagues();
        }
      },
    );
  }

  // R E F R E S H   D A I L Y   C H A L L E N G E
  Future<void> _onRefreshDailyChallenge(
    RefreshDailyChallengeEvent event,
    Emitter<DailyChallengesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DailyChallengesLoaded) return;

    emit(const DailyChallengesLoading());

    final result = await _updateChallengeRefreshStatus.call(
      UpdateChallengeRefreshStatusParams(
        challengeId: event.challenge.id,
        userId: event.userId,
        isRefreshed: true,
      ),
    );

    result.fold(
      (failure) => emit(DailyChallengesError(message: failure.message)),
      (_) {
        // Update the challenge as refreshed, preserving unlock status
        final updatedChallenge = event.challenge.copyWith(
          isRefreshed: true,
          refreshedAt: DateTime.now(),
        );

        // Update the challenges list with the refreshed challenge
        final updatedChallenges = currentState.challenges.map((c) {
          return c.id == event.challenge.id ? updatedChallenge : c;
        }).toList();

        // Emettiamo un unico stato con tutte le informazioni necessarie
        emit(DailyChallengesLoaded(
          challenges: updatedChallenges,
          leagueId: currentState.leagueId,
          userId: currentState.userId,
          operation: 'refresh_challenge',
        ));
      },
    );
  }

  // U N L O C K   D A I L Y   C H A L L E N G E
  Future<void> _onUnlockDailyChallenge(
    UnlockDailyChallengeEvent event,
    Emitter<DailyChallengesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DailyChallengesLoaded) return;

    emit(const DailyChallengesLoading());

    final result = await _unlockDailyChallenge.call(
      UnlockDailyChallengeParams(
        challengeId: event.challenge.id,
        leagueId: event.leagueId,
        isUnlocked: true,
        primaryPosition: event.challenge.position,
      ),
    );

    result.fold(
      (failure) => emit(DailyChallengesError(message: failure.message)),
      (_) {
        // Update the challenge as unlocked
        final updatedChallenge = event.challenge.copyWith(isUnlocked: true);

        // Update the challenges list with the unlocked challenge
        final updatedChallenges = currentState.challenges.map((c) {
          // Sblocca sia la sfida selezionata che la sua corrispondente sostitutiva
          if (c.id == updatedChallenge.id) {
            return updatedChallenge;
          } else if (event.challenge.position < 3 &&
              c.position == event.challenge.position + 3) {
            return c.copyWith(isUnlocked: true);
          }
          // Lasciamo invariate le altre sfide
          else {
            return c;
          }
        }).toList();

        // Emettiamo un unico stato con tutte le informazioni necessarie
        emit(DailyChallengesLoaded(
          challenges: updatedChallenges,
          leagueId: currentState.leagueId,
          userId: currentState.userId,
          operation: 'unlock_challenge',
        ));
      },
    );
  }

  // A P P R O V E   D A I L Y   C H A L L E N G E
  Future<void> _onApproveDailyChallenge(
    ApproveDailyChallengeEvent event,
    Emitter<DailyChallengesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DailyChallengesLoaded) return;

    emit(const DailyChallengesLoading());

    final result = await _approveDailyChallenge.call(
      ApproveDailyChallengeParams(
        notificationId: event.notificationId,
      ),
    );

    result.fold(
      (failure) => emit(DailyChallengesError(message: failure.message)),
      (_) {
        // Emettiamo un unico stato aggiornato con l'operazione completata
        emit(DailyChallengesLoaded(
          challenges: currentState.challenges,
          leagueId: currentState.leagueId,
          userId: currentState.userId,
          operation: 'approve_challenge',
        ));
      },
    );
  }

  // R E J E C T   D A I L Y   C H A L L E N G E
  Future<void> _onRejectDailyChallenge(
    RejectDailyChallengeEvent event,
    Emitter<DailyChallengesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DailyChallengesLoaded) return;

    emit(const DailyChallengesLoading());

    final result = await _rejectDailyChallenge.call(
      RejectDailyChallengeParams(
        notificationId: event.notificationId,
        challengeId: event.challengeId,
      ),
    );

    result.fold(
      (failure) => emit(DailyChallengesError(message: failure.message)),
      (_) {
        // Emettiamo un unico stato aggiornato con l'operazione completata
        emit(DailyChallengesLoaded(
          challenges:
              currentState.challenges, // mantenere le challenge esistenti
          leagueId: currentState.leagueId,
          userId: currentState.userId,
          operation: 'reject_challenge',
        ));
      },
    );
  }

  // R E S E T   S T A T E
  void _onResetState(
    DailyChallengesResetStateEvent event,
    Emitter<DailyChallengesState> emit,
  ) {
    emit(const DailyChallengesInitial());
  }

  // Handle premium status changes and update challenges accordingly
  void _onUserStateChanged(dynamic userState) {
    if (userState is AppUserIsLoggedIn &&
        _appLeagueCubit.state is AppLeagueExists) {
      final leagueId =
          (_appLeagueCubit.state as AppLeagueExists).selectedLeague.id;

      if (userState.user.isPremium) {
        // Se l'utente è diventato premium, sblocca le sfide premium e ads
        add(
          UnlockPremiumChallengesEvent(
            userId: userState.user.id,
            leagueId: leagueId,
          ),
        );
      } else {
        // Se l'utente non è più premium, blocca le sfide premium e ads
        add(
          LockPremiumChallengesEvent(
            userId: userState.user.id,
            leagueId: leagueId,
          ),
        );
      }
    }
  }

  // Handle league selection changes
  void _onLeagueStateChanged(dynamic leagueState) {
    if (leagueState is AppLeagueExists) {
      final userState = _appUserCubit.state;
      if (userState is AppUserIsLoggedIn) {
        // Reload challenges when league changes
        add(GetDailyChallengesEvent(
          userId: userState.user.id,
          leagueId: leagueState.selectedLeague.id,
        ));
      }
    }
  }

  // U N L O C K   P R E M I U M   C H A L L E N G E S
  Future<void> _onUnlockPremiumChallenges(
    UnlockPremiumChallengesEvent event,
    Emitter<DailyChallengesState> emit,
  ) async {
    // Verifica che lo stato corrente sia loaded
    final currentState = state;
    if (currentState is! DailyChallengesLoaded) {
      // Se non abbiamo già caricato le sfide, dobbiamo farlo
      await _onGetDailyChallenges(
        GetDailyChallengesEvent(
          userId: event.userId,
          leagueId: event.leagueId,
        ),
        emit,
      );
      return;
    }

    // Verifica lo stato utente
    final userState = _appUserCubit.state;

    if (userState is! AppUserIsLoggedIn || userState.user.isPremium != true) {
      // Se l'utente non è premium, non procedere
      return;
    }

    // Aggiorna lo stato con tutte le sfide sbloccate (sia premium che ads)
    final updatedChallenges = currentState.challenges.map((challenge) {
      // Sblocca le sfide premium (posizione 3 e 6) e quelle ads (posizione 2 e 5)
      if (challenge.position == 2 ||
          challenge.position == 3 ||
          challenge.position == 5 ||
          challenge.position == 6) {
        return challenge.copyWith(isUnlocked: true);
      }
      return challenge;
    }).toList();

    // Emetti lo stato aggiornato con tutte le sfide sbloccate
    emit(DailyChallengesLoaded(
      challenges: updatedChallenges,
      leagueId: currentState.leagueId,
      userId: currentState.userId,
      operation: 'premium_unlocked',
    ));
  }

  // L O C K   P R E M I U M   C H A L L E N G E S
  Future<void> _onLockPremiumChallenges(
    LockPremiumChallengesEvent event,
    Emitter<DailyChallengesState> emit,
  ) async {
    // Verifica che lo stato corrente sia loaded
    final currentState = state;
    if (currentState is! DailyChallengesLoaded) {
      // Se non abbiamo già caricato le sfide, dobbiamo farlo
      await _onGetDailyChallenges(
        GetDailyChallengesEvent(
          userId: event.userId,
          leagueId: event.leagueId,
        ),
        emit,
      );
      return;
    }

    // Aggiorna lo stato bloccando le sfide premium e ads
    final updatedChallenges = currentState.challenges.map((challenge) {
      // Blocca le sfide premium (posizione 3 e 6) e quelle ads (posizione 2 e 5)
      // ma solo se non sono già state completate
      if ((challenge.position == 2 ||
              challenge.position == 3 ||
              challenge.position == 5 ||
              challenge.position == 6) &&
          !challenge.isCompleted) {
        return challenge.copyWith(isUnlocked: false);
      }
      return challenge;
    }).toList();

    // Emetti lo stato aggiornato con le sfide bloccate
    emit(DailyChallengesLoaded(
      challenges: updatedChallenges,
      leagueId: currentState.leagueId,
      userId: currentState.userId,
      operation: 'premium_locked',
    ));
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _leagueSubscription?.cancel();
    return super.close();
  }
}
