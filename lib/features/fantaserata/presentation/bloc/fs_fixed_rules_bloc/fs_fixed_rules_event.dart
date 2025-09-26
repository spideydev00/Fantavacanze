part of 'fs_fixed_rules_bloc.dart';

abstract class FsFixedRulesEvent {
  const FsFixedRulesEvent();
}

class GetFixedRulesEvent extends FsFixedRulesEvent {
  final String userId;
  final String gender;
  final String sentimentalStatus;

  const GetFixedRulesEvent({
    required this.userId,
    required this.gender,
    required this.sentimentalStatus,
  });
}

class ToggleFixedRuleCompletionEvent extends FsFixedRulesEvent {
  final int ruleId;
  final bool isCompleted;

  const ToggleFixedRuleCompletionEvent({
    required this.ruleId,
    required this.isCompleted,
  });
}
