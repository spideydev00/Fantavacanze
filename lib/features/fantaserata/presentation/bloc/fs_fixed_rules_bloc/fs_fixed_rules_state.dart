part of 'fs_fixed_rules_bloc.dart';

abstract class FsFixedRulesState {
  const FsFixedRulesState();
}

class FsFixedRulesInitial extends FsFixedRulesState {}

class FsFixedRulesLoading extends FsFixedRulesState {}

class FsFixedRulesLoaded extends FsFixedRulesState {
  final List<DefaultFsRule> rules;

  const FsFixedRulesLoaded(this.rules);

  FsFixedRulesLoaded copyWith({
    List<DefaultFsRule>? rules,
  }) {
    return FsFixedRulesLoaded(rules ?? this.rules);
  }
}

class FsFixedRulesFailure extends FsFixedRulesState {
  final String message;

  const FsFixedRulesFailure(this.message);
}
