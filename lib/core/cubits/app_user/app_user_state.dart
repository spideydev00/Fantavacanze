part of 'app_user_cubit.dart';

@immutable
sealed class AppUserState {}

final class AppUserInitial extends AppUserState {}

final class AppUserIsLoggedIn extends AppUserState {
  final User user;
  final String? errorMessage;

  AppUserIsLoggedIn({required this.user, this.errorMessage});
}

final class AppUserNeedsOnboarding extends AppUserState {
  final User user;

  AppUserNeedsOnboarding({required this.user});
}

final class AppUserNeedsGender extends AppUserState {
  final User user;

  AppUserNeedsGender({
    required this.user,
  });
}
