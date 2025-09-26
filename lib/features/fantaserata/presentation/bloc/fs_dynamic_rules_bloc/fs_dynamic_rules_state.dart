part of 'fs_dynamic_rules_bloc.dart';

abstract class FsDynamicRulesState extends Equatable {
  const FsDynamicRulesState();

  @override
  List<Object?> get props => [];
}

class FsDynamicRulesInitial extends FsDynamicRulesState {}

class FsDynamicRulesLoading extends FsDynamicRulesState {}

class FsDynamicRulesLoaded extends FsDynamicRulesState {
  final List<FsRule> rules;

  const FsDynamicRulesLoaded(this.rules);

  @override
  List<Object> get props => [rules];

  FsDynamicRulesLoaded copyWith({
    FsRule? rule,
  }) {
    rules.removeWhere((r) => r.id == rule?.id);
    rules.add(rule!);

    return FsDynamicRulesLoaded(
      rules,
    );
  }
}

class FsDynamicRulesFailure extends FsDynamicRulesState {
  final String message;

  const FsDynamicRulesFailure(this.message);

  @override
  List<Object> get props => [message];
}
