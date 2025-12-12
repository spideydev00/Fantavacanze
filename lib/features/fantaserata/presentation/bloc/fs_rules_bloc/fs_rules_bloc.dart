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
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule_completion.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_rules/get_league_rules.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_rules/get_fs_rule_completions.dart';

part 'fs_rules_event.dart';
part 'fs_rules_state.dart';

class FsRulesBloc extends Bloc<FsRulesEvent, FsRulesState> {
  final GetLeagueRules _getLeagueRules;
  final RefreshFsRule _refreshFsRule;
  final UnlockFsRule _unlockFsRule;
  final SetFsRuleAsCompleted _setFsRuleAsCompleted;
  final SetFsRuleAsUncompleted _setFsRuleAsUncompleted;
  final InsertRulesForLeagueFromExisting _insertRulesForLeagueFromExisting;
  final GetFsRuleCompletions _getFsRuleCompletions;
  final AppFsLeagueCubit _appFsLeagueCubit;
  final LockFsRule _lockFsRule;
  final AppUserCubit _appUserCubit;
  bool _isFetchingRules = false;

  StreamSubscription? _userSubscription;

  FsRulesBloc({
    required GetLeagueRules getLeagueRules,
    required RefreshFsRule refreshFsRule,
    required UnlockFsRule unlockFsRule,
    required SetFsRuleAsCompleted setFsRuleAsCompleted,
    required SetFsRuleAsUncompleted setFsRuleAsUncompleted,
    required InsertRulesForLeagueFromExisting insertRulesForLeagueFromExisting,
    required GetFsRuleCompletions getFsRuleCompletions,
    required AppFsLeagueCubit appFsLeagueCubit,
    required LockFsRule lockFsRule,
    required AppUserCubit appUserCubit,
  })  : _getLeagueRules = getLeagueRules,
        _refreshFsRule = refreshFsRule,
        _unlockFsRule = unlockFsRule,
        _setFsRuleAsCompleted = setFsRuleAsCompleted,
        _setFsRuleAsUncompleted = setFsRuleAsUncompleted,
        _insertRulesForLeagueFromExisting = insertRulesForLeagueFromExisting,
        _getFsRuleCompletions = getFsRuleCompletions,
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

  void _updateRuleState({
    required FsRule updatedRule,
    required String leagueId,
    required Emitter<FsRulesState> emit,
    FsRuleCompletion? completionToAdd,
    String? completionIdToRemove,
    bool removeCompletionByChallenge = false,
  }) {
    final currentState = state;

    if (currentState is! FsRulesLoaded) {
      add(GetLeagueRulesEvent(leagueId: leagueId));
      return;
    }

    bool ruleUpdated = false;

    final updatedRules = currentState.rules.map((rule) {
      final matches =
          rule.id == updatedRule.id || rule.challengeId == updatedRule.challengeId;
      if (!matches) return rule;
      ruleUpdated = true;
      return _mergeRule(rule, updatedRule);
    }).toList();

    if (!ruleUpdated) {
      updatedRules.add(updatedRule);
    }

    final updatedCompletions =
        List<FsRuleCompletion>.from(currentState.completions);

    if (completionIdToRemove != null) {
      updatedCompletions.removeWhere((c) => c.id == completionIdToRemove);
    } else if (removeCompletionByChallenge) {
      updatedCompletions
          .removeWhere((c) => c.challengeId == updatedRule.challengeId);
    }

    if (completionToAdd != null) {
      if (completionToAdd.isDynamic) {
        updatedCompletions
            .removeWhere((c) => c.challengeId == completionToAdd.challengeId);
      }
      updatedCompletions.add(completionToAdd);
    }

    updatedCompletions
        .sort((a, b) => b.completedAt.compareTo(a.completedAt));

    emit(FsRulesLoaded(
      updatedRules,
      completions: updatedCompletions,
    ));
  }

  FsRule _mergeRule(FsRule existing, FsRule updated) {
    return FsRule(
      id: existing.id,
      userId: updated.userId,
      userName: updated.userName ?? existing.userName,
      completionId: updated.completionId ?? existing.completionId,
      leagueId: updated.leagueId,
      challengeId: updated.challengeId,
      name: updated.name,
      points: updated.points,
      type: updated.type,
      position: updated.position,
      isUnlocked: updated.isUnlocked,
      isCompleted: updated.isCompleted,
      isRefreshed: updated.isRefreshed,
      createdAt: updated.createdAt,
      completedAt: updated.completedAt,
      refreshedAt: updated.refreshedAt,
    );
  }

