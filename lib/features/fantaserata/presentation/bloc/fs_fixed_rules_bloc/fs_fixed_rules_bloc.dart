import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/constants/fantaserata/default_fs_rule.dart';
import 'package:fantavacanze_official/core/constants/fantaserata/fs_fixed_rules.dart';

part 'fs_fixed_rules_event.dart';
part 'fs_fixed_rules_state.dart';

class FsFixedRulesBloc extends Bloc<FsFixedRulesEvent, FsFixedRulesState> {
  // Map to store completed rules per user
  final Map<String, Set<int>> _completedRules = {};

  FsFixedRulesBloc() : super(FsFixedRulesInitial()) {
    on<FsFixedRulesEvent>((event, emit) => emit(FsFixedRulesLoading()));
    on<GetFixedRulesEvent>(_onGetFixedRules);
    on<ToggleFixedRuleCompletionEvent>(_onToggleFixedRuleCompletion);
  }

  FutureOr<void> _onGetFixedRules(
    GetFixedRulesEvent event,
    Emitter<FsFixedRulesState> emit,
  ) async {
    try {
      final fsFixedRules = FsFixedRules();
      final userCompletedRules = _completedRules[event.userId] ?? <int>{};

      // Get rules based on user profile
      List<DefaultFsRule> baseRules = _getRulesForUser(
        event.gender,
        event.sentimentalStatus,
        fsFixedRules,
      );

      // Apply completion status
      final rules = baseRules.map((rule) {
        final isCompleted = userCompletedRules.contains(rule.id);
        return DefaultFsRule(
          id: rule.id,
          name: rule.name,
          type: rule.type,
          points: rule.points,
          isCompleted: isCompleted,
        );
      }).toList();

      emit(FsFixedRulesLoaded(rules));
    } catch (e) {
      emit(FsFixedRulesFailure('Errore nel caricamento delle regole: $e'));
    }
  }

  FutureOr<void> _onToggleFixedRuleCompletion(
    ToggleFixedRuleCompletionEvent event,
    Emitter<FsFixedRulesState> emit,
  ) async {
    if (state is! FsFixedRulesLoaded) return;

    final currentState = state as FsFixedRulesLoaded;

    // Update the rules list
    final updatedRules = currentState.rules.map((rule) {
      if (rule.id == event.ruleId) {
        return DefaultFsRule(
          id: rule.id,
          name: rule.name,
          type: rule.type,
          points: rule.points,
          isCompleted: event.isCompleted,
        );
      }
      return rule;
    }).toList();

    emit(FsFixedRulesLoaded(updatedRules));
  }

  List<DefaultFsRule> _getRulesForUser(
    String gender,
    String sentimentalStatus,
    FsFixedRules fsFixedRules,
  ) {
    final genderLower = gender.toLowerCase();
    final statusLower = sentimentalStatus.toLowerCase();
    final isSingle = statusLower == 'single';
    final isEngaged = statusLower == 'engaged';

    if (genderLower == 'male') {
      if (isSingle) {
        return fsFixedRules.singleMalesRules;
      } else if (isEngaged) {
        return fsFixedRules.engagedMalesRules;
      }
    } else if (genderLower == 'female') {
      if (isSingle) {
        return fsFixedRules.singleFemalesRules;
      } else if (isEngaged) {
        return fsFixedRules.engagedFemalesRules;
      }
    }

    // Default cases
    if (isSingle || sentimentalStatus.isEmpty) {
      return fsFixedRules.singleMixedRules;
    } else if (isEngaged) {
      return fsFixedRules.engagedMixedRules;
    }

    // Fallback
    return fsFixedRules.singleMixedRules;
  }

  void updateCompletedRule(String userId, int ruleId, bool isCompleted) {
    if (isCompleted) {
      _completedRules.putIfAbsent(userId, () => <int>{}).add(ruleId);
    } else {
      _completedRules[userId]?.remove(ruleId);
    }
  }
}
