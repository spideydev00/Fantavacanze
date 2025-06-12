part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

//in order to display loader
final class AuthGoogleLoading extends AuthState {}

final class AuthAppleLoading extends AuthState {}
// for just one button

final class AuthFailure extends AuthState {
  final String message;
  final String operation;

  AuthFailure(this.message, this.operation);
}

final class AuthSuccess extends AuthState {
  final User loggedUser;

  AuthSuccess(this.loggedUser);
}

// New state for successful signup
final class AuthSignUpSuccess extends AuthState {
  final String email;

  AuthSignUpSuccess(this.email);
}

// State for consents
class AuthNeedsConsent extends AuthState {
  final User? user;
  final String provider;

  AuthNeedsConsent({this.user, required this.provider});
}

class AuthConsentsUpdated extends AuthState {
  final User user;
  AuthConsentsUpdated(this.user);
}
