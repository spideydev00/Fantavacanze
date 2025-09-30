import 'dart:async';
import 'package:fantavacanze_official/core/cubits/app_fs_league/app_fs_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_rules/refresh_fs_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_rules/set_fs_rule_as_completed.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_rules/set_fs_rule_as_uncompleted.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_rules/unlock_fs_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_rules/lock_fs_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_rules/insert_rules_for_league_from_existing.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_rules/get_league_rules.dart';

part 'fs_rules_event.dart';
part 'fs_rules_state.dart';

class FsRulesBloc extends Bloc<FsRulesEvent, FsRulesState> {
  final GetLeagueRules _getLeagueRules;
  final RefreshFsRule _refreshFsRule;
  final UnlockFsRule _unlockFsRule;
  final SetFsRuleAsCompleted _setFsRuleAsCompleted;
  final SetFsRuleAsUncompleted _setFsRuleAsUncompleted;
  final InsertRulesForLeagueFromExisting _insertRulesForLeagueFromExisting;
  final AppFsLeagueCubit _appFsLeagueCubit;
  final LockFsRule _lockFsRule;
  final AppUserCubit _appUserCubit;

  StreamSubscription? _userSubscription;

  FsRulesBloc({
    required GetLeagueRules getLeagueRules,
    required RefreshFsRule refreshFsRule,
    required UnlockFsRule unlockFsRule,
    required SetFsRuleAsCompleted setFsRuleAsCompleted,
    required SetFsRuleAsUncompleted setFsRuleAsUncompleted,
    required InsertRulesForLeagueFromExisting insertRulesForLeagueFromExisting,
    required AppFsLeagueCubit appFsLeagueCubit,
    required LockFsRule lockFsRule,
    required AppUserCubit appUserCubit,
  })  : _getLeagueRules = getLeagueRules,
        _refreshFsRule = refreshFsRule,
        _unlockFsRule = unlockFsRule,
        _setFsRuleAsCompleted = setFsRuleAsCompleted,
        _setFsRuleAsUncompleted = setFsRuleAsUncompleted,
        _insertRulesForLeagueFromExisting = insertRulesForLeagueFromExisting,
        _appFsLeagueCubit = appFsLeagueCubit,
        _lockFsRule = lockFsRule,
        _appUserCubit = appUserCubit,
        super(FsRulesInitial()) {
    on<GetLeagueRulesEvent>(_onGetLeagueRules);
    on<RefreshRuleEvent>(_onRefreshRule);
    on<UnlockRuleEvent>(_onUnlockRule);
    on<SetRuleAsCompletedEvent>(_onSetRuleAsCompleted);
    on<SetRuleAsUncompletedEvent>(_onSetRuleAsUncompleted);
    on<InsertRulesForLeagueFromExistingEvent>(
        _onInsertRulesForLeagueFromExisting);
    on<LockRuleEvent>(_onLockRule);
    on<UpdateRulesLocallyEvent>(_onUpdateRulesLocally);

    // Listen to premium status changes
    _userSubscription = _appUserCubit.stream.listen(_onUserStateChanged);
  }

  void _updateRuleInState({
    required FsRulesState previousState,
    required String oldChallengeId,
    required FsRule updatedRule,
    required String leagueId,
    required Emitter<FsRulesState> emit,
  }) {
    if (previousState is FsRulesLoaded) {
      final updatedRules = List<FsRule>.from(previousState.rules);

      // 1) trova ID della regola aggiornata
      try {
        int index = updatedRules.indexWhere((r) => r.id == updatedRule.id);

        if (index != -1) {
          updatedRules[index] = updatedRule;
        }

        emit(FsRulesLoaded(updatedRules));
      } catch (e) {
        emit(FsRulesFailure("Errore durante l'aggiornamento della regola."));
      }
    } else {
      add(GetLeagueRulesEvent(leagueId: leagueId));
    }
  }

  FutureOr<void> _onGetLeagueRules(
    GetLeagueRulesEvent event,
    Emitter<FsRulesState> emit,
  ) async {
    emit(FsRulesLoading());

    final result = await _getLeagueRules(GetLeagueRulesParams(
      leagueId: event.leagueId,
    ));

    result.fold(
      (failure) {
        emit(FsRulesFailure(failure.message));
      },
      (rules) {
        emit(FsRulesLoaded(rules));
      },
    );
  }

  FutureOr<void> _onRefreshRule(
    RefreshRuleEvent event,
    Emitter<FsRulesState> emit,
  ) async {
    final previousState = state;
    emit(FsRulesLoading());

    final result = await _refreshFsRule(RefreshFsRuleParams(
      leagueId: event.leagueId,
      challengeId: event.challengeId,
    ));

    result.fold(
      (failure) => emit(FsRulesFailure(failure.message)),
      (rule) => _updateRuleInState(
        previousState: previousState,
        oldChallengeId: event.challengeId,
        updatedRule: rule,
        leagueId: event.leagueId,
        emit: emit,
      ),
    );
  }

  FutureOr<void> _onUnlockRule(
    UnlockRuleEvent event,
    Emitter<FsRulesState> emit,
  ) async {
    final previousState = state;
    emit(FsRulesLoading());

    final result = await _unlockFsRule(UnlockFsRuleParams(
      leagueId: event.leagueId,
      challengeId: event.challengeId,
    ));

    result.fold(
      (failure) => emit(FsRulesFailure(failure.message)),
      (rule) => _updateRuleInState(
        previousState: previousState,
        oldChallengeId: event.challengeId,
        updatedRule: rule,
        leagueId: event.leagueId,
        emit: emit,
      ),
    );
  }

