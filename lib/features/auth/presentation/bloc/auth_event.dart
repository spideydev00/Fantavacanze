part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthGoogleSignIn extends AuthEvent {}

class AuthAppleSignIn extends AuthEvent {}

class AuthEmailSignIn extends AuthEvent {
  final String email;
  final String password;
  final String hCaptcha;

  AuthEmailSignIn(
      {required this.email, required this.password, required this.hCaptcha});
}

class AuthEmailSignUp extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String hCaptcha;

  AuthEmailSignUp(
      {required this.name,
      required this.email,
      required this.password,
      required this.hCaptcha});
}

// class AuthFacebookSignIn extends AuthEvent {}
