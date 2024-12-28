import 'dart:async';

import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit_cubit.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/apple_sign_in.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/facebook_sign_in.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GoogleSignIn _googleSignIn;
  final AppleSignIn _appleSignIn;
  final FacebookSignIn _facebookSignIn;
  final AppUserCubit _appUserCubit;

  AuthBloc({
    required GoogleSignIn googleSignIn,
    required AppleSignIn appleSignIn,
    required FacebookSignIn facebookSignIn,
    required AppUserCubit appUserCubit,
  })  : _googleSignIn = googleSignIn,
        _appleSignIn = appleSignIn,
        _appUserCubit = appUserCubit,
        _facebookSignIn = facebookSignIn,
        super(AuthInitial()) {
    //google sign-in
    on<AuthGoogleSignIn>(_onGoogleSignIn);
    //google sign-in
    on<AuthAppleSignIn>(_onAppleSignIn);
    //fb sign-in
    on<AuthFacebookSignIn>(_onFacebookSignIn);
    //others
  }

  Future<void> _onGoogleSignIn(
      AuthGoogleSignIn event, Emitter<AuthState> emit) async {
    emit(AuthGoogleLoading());
    final res = await _googleSignIn.call(NoParams());

    res.fold((l) => emit(AuthFailure(l.message)),
        (r) => emit(_emitAuthSuccess(r, emit)));
  }

  Future<void> _onAppleSignIn(
      AuthAppleSignIn event, Emitter<AuthState> emit) async {
    emit(AuthAppleOrFbLoading());
    final res = await _appleSignIn.call(NoParams());

    res.fold((l) => emit(AuthFailure(l.message)),
        (r) => emit(_emitAuthSuccess(r, emit)));
  }

  Future<void> _onFacebookSignIn(
      AuthFacebookSignIn event, Emitter<AuthState> emit) async {
    emit(AuthAppleOrFbLoading());
    final res = await _facebookSignIn.call(NoParams());

    res.fold((l) => emit(AuthFailure(l.message)),
        (r) => emit(_emitAuthSuccess(r, emit)));
  }

  //Save information about user state (logged in or not)
  _emitAuthSuccess(User user, Emitter<AuthState> emit) {
    _appUserCubit.updateUser(user);

    emit(AuthSuccess(user));
  }
}
