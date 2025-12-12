part of 'app_status_bloc.dart';

sealed class AppStatusState extends Equatable {
  const AppStatusState();

  @override
  List<Object> get props => [];
}

final class AppAvailable extends AppStatusState {}

final class AppUnavailable extends AppStatusState {}

final class AppStatusFailure extends AppStatusState {
  final String message;

  const AppStatusFailure(this.message);
}
