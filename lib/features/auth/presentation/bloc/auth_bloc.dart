import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GoogleSignIn _googleSignIn;

  AuthBloc({required GoogleSignIn googleSignIn})
      : _googleSignIn = googleSignIn,
        super(AuthInitial()) {
    //google sign-in
    on<AuthGoogleSignIn>(_onGoogleSignIn);
    //others
  }

  Future<void> _onGoogleSignIn(
      AuthGoogleSignIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final res = await _googleSignIn.call(NoParams());

    res.fold((l) => emit(AuthFailure(l.message)), (r) => emit(AuthSuccess(r)));
  }
}
