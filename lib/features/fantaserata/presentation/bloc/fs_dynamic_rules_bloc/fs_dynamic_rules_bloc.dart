import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_dynamic_rules/get_user_dynamic_rules.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_dynamic_rules/refresh_fs_dynamic_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_dynamic_rules/unlock_fs_dynamic_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/use_cases/fs_dynamic_rules/set_fs_dynamic_rule_as_completed.dart';

part 'fs_dynamic_rules_event.dart';
part 'fs_dynamic_rules_state.dart';

class FsDynamicRulesBloc
    extends Bloc<FsDynamicRulesEvent, FsDynamicRulesState> {
  final GetUserDynamicRules _getUserDynamicRules;
  final RefreshFsDynamicRule _refreshFsDynamicRule;
  final UnlockFsDynamicRule _unlockFsDynamicRule;
  final SetFsDynamicRuleAsCompleted _setFsDynamicRuleAsCompleted;

  FsDynamicRulesBloc({
    required GetUserDynamicRules getUserDynamicRules,
    required RefreshFsDynamicRule refreshFsDynamicRule,
    required UnlockFsDynamicRule unlockFsDynamicRule,
    required SetFsDynamicRuleAsCompleted setFsDynamicRuleAsCompleted,
  })  : _getUserDynamicRules = getUserDynamicRules,
        _refreshFsDynamicRule = refreshFsDynamicRule,
        _unlockFsDynamicRule = unlockFsDynamicRule,
        _setFsDynamicRuleAsCompleted = setFsDynamicRuleAsCompleted,
        super(FsDynamicRulesInitial()) {
    on<FsDynamicRulesEvent>((event, emit) => emit(FsDynamicRulesLoading()));
    on<GetUserDynamicRulesEvent>(_onGetUserDynamicRules);
    on<RefreshDynamicRuleEvent>(_onRefreshDynamicRule);
    on<UnlockDynamicRuleEvent>(_onUnlockDynamicRule);
    on<SetDynamicRuleAsCompletedEvent>(_onSetDynamicRuleAsCompleted);
  }

  FutureOr<void> _onGetUserDynamicRules(
    GetUserDynamicRulesEvent event,
    Emitter<FsDynamicRulesState> emit,
  ) async {
    final result = await _getUserDynamicRules(GetUserDynamicRulesParams(
      userId: event.userId,
      leagueId: event.leagueId,
    ));

    result.fold(
      (failure) {
        emit(FsDynamicRulesFailure(failure.message));
      },
      (rules) {
        emit(FsDynamicRulesLoaded(rules));
      },
    );
  }

  FutureOr<void> _onRefreshDynamicRule(
    RefreshDynamicRuleEvent event,
    Emitter<FsDynamicRulesState> emit,
  ) async {
    final result = await _refreshFsDynamicRule(RefreshFsDynamicRuleParams(
      userId: event.userId,
      leagueId: event.leagueId,
      challengeId: event.challengeId,
    ));

    result.fold(
      (failure) => emit(FsDynamicRulesFailure(failure.message)),
      (rule) {
        final oldState = state as FsDynamicRulesLoaded;

        emit(FsDynamicRulesLoaded(oldState.rules).copyWith(
          rule: rule,
        ));
      },
    );
  }

  FutureOr<void> _onUnlockDynamicRule(
    UnlockDynamicRuleEvent event,
    Emitter<FsDynamicRulesState> emit,
  ) async {
    final result = await _unlockFsDynamicRule(UnlockFsDynamicRuleParams(
      userId: event.userId,
      leagueId: event.leagueId,
      challengeId: event.challengeId,
    ));

    result.fold(
      (failure) => emit(FsDynamicRulesFailure(failure.message)),
      (rule) {
        final oldState = state as FsDynamicRulesLoaded;

        emit(FsDynamicRulesLoaded(oldState.rules).copyWith(
          rule: rule,
        ));
      },
    );
  }

  FutureOr<void> _onSetDynamicRuleAsCompleted(
    SetDynamicRuleAsCompletedEvent event,
    Emitter<FsDynamicRulesState> emit,
  ) async {
    final result =
        await _setFsDynamicRuleAsCompleted(SetFsDynamicRuleAsCompletedParams(
      userId: event.userId,
      leagueId: event.leagueId,
      challengeId: event.challengeId,
      ruleName: event.ruleName,
      points: event.points,
      type: event.type,
    ));

    result.fold((failure) => emit(FsDynamicRulesFailure(failure.message)),
        (rule) {
      final oldState = state as FsDynamicRulesLoaded;

      emit(FsDynamicRulesLoaded(oldState.rules).copyWith(
        rule: rule,
      ));
    });
  }
}
