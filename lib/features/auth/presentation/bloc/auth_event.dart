part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthGoogleSignIn extends AuthEvent {}

class AuthAppleSignIn extends AuthEvent {}

class AuthEmailSignIn extends AuthEvent {
  final String email;
  final String password;
  final String hCaptcha;

  AuthEmailSignIn({
    required this.email,
    required this.password,
    required this.hCaptcha,
  });
}

class AuthEmailSignUp extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String hCaptcha;
  final bool isAdult;
  final bool isTermsAccepted;

  AuthEmailSignUp({
    required this.name,
    required this.email,
    required this.password,
    required this.hCaptcha,
    required this.isAdult,
    required this.isTermsAccepted,
  });
}

class AuthSignOut extends AuthEvent {}

class AuthChangeIsOnboardedValue extends AuthEvent {
  final bool isOnboarded;

  AuthChangeIsOnboardedValue({required this.isOnboarded});
}

class AuthUpdateConsents extends AuthEvent {
  final bool isAdult;
  final bool isTermsAccepted;

  AuthUpdateConsents({
    required this.isAdult,
    required this.isTermsAccepted,
  });
}
