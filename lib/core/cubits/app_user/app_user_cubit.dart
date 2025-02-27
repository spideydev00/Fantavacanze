import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/get_current_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_user_state.dart';

class AppUserCubit extends Cubit<AppUserState> {
  final GetCurrentUser _getCurrentUser;

  AppUserCubit({required GetCurrentUser getCurrentUser})
      : _getCurrentUser = getCurrentUser,
        super(AppUserInitial());

  Future<void> getCurrentUser() async {
    final res = await _getCurrentUser.call(NoParams());

    res.fold(
      (l) => emit(
        AppUserInitial(),
      ),
      (r) => updateUser(r),
    );
  }

  void updateUser(User? user) {
    if (user == null) {
      emit(AppUserInitial());
    } else {
      emit(AppUserIsLoggedIn(user: user));
    }
  }
}