  FutureOr<void> _onSetRuleAsCompleted(
    SetRuleAsCompletedEvent event,
    Emitter<FsRulesState> emit,
  ) async {
    final previousState = state;

    final result = await _setFsRuleAsCompleted(SetFsRuleAsCompletedParams(
      leagueId: event.leagueId,
      challengeId: event.challengeId,
      ruleName: event.ruleName,
      points: event.points,
      type: event.type,
    ));

    result.fold(
      (failure) => emit(FsRulesFailure(failure.message)),
      (rule) async {
        _updateRuleInState(
          previousState: previousState,
          oldChallengeId: event.challengeId,
          updatedRule: rule,
          leagueId: event.leagueId,
          emit: emit,
        );

        await _appFsLeagueCubit.checkFsLeague();
      },
    );
  }

  FutureOr<void> _onSetRuleAsUncompleted(
    SetRuleAsUncompletedEvent event,
    Emitter<FsRulesState> emit,
  ) async {
    final previousState = state;

    final result = await _setFsRuleAsUncompleted(SetFsRuleAsUncompletedParams(
      leagueId: event.leagueId,
      userId: event.userId,
      challengeId: event.challengeId,
    ));

    result.fold(
      (failure) => emit(FsRulesFailure(failure.message)),
      (rule) async {
        _updateRuleInState(
          previousState: previousState,
          oldChallengeId: event.challengeId,
          updatedRule: rule,
          leagueId: event.leagueId,
          emit: emit,
        );

        await _appFsLeagueCubit.checkFsLeague();
      },
    );
  }

  FutureOr<void> _onInsertRulesForLeagueFromExisting(
    InsertRulesForLeagueFromExistingEvent event,
    Emitter<FsRulesState> emit,
  ) async {
    emit(FsRulesLoading());

    final result = await _insertRulesForLeagueFromExisting(
      InsertRulesForLeagueFromExistingParams(
        leagueId: event.leagueId,
        name: event.name,
        points: event.points,
        typeText: event.typeText,
      ),
    );

    result.fold(
      (failure) => emit(FsRulesFailure(failure.message)),
      (rules) => emit(
        FsRulesLoaded(rules),
      ),
    );
  }

  FutureOr<void> _onLockRule(
    LockRuleEvent event,
    Emitter<FsRulesState> emit,
  ) async {
    final previousState = state;
    emit(FsRulesLoading());

    final result = await _lockFsRule(LockFsRuleParams(
      leagueId: event.leagueId,
      challengeId: event.challengeId,
    ));

    result.fold(
      (failure) => emit(FsRulesFailure(failure.message)),
      (rule) => _updateRuleInState(
        previousState: previousState,
        oldChallengeId: event.challengeId,
        updatedRule: rule,
        leagueId: event.leagueId,
        emit: emit,
      ),
    );
  }

  // Handle premium status changes and update rules locally
  void _onUserStateChanged(dynamic userState) {
    if (userState is AppUserIsLoggedIn &&
        _appFsLeagueCubit.state is AppFsLeagueExists) {
      final currentState = state;

      // Solo se abbiamo regole caricate
      if (currentState is FsRulesLoaded) {
        if (userState.user.isPremium) {
          add(UpdateRulesLocallyEvent(
            rules: currentState.rules,
            isPremium: true,
          ));
        } else {
          add(UpdateRulesLocallyEvent(
            rules: currentState.rules,
            isPremium: false,
          ));
        }
      }
    }
  }

  // Handle local rule updates
  FutureOr<void> _onUpdateRulesLocally(
    UpdateRulesLocallyEvent event,
    Emitter<FsRulesState> emit,
  ) async {
    if (event.isPremium) {
      // Sblocca tutte le regole localmente
      final updatedRules = event.rules.map((rule) {
        return FsRule(
          id: rule.id,
          userId: rule.userId,
          userName: rule.userName,
          leagueId: rule.leagueId,
          challengeId: rule.challengeId,
          name: rule.name,
          points: rule.points,
          type: rule.type,
          position: rule.position,
          isUnlocked: true,
          isCompleted: rule.isCompleted,
          isRefreshed: rule.isRefreshed,
          createdAt: rule.createdAt,
          completedAt: rule.completedAt,
          refreshedAt: rule.refreshedAt,
        );
      }).toList();

      emit(FsRulesLoaded(updatedRules));
    } else {
      // Blocca solo le regole premium localmente
      final updatedRules = event.rules.map((rule) {
        if (_isPremiumRule(rule) && !rule.isCompleted) {
          return FsRule(
            id: rule.id,
            userId: rule.userId,
            userName: rule.userName,
            leagueId: rule.leagueId,
            challengeId: rule.challengeId,
            name: rule.name,
            points: rule.points,
            type: rule.type,
            position: rule.position,
            isUnlocked: false,
            isCompleted: rule.isCompleted,
            isRefreshed: rule.isRefreshed,
            createdAt: rule.createdAt,
            completedAt: rule.completedAt,
            refreshedAt: rule.refreshedAt,
          );
        }
        return rule;
      }).toList();

      emit(FsRulesLoaded(updatedRules));
    }
  }

  // Helper method to determine if a rule is premium
  bool _isPremiumRule(FsRule rule) {
    return rule.position == 2 || rule.position == 3;
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
