part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthGoogleSignIn extends AuthEvent {}

class AuthAppleSignIn extends AuthEvent {}

class AuthDiscordSignIn extends AuthEvent {}