  FutureOr<void> _onGetLeagueRules(
    GetLeagueRulesEvent event,
    Emitter<FsRulesState> emit,
  ) async {
    if (_isFetchingRules) return;

    _isFetchingRules = true;

    emit(FsRulesLoading());

    try {
      final result = await _getLeagueRules(GetLeagueRulesParams(
        leagueId: event.leagueId,
      ));

      await result.fold(
        (failure) async {
          emit(FsRulesFailure(failure.message));
        },
        (rules) async {
          final completions = await _fetchCompletions(event.leagueId);
          emit(FsRulesLoaded(rules, completions: completions));
        },
      );
    } finally {
      _isFetchingRules = false;
    }
  }

  FutureOr<void> _onRefreshRule(
    RefreshRuleEvent event,
    Emitter<FsRulesState> emit,
  ) async {
    emit(FsRulesLoading());

    final result = await _refreshFsRule(RefreshFsRuleParams(
      leagueId: event.leagueId,
      challengeId: event.challengeId,
    ));

    result.fold(
      (failure) => emit(FsRulesFailure(failure.message)),
      (rule) => _updateRuleState(
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
    final result = await _unlockFsRule(UnlockFsRuleParams(
      leagueId: event.leagueId,
      challengeId: event.challengeId,
    ));

    result.fold(
      (failure) => emit(FsRulesFailure(failure.message)),
      (rule) => _updateRuleState(
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
    final result = await _setFsRuleAsCompleted(SetFsRuleAsCompletedParams(
      rule: event.rule,
    ));

    result.fold(
      (failure) => emit(FsRulesFailure(failure.message)),
      (payload) async {
        final fsRule = payload['fsRule'] as FsRule;
        final completion = payload['completion'] as FsRuleCompletion;

        _updateRuleState(
          updatedRule: fsRule,
          leagueId: fsRule.leagueId,
          emit: emit,
          completionToAdd: completion,
        );

        await _appFsLeagueCubit.checkFsLeague();
      },
    );
  }

  FutureOr<void> _onSetRuleAsUncompleted(
    SetRuleAsUncompletedEvent event,
    Emitter<FsRulesState> emit,
  ) async {
    final result = await _setFsRuleAsUncompleted(SetFsRuleAsUncompletedParams(
      rule: event.rule,
      completionId:
          event.completionId, // Pass completion ID for targeted deletion
    ));

    result.fold(
      (failure) => emit(FsRulesFailure(failure.message)),
      (rule) async {
        _updateRuleState(
          updatedRule: rule,
          leagueId: event.rule.leagueId,
          emit: emit,
          completionIdToRemove: event.completionId,
          removeCompletionByChallenge: event.completionId == null,
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

    if (result.isLeft()) {
      emit(
        FsRulesFailure(
          result.fold(
            (l) => l.message,
            (_) => '',
          ),
        ),
      );
    } else {
      final rules = result.fold((_) => <FsRule>[], (r) => r);

      final completions = await _fetchCompletions(event.leagueId);

      emit(FsRulesLoaded(rules, completions: completions));
    }
  }

  FutureOr<void> _onLockRule(
    LockRuleEvent event,
    Emitter<FsRulesState> emit,
  ) async {
    final result = await _lockFsRule(LockFsRuleParams(
      leagueId: event.leagueId,
      challengeId: event.challengeId,
    ));

    result.fold(
      (failure) => emit(FsRulesFailure(failure.message)),
      (rule) => _updateRuleState(
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
    final currentState = state;
    final completions = currentState is FsRulesLoaded
        ? currentState.completions
        : <FsRuleCompletion>[];

    if (event.isPremium) {
      // Sblocca tutte le regole localmente
      final updatedRules = event.rules.map((rule) {
        return FsRule(
          id: rule.id,
          userId: rule.userId,
          userName: rule.userName,
          completionId: rule.completionId,
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

      emit(FsRulesLoaded(updatedRules, completions: completions));
    } else {
      // Blocca solo le regole premium localmente
      final updatedRules = event.rules.map((rule) {
        if (_isPremiumRule(rule) && !rule.isCompleted) {
          return FsRule(
            id: rule.id,
            userId: rule.userId,
            userName: rule.userName,
            completionId: rule.completionId,
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

      emit(FsRulesLoaded(updatedRules, completions: completions));
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

  Future<List<FsRuleCompletion>> _fetchCompletions(String leagueId) async {
    final result = await _getFsRuleCompletions(
      GetFsRuleCompletionsParams(leagueId: leagueId),
    );

    return result.fold(
      (_) => <FsRuleCompletion>[],
      (completions) => completions,
    );
  }
}
