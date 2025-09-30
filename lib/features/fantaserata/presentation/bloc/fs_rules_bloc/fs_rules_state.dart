part of 'fs_rules_bloc.dart';

abstract class FsRulesState extends Equatable {
  const FsRulesState();

  @override
  List<Object?> get props => [];
}

class FsRulesInitial extends FsRulesState {}

class FsRulesLoading extends FsRulesState {}

class FsRulesLoaded extends FsRulesState {
  final List<FsRule> rules;

  const FsRulesLoaded(this.rules);

  @override
  List<Object> get props => [rules];
}

class FsRulesFailure extends FsRulesState {
  final String message;

  const FsRulesFailure(this.message);

  @override
  List<Object> get props => [message];
}
