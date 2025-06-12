import 'dart:async';

import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/get_current_user.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/sign_out.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/update_display_name.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/update_password.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/delete_account.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/remove_consents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_user_state.dart';

class AppUserCubit extends Cubit<AppUserState> {
  final GetCurrentUser _getCurrentUser;
  final SignOut _signOut;
  final UpdateDisplayName _updateDisplayName;
  final UpdatePassword _updatePassword;
  final DeleteAccount _deleteAccount;
  final RemoveConsents _removeConsents;

  AppUserCubit({
    required GetCurrentUser getCurrentUser,
    required SignOut signOut,
    required UpdateDisplayName updateDisplayName,
    required UpdatePassword updatePassword,
    required DeleteAccount deleteAccount,
    required RemoveConsents removeConsents,
  })  : _getCurrentUser = getCurrentUser,
        _signOut = signOut,
        _updateDisplayName = updateDisplayName,
        _updatePassword = updatePassword,
        _deleteAccount = deleteAccount,
        _removeConsents = removeConsents,
        super(AppUserInitial());

  // Gets current user when app starts
  Future<void> getCurrentUser() async {
    final result = await _getCurrentUser(NoParams());

    result.fold(
      (failure) => emit(AppUserInitial()),
      (user) {
        // Uniforma questa logica con quella di updateUser
        if (!user.isOnboarded) {
          emit(AppUserNeedsOnboarding(user: user));
        } else if (user.gender == null) {
          emit(AppUserNeedsGender(user: user));
        } else {
          emit(AppUserIsLoggedIn(user: user));
        }
      },
    );
  }

  void updateUser(User? user) {
    if (user == null) {
      emit(AppUserInitial());
    } else if (!user.isOnboarded) {
      emit(AppUserNeedsOnboarding(user: user));
    } else if (user.gender == null) {
      emit(AppUserNeedsGender(user: user));
    } else {
      emit(AppUserIsLoggedIn(user: user));
    }
  }

  Future<void> signOut() async {
    if (state is AppUserIsLoggedIn) {
      final currentState = state as AppUserIsLoggedIn;

      final res = await _signOut.call(NoParams());

      return res.fold(
        (failure) {
          emit(currentState);
        },
        (_) async {
          // await _appLeagueCubit.clearCache();
          // Clear the user state and emit initial state
          emit(AppUserInitial());
        },
      );
    }
  }

  // Updates display name
  Future<void> updateDisplayName(String newName) async {
    if (state is AppUserIsLoggedIn) {
      final currentState = state as AppUserIsLoggedIn;

      final res = await _updateDisplayName(newName);

      res.fold(
        (failure) => emit(AppUserIsLoggedIn(
          user: currentState.user,
          errorMessage: failure.message,
        )),
        (user) => emit(AppUserIsLoggedIn(user: user)),
      );
    }
  }

  // Update password method
  Future<void> updatePassword(
    String oldPassword,
    String newPassword,
    String captchaToken,
  ) async {
    if (state is AppUserIsLoggedIn) {
      final currentState = state as AppUserIsLoggedIn;

      // Pass the captcha token to the repository
      final res = await _updatePassword(UpdatePasswordParams(
        oldPassword: oldPassword,
        newPassword: newPassword,
        captchaToken: captchaToken,
      ));

      res.fold(
        (failure) => emit(AppUserIsLoggedIn(
          user: currentState.user,
          errorMessage: failure.message,
        )),
        (_) => emit(AppUserInitial()),
      );
    }
  }

  // Deletes user account - returns true if successful, false otherwise
  Future<bool> deleteAccount() async {
    if (state is AppUserIsLoggedIn) {
      final currentState = state as AppUserIsLoggedIn;

      final res = await _deleteAccount(NoParams());

      return res.fold(
        (failure) {
          emit(AppUserIsLoggedIn(
            user: currentState.user,
            errorMessage: failure.message,
          ));
          return false;
        },
        (_) async {
          await signOut();
          emit(AppUserInitial());
          return true;
        },
      );
    }
    return false;
  }

  // Removes user consents and then signs out
  Future<void> removeConsents({
    required bool isAdult,
  }) async {
    if (state is AppUserIsLoggedIn) {
      final currentState = state as AppUserIsLoggedIn;

      final res = await _removeConsents(RemoveConsentsParams(
        isAdult: isAdult,
      ));

      res.fold(
        (failure) => emit(AppUserIsLoggedIn(
          user: currentState.user,
          errorMessage: failure.message,
        )),
        (_) async {
          // After removing consents, sign out
          await signOut();
        },
      );
    }
  }

  // Helper method to update user state with an error message
  void setErrorMessage(String message) {
    if (state is AppUserIsLoggedIn) {
      final currentState = state as AppUserIsLoggedIn;
      emit(AppUserIsLoggedIn(
        user: currentState.user,
        errorMessage: message,
      ));
    }
  }

  // Helper method to clear error message
  void clearErrorMessage() {
    if (state is AppUserIsLoggedIn) {
      final currentState = state as AppUserIsLoggedIn;
      if (currentState.errorMessage != null) {
        emit(AppUserIsLoggedIn(user: currentState.user));
      }
    }
  }
}
