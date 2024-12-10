import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:fantavacanze_official/core/errors/server_exception.dart';
import 'package:fantavacanze_official/core/secrets/app_secrets.dart';
import 'package:fantavacanze_official/features/auth/data/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  // void signInWithPhone();
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<UserModel> signInWithDiscord();
  void signInWithFacebook();
  void signUpWithEmailPassword();
  void signInWithEmailPassword();

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

      final user = response.user;

      if (user == null) {
        throw ServerException("Errore nella creazione dell'utente.");
      }

      final givenName = credential.givenName;
      final userId = user.id;
      late UserModel userModel;

      //Check if it's first access
      if (!(user.userMetadata!.containsKey('full_name'))) {
        //update auth.users to include name
        await supabaseClient.auth
            .updateUser(UserAttributes(data: {'full_name': givenName}));

        //update profiles
        await supabaseClient
            .from('profiles')
            .update({'name': givenName}).eq('id', userId);

        //create the user model with the updated name
        userModel = UserModel.fromJson(user.toJson()).copyWith(
          name: givenName,
        );

        return userModel;
      }

      //If it's not first access
      userModel = UserModel.fromJson(user.toJson());

      return userModel;
    } on AuthException catch (e) {
      throw ServerException(e.toString());
      //apple related exception
    } on SignInWithAppleException catch (e) {
      throw ServerException(e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ------------------ EMAIL SIGNIN ------------------ //
  @override
  void signInWithEmailPassword() {
    // TODO: implement signInWithDiscord
  }

  // ------------------ GOOGLE ------------------ //
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

  // ------------------ EMAIL SIGNUP ------------------ //
  @override
  void signUpWithEmailPassword() {
    // TODO: implement signInWithDiscord
  }

  // ------------------ DISCORD ------------------ //
  @override
  Future<UserModel> signInWithDiscord() async {
    try {
      final response = await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.discord,
        redirectTo: kIsWeb ? null : 'https://fantavacanze.it/auth/callback',
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication, //Fai partire app su web
      );

      if (!response) {
        throw ServerException("Nessuna risposta dal Server Discord.");
      }

      late UserModel userModel;

      // Puoi ascoltare i cambiamenti dello stato di autenticazione
      final StreamSubscription<AuthState> subscription =
          supabaseClient.auth.onAuthStateChange.listen(
        (data) {
          final Session? session = data.session;
          if (session != null) {
            final User user = session.user;
            // Crea il tuo UserModel con le informazioni dell'utente
            userModel = UserModel.fromJson(user.toJson());
            print("id: ${userModel.id}");
            print("email: ${userModel.email}");
            print("name: ${userModel.name}");
          }
        },
      );

      // Assicurati di gestire la cancellazione della subscription quando non è più necessaria
      subscription.cancel();

      return userModel;
    } on AuthException catch (e) {
      throw ServerException(e.toString());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ------------------ FACEBOOK ------------------ //
  @override
  void signInWithFacebook() {
    // TODO: implement signInWithFacebook
  }
}
