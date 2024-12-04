import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:fantavacanze_official/core/errors/server_exception.dart';
import 'package:fantavacanze_official/core/secrets/app_secrets.dart';
import 'package:fantavacanze_official/features/auth/data/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  // void signInWithPhone();
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  void signInWithDiscord();
  void signInWithFacebook();
  void signUpWithEmailPassword();
  void signInWithEmailPassword();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> signInWithApple() async {
    try {
      final rawNonce = supabaseClient.auth.generateRawNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw ServerException(
            'Impossibile trovare token ID dalle credenziali fornite!');
      }

      //autentica l'utente tramite IdToken
      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      if (response.user == null) {
        throw ServerException("Errore nella creazione dell'utente.");
      }

      final user = UserModel.fromJson(response.user!.toJson());

      return user;
    } on AuthException catch (e) {
      throw ServerException(e.toString());
      //apple related exception
    } on SignInWithAppleException catch (e) {
      throw ServerException(e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  void signInWithEmailPassword() {
    // TODO: implement signInWithDiscord
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      const iosClientId = AppSecrets.iosClientId;
      const webClientId = AppSecrets.webClientId;

      GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
        scopes: [
          'email',
        ],
      );

      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw ServerException('Nessun token di accesso trovato.');
      }
      if (idToken == null) {
        throw ServerException('Nessun ID Token trovato.');
      }

      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw ServerException("Errore nella creazione dell'utente.");
      }

      //create a user
      final user = UserModel.fromJson(response.user!.toJson());

      return user;
    } on AuthException catch (e) {
      throw ServerException(e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  void signUpWithEmailPassword() {
    // TODO: implement signInWithDiscord
  }

  @override
  void signInWithDiscord() {
    // TODO: implement signInWithDiscord
  }

  @override
  void signInWithFacebook() {
    // TODO: implement signInWithFacebook
  }
}
