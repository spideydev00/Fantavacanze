part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

//in order to display loader
final class AuthGoogleLoading extends AuthState {}

final class AuthAppleOrFbLoading extends AuthState {}

final class AuthDiscordLoading extends AuthState {}
// for just one button

final class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}

final class AuthSuccess extends AuthState {
  final User loggedUser;

  AuthSuccess(this.loggedUser);
}
