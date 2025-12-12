part of 'app_status_bloc.dart';

sealed class AppStatusEvent extends Equatable {
  const AppStatusEvent();

  @override
  List<Object> get props => [];
}

class GetAppStatusEvent extends AppStatusEvent {}
