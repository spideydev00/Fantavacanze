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
import 'package:fantavacanze_official/features/auth/domain/use-cases/update_consents.dart';
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
  final UpdateConsents _updateConsents;

  /// Qui salviamo qual è l'evento di login pendente (Email/Google/Apple)
  AuthEvent? _pendingAuthEvent;

  AuthBloc({
    required GoogleSignIn googleSignIn,
    required AppleSignIn appleSignIn,
    required EmailSignIn emailSignIn,
    required EmailSignUp emailSignUp,
    required SignOut signOut,
    required AppUserCubit appUserCubit,
    required AppLeagueCubit appLeagueCubit,
    required ChangeIsOnboardedValue changeIsOnboardedValue,
    required UpdateConsents updateConsents,
  })  : _googleSignIn = googleSignIn,
        _appleSignIn = appleSignIn,
        _emailSignIn = emailSignIn,
        _emailSignUp = emailSignUp,
        _signOut = signOut,
        _appUserCubit = appUserCubit,
        _appLeagueCubit = appLeagueCubit,
        _changeIsOnboardedValue = changeIsOnboardedValue,
        _updateConsents = updateConsents,
        super(AuthInitial()) {
    on<AuthGoogleSignIn>(_onGoogleSignIn);
    on<AuthAppleSignIn>(_onAppleSignIn);
    on<AuthEmailSignIn>(_onEmailSignIn);
    on<AuthEmailSignUp>(_onEmailSignUp);
    on<AuthSignOut>(_onSignOut);
    on<AuthChangeIsOnboardedValue>(_onChangeIsOnboardedValue);
    on<AuthUpdateConsents>(_onUpdateConsents);
  }

  Future<void> _onGoogleSignIn(
      AuthGoogleSignIn event, Emitter<AuthState> emit) async {
    emit(AuthGoogleLoading());
    _pendingAuthEvent = event;
    final res = await _googleSignIn.call(NoParams());

    res.fold(
      (failure) {
        if (failure.message == 'consent_required') {
          emit(AuthNeedsConsent(provider: 'Google'));
        } else {
          _pendingAuthEvent = null;
          emit(AuthFailure(failure.message));
        }
      },
      (user) {
        _pendingAuthEvent = null;
        _emitAuthSuccess(user, emit);
      },
    );
  }

  Future<void> _onAppleSignIn(
      AuthAppleSignIn event, Emitter<AuthState> emit) async {
    emit(AuthAppleLoading());
    _pendingAuthEvent = event;
    final res = await _appleSignIn.call(NoParams());

    res.fold(
      (failure) {
        if (failure.message == 'consent_required') {
          emit(AuthNeedsConsent(provider: 'Apple'));
        } else {
          _pendingAuthEvent = null;
          emit(AuthFailure(failure.message));
        }
      },
      (user) {
        _pendingAuthEvent = null;
        _emitAuthSuccess(user, emit);
      },
    );
  }

  Future<void> _onEmailSignIn(
      AuthEmailSignIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    _pendingAuthEvent = event;
    final result = await _emailSignIn.call(SignInParams(
      email: event.email,
      password: event.password,
      hCaptcha: event.hCaptcha,
    ));

    result.fold(
      (failure) {
        if (failure.message == 'consent_required') {
          emit(AuthNeedsConsent(provider: 'Email'));
        } else {
          _pendingAuthEvent = null;
          emit(AuthFailure(failure.message));
        }
      },
      (user) {
        _pendingAuthEvent = null;
        _emitAuthSuccess(user, emit);
      },
    );
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
        isAdult: event.isAdult,
        isTermsAccepted: event.isTermsAccepted,
      ),
    );

    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (_) => emit(AuthSignUpSuccess(event.email)),
    );
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

  Future<void> _onUpdateConsents(
      AuthUpdateConsents event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _updateConsents.call(UpdateConsentsParams(
      isAdult: event.isAdult,
      isTermsAccepted: event.isTermsAccepted,
    ));

    result.fold((failure) => emit(AuthFailure(failure.message)), (user) {
      // Get the pending event before clearing it
      final pending = _pendingAuthEvent;
      _pendingAuthEvent = null;

      if (pending != null && pending is! AuthEmailSignIn) {
        // → social login: automatically retry
        add(pending);
      } else {
        // → email login: just show consents updated state
        // and let user retry manually
        emit(AuthConsentsUpdated(user));
      }
    });
  }

  //Save information about user state (logged in or not)
  _emitAuthSuccess(User user, Emitter<AuthState> emit) {
    _appUserCubit.updateUser(user);

    // Only fetch leagues if user is fully onboarded - prevents error during onboarding
    if (user.isOnboarded) {
      _appLeagueCubit.getUserLeagues();
    }

    emit(AuthSuccess(user));
  }

  _emitLogoutSuccess(Emitter<AuthState> emit) {
    _appUserCubit.updateUser(null);
    emit(AuthInitial());
  }
}
