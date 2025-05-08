import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/get_current_user.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/sign_out.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_user_state.dart';

class AppUserCubit extends Cubit<AppUserState> {
  final GetCurrentUser _getCurrentUser;
  final SignOut _signOut;

  AppUserCubit({
    required GetCurrentUser getCurrentUser,
    required SignOut signOut,
  })  : _getCurrentUser = getCurrentUser,
        _signOut = signOut,
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
    } else if (!user.isOnboarded) {
      emit(AppUserNeedsOnboarding(user: user));
    } else {
      emit(AppUserIsLoggedIn(user: user));
    }
  }

  Future<bool> signOut() async {
    final res = await _signOut.call(NoParams());

    return res.fold((failure) {
      // Mantiene lo stato attuale in caso di errore
      return false;
    }, (_) {
      // Aggiorna lo stato a utente non loggato
      updateUser(null);
      return true;
    });
  }
}
