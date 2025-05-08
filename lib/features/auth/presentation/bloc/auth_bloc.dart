import 'dart:async';

import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/apple_sign_in.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/change_is_onboarded_value.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/email_sign_in.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/email_sign_up.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/google_sign_in.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/sign_out.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GoogleSignIn _googleSignIn;
  final AppleSignIn _appleSignIn;
  final EmailSignIn _emailSignIn;
  final EmailSignUp _emailSignUp;
  final SignOut _signOut;
  final AppUserCubit _appUserCubit;
  final AppLeagueCubit _appLeagueCubit;
  final ChangeIsOnboardedValue _changeIsOnboardedValue;

  AuthBloc({
    required GoogleSignIn googleSignIn,
    required AppleSignIn appleSignIn,
    required EmailSignIn emailSignIn,
    required EmailSignUp emailSignUp,
    required SignOut signOut,
    required AppUserCubit appUserCubit,
    required AppLeagueCubit appLeagueCubit,
    required ChangeIsOnboardedValue changeIsOnboardedValue,
  })  : _googleSignIn = googleSignIn,
        _appleSignIn = appleSignIn,
        _emailSignIn = emailSignIn,
        _emailSignUp = emailSignUp,
        _signOut = signOut,
        _appUserCubit = appUserCubit,
        _appLeagueCubit = appLeagueCubit,
        _changeIsOnboardedValue = changeIsOnboardedValue,
        super(AuthInitial()) {
    //google sign-in
    on<AuthGoogleSignIn>(_onGoogleSignIn);
    //google sign-in
    on<AuthAppleSignIn>(_onAppleSignIn);
    //email sign-in
    on<AuthEmailSignIn>(_onEmailSignIn);
    //email sign_up
    on<AuthEmailSignUp>(_onEmailSignUp);
    //sign out
    on<AuthSignOut>(_onSignOut);
    //change isOnboarded value
    on<AuthChangeIsOnboardedValue>(_onChangeIsOnboardedValue);
  }

  Future<void> _onGoogleSignIn(
      AuthGoogleSignIn event, Emitter<AuthState> emit) async {
    emit(AuthGoogleLoading());
    final res = await _googleSignIn.call(NoParams());

    res.fold((l) => emit(AuthFailure("Google: ${l.message}")),
        (r) => emit(_emitAuthSuccess(r, emit)));
  }

  Future<void> _onAppleSignIn(
      AuthAppleSignIn event, Emitter<AuthState> emit) async {
    emit(AuthAppleLoading());
    final res = await _appleSignIn.call(NoParams());

    res.fold((l) => emit(AuthFailure("Apple: ${l.message}")),
        (r) => emit(_emitAuthSuccess(r, emit)));
  }

  Future<void> _onEmailSignIn(
      AuthEmailSignIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _emailSignIn.call(SignInParams(
        email: event.email,
        password: event.password,
        hCaptcha: event.hCaptcha));

    res.fold((l) => emit(AuthFailure(l.message)),
        (r) => emit(_emitAuthSuccess(r, emit)));
  }

  Future<void> _onEmailSignUp(
      AuthEmailSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _emailSignUp.call(
      SignUpParams(
        name: event.name,
        email: event.email,
        password: event.password,
        hCaptcha: event.hCaptcha,
      ),
    );

    res.fold((l) => emit(AuthFailure(l.message)),
        (r) => emit(_emitAuthSuccess(r, emit)));
  }

  Future<void> _onChangeIsOnboardedValue(
      AuthChangeIsOnboardedValue event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _changeIsOnboardedValue
        .call(ChangeIsOnboardedValueParams(newValue: event.isOnboarded));

    res.fold((l) => emit(AuthFailure(l.message)), (user) {
      _emitAuthSuccess(user, emit);
    });
  }

  Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _signOut.call(NoParams());

    res.fold((l) => emit(AuthFailure(l.message)), (_) {
      _emitLogoutSuccess(emit);
    });
  }

  //Save information about user state (logged in or not)
  _emitAuthSuccess(User user, Emitter<AuthState> emit) {
    _appUserCubit.updateUser(user);
    _appLeagueCubit.getUserLeagues();

    emit(AuthSuccess(user));
  }

  _emitLogoutSuccess(Emitter<AuthState> emit) {
    _appUserCubit.updateUser(null);
    emit(AuthInitial());
  }
}
