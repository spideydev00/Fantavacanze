import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/secrets/app_secrets.dart';
import 'package:fantavacanze_official/features/auth/data/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle({
    required bool isAdult,
    required bool isTermsAccepted,
  });

  Future<UserModel> signInWithApple({
    required bool isAdult,
    required bool isTermsAccepted,
  });

  Future<void> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required String hCaptcha,
    required bool isAdult,
    required bool isTermsAccepted,
  });

  Future<UserModel> loginWithEmailPassword(
      {required String email,
      required String password,
      required String hCaptcha});

  Future<void> signOut();

  Future<UserModel> changeIsOnboardedValue({
    required bool newValue,
  });

  //helper methods
  Future<UserModel?> getCurrentUserData();
  Session? get currentSession;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  AuthRemoteDataSourceImpl({required this.supabaseClient});

  // ------------------ GET CURRENT SESSION ------------------ //
  @override
  Session? get currentSession => supabaseClient.auth.currentSession;

  // ------------------ GET USER DATA ------------------ //
  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentSession != null) {
        final userData = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', currentSession!.user.id);

        return UserModel.fromJson(userData.first)
            .copyWith(email: currentSession!.user.email);
      }

      return null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ------------------ APPLE ------------------ //
  @override
  Future<UserModel> signInWithApple({
    required bool isAdult,
    required bool isTermsAccepted,
  }) async {
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
        throw ServerException('ID token non trovato.');
      }

      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      if (response.user == null) {
        throw ServerException("Errore nella creazione dell'utente.");
      }

      // Primo accesso → aggiorna profilo
      if (!(response.user!.userMetadata?.containsKey('full_name') ?? false) ||
          !(response.user!.userMetadata?.containsKey('is_adult') ?? false) ||
          !(response.user!.userMetadata?.containsKey('is_terms_accepted') ??
              false)) {
        final givenName = credential.givenName;

        await supabaseClient.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': givenName,
              'is_adult': isAdult,
              'is_terms_accepted': isTermsAccepted,
            },
          ),
        );
      }

      final user = await getCurrentUserData();

      return user!;
    } on AuthException catch (e) {
      throw ServerException(e.toString());
    } on SignInWithAppleException catch (e) {
      throw ServerException(e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ------------------ EMAIL SIGNIN ------------------ //
  @override
  Future<UserModel> loginWithEmailPassword(
      {required String email,
      required String password,
      required String hCaptcha}) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
        captchaToken: hCaptcha,
      );

      if (response.user == null) {
        throw ServerException('User is null!');
      }

      final user = await getCurrentUserData();

      return user!.copyWith(email: response.user!.email ?? '');
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ------------------ GOOGLE ------------------ //
  @override
  Future<UserModel> signInWithGoogle({
    required bool isAdult,
    required bool isTermsAccepted,
  }) async {
    try {
      const iosClientId = AppSecrets.iosClientId;
      const webClientId = AppSecrets.webClientId;

      final googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
        scopes: ['email'],
      );

      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw ServerException('Token di accesso o ID mancante.');
      }

      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw ServerException("Errore nella creazione dell'utente.");
      }

      // Primo accesso → aggiorna profilo
      if (!(response.user!.userMetadata?.containsKey('is_adult') ?? false) ||
          !(response.user!.userMetadata?.containsKey('is_terms_accepted') ??
              false)) {
        await supabaseClient.auth.updateUser(
          UserAttributes(
            data: {
              'is_adult': isAdult,
              'is_terms_accepted': isTermsAccepted,
            },
          ),
        );
      }

      final user = await getCurrentUserData();
      return user!;
    } on AuthException catch (e) {
      throw ServerException(e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ------------------ EMAIL SIGNUP ------------------ //
  @override
  Future<void> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required String hCaptcha,
    required bool isAdult,
    required bool isTermsAccepted,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        password: password,
        email: email,
        captchaToken: hCaptcha,
        data: {
          'name': name,
          'is_adult': isAdult,
          'is_terms_accepted': isTermsAccepted,
        },
        emailRedirectTo: "https://fantavacanze.it/",
      );

      if (response.user == null) {
        throw ServerException('User is null!');
      }

      // No need to return anything - user needs to verify email
      return;
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ------------------ SIGN OUT ------------------ //
  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ------------------ CHANGE ISONBOARDED VALUE ------------------ //
  @override
  Future<UserModel> changeIsOnboardedValue({required bool newValue}) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .update({'is_onboarded': newValue})
          .eq('id', currentSession!.user.id)
          .select()
          .single();

      return UserModel.fromJson(response).copyWith(
        email: currentSession!.user.email,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ------------------ FACEBOOK ------------------ //
  // @override
  // Future<UserModel> signInWithFacebook() async {
  //   try {
  //     final response = await supabaseClient.auth.signInWithOAuth(
  //       OAuthProvider.facebook,
  //       redirectTo:
  //           kIsWeb ? null : 'io.supabase.fantavacanze://login-callback/',
  //       authScreenLaunchMode: kIsWeb
  //           ? LaunchMode.platformDefault
  //           : LaunchMode
  //               .externalApplication, // Launch the auth screen in a new webview on mobile.
  //     );

  //     if (!response) {
  //       throw ServerException("Errore nella risposta da Facebook");
  //     }

  //     // final user = await getCurrentUserData();

  //     // print("email: ${user!.email}");
  //     // print("name: ${user!.name}");
  //     // print("id: ${user!.id}");

  //     // return user!;
  //   } catch (e) {
  //     throw ServerException(e.toString());
  //   }
  // }
}
