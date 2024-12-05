import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/apple_sign_in.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/discord_sign_in.dart';
import 'package:fantavacanze_official/features/auth/domain/use-cases/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GoogleSignIn _googleSignIn;
  final AppleSignIn _appleSignIn;
  final DiscordSignIn _discordSignIn;

  AuthBloc(
      {required GoogleSignIn googleSignIn,
      required AppleSignIn appleSignIn,
      required DiscordSignIn discordSignIn})
      : _googleSignIn = googleSignIn,
        _appleSignIn = appleSignIn,
        _discordSignIn = discordSignIn,
        super(AuthInitial()) {
    //google sign-in
    on<AuthGoogleSignIn>(_onGoogleSignIn);
    //google sign-in
    on<AuthAppleSignIn>(_onAppleSignIn);
    //discord sign-in
    on<AuthDiscordSignIn>(_onDiscordSignIn);
    //others
  }

  Future<void> _onGoogleSignIn(
      AuthGoogleSignIn event, Emitter<AuthState> emit) async {
    emit(AuthGoogleLoading());
    final res = await _googleSignIn.call(NoParams());

    res.fold((l) => emit(AuthFailure(l.message)), (r) => emit(AuthSuccess(r)));
  }

  Future<void> _onAppleSignIn(
      AuthAppleSignIn event, Emitter<AuthState> emit) async {
    emit(AuthAppleOrFbLoading());
    final res = await _appleSignIn.call(NoParams());

    res.fold((l) => emit(AuthFailure(l.message)), (r) => emit(AuthSuccess(r)));
  }

  Future<void> _onDiscordSignIn(
      AuthDiscordSignIn event, Emitter<AuthState> emit) async {
    emit(AuthDiscordLoading());
    final res = await _discordSignIn.call(NoParams());

    res.fold((l) => emit(AuthFailure(l.message)), (r) => emit(AuthSuccess(r)));
  }
}
