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
  final String gender;
  final String hCaptcha;
  final bool isAdult;

  AuthEmailSignUp({
    required this.name,
    required this.email,
    required this.password,
    required this.gender,
    required this.hCaptcha,
    required this.isAdult,
  });
}

class AuthSignOut extends AuthEvent {}

class AuthChangeIsOnboardedValue extends AuthEvent {
  final bool isOnboarded;

  AuthChangeIsOnboardedValue({required this.isOnboarded});
}

class AuthUpdateConsents extends AuthEvent {
  final bool isAdult;

  AuthUpdateConsents({
    required this.isAdult,
  });
}

class AuthUpdateGender extends AuthEvent {
  final String? gender;

  AuthUpdateGender({
    required this.gender,
  });
}

// New events for password reset
class AuthSendOtpEmail extends AuthEvent {
  final String email;
  final String hCaptcha;

  AuthSendOtpEmail({
    required this.email, 
    required this.hCaptcha,
  });
}

class AuthVerifyOtp extends AuthEvent {
  final String email;
  final String otp;
  final bool isPasswordReset;

  AuthVerifyOtp({
    required this.email,
    required this.otp,
    this.isPasswordReset = false,
  });
}

class AuthResetPassword extends AuthEvent {
  final String email;
  final String token;
  final String newPassword;

  AuthResetPassword({
    required this.email,
    required this.token,
    required this.newPassword,
  });
}
