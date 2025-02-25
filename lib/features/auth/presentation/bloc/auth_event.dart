part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthGoogleSignIn extends AuthEvent {}

class AuthAppleSignIn extends AuthEvent {}

class AuthEmailSignIn extends AuthEvent {
  final String email;
  final String password;

  AuthEmailSignIn({required this.email, required this.password});
}

class AuthEmailSignUp extends AuthEvent {
  final String name;
  final String email;
  final String password;

  AuthEmailSignUp(
      {required this.name, required this.email, required this.password});
}

// class AuthFacebookSignIn extends AuthEvent {}
