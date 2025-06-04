import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/secrets/app_secrets.dart';
import 'package:fantavacanze_official/features/auth/data/models/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<void> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required String hCaptcha,
    required String gender,
    required bool isAdult,
    required bool isTermsAccepted,
  });
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
    required String hCaptcha,
  });
  Future<void> signOut();
  Future<UserModel> changeIsOnboardedValue({
    required bool newValue,
  });
  Future<UserModel> updateDisplayName(String newName);
  Future<void> updatePassword(
      String oldPassword, String newPassword, String captchaToken);
  Future<void> deleteAccount();
  Future<void> removeConsents({
    required bool isAdult,
    required bool isTermsAccepted,
  });
  Future<UserModel> updateConsents({
    required bool isAdult,
    required bool isTermsAccepted,
  });
  Future<UserModel> updateGender({required String gender});
  Future<UserModel?> getCurrentUserData();
  Session? get currentSession;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  final firebaseMessaging = serviceLocator<FirebaseMessaging>();

  // Subscription to listen for changes in the fcm token
  StreamSubscription<String>? _tokenSubscription;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  // ------------------ Helper per “ripulire” l’errore ------------------

  String _extractErrorMessage(Object e) {
    if (e is ServerException) return e.message;
    if (e is AuthException) return e.message;
    if (e is PostgrestException) return e.message;
    if (e is TimeoutException) return e.message ?? 'Operazione scaduta';
    return e.toString();
  }

  // ------------------ GET CURRENT SESSION ------------------ //
  @override
  Session? get currentSession => supabaseClient.auth.currentSession;

  // ------------------ GET USER DATA ------------------ //
  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentSession == null) {
        throw ServerException('Nessuna sessione attiva');
      }

      final user = currentSession?.user;

      final userData = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', currentSession!.user.id);

      Map<String, dynamic> combinedData = userData.first;

      if (user != null && user.appMetadata.containsKey('provider')) {
        combinedData['raw_app_meta_data'] = user.appMetadata;
      }

      final userModel = UserModel.fromJson(combinedData)
          .copyWith(email: currentSession!.user.email);

      String token = '';

      if (!userModel.isAdult || !userModel.isTermsAccepted) {
        throw ServerException('consent_required');
      } else {
        _tokenSubscription = await initTokenSubscription(userId: userModel.id);
      }

      return userModel.copyWith(fcmToken: token);
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  // ------------------ APPLE SIGN-IN ------------------ //
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
      if (idToken == null) throw ServerException('ID token non trovato.');

      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      if (response.user == null) {
        throw ServerException("Errore nella creazione dell'utente.");
      }

      if (!(response.user!.userMetadata?.containsKey('full_name') ?? false)) {
        await supabaseClient.auth.updateUser(
          UserAttributes(
            data: {
              'full_name': credential.givenName,
              'is_adult': false,
              'is_terms_accepted': false,
            },
          ),
        );
      }

      final user = await getCurrentUserData();
      return user!;
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  // ------------------ EMAIL LOGIN ------------------ //
  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
    required String hCaptcha,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
        captchaToken: hCaptcha,
      );

      if (response.user == null) throw ServerException('Utente non valido!');

      final user = await getCurrentUserData();

      return user!.copyWith(email: response.user!.email ?? '');
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  // ------------------ GOOGLE SIGN-IN ------------------ //
  @override
  Future<UserModel> signInWithGoogle() async {
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

      final user = await getCurrentUserData();
      return user!;
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  // ------------------ EMAIL SIGNUP ------------------ //
  @override
  Future<void> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required String hCaptcha,
    required String gender,
    required bool isAdult,
    required bool isTermsAccepted,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        captchaToken: hCaptcha,
        data: {
          'name': name,
          'is_adult': isAdult,
          'is_terms_accepted': isTermsAccepted,
          'gender': gender,
        },
        emailRedirectTo: "https://fantavacanze.it/",
      );

      if (response.user == null) throw ServerException('Utente non creato!');
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  // ------------------ SIGN OUT ------------------ //
  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
      _tokenSubscription?.cancel();
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  // ------------------ CHANGE IS_ONBOARDED ------------------ //
  @override
  Future<UserModel> changeIsOnboardedValue({required bool newValue}) async {
    try {
      final response = await supabaseClient
          .from('profiles')
          .update({'is_onboarded': newValue})
          .eq('id', currentSession!.user.id)
          .select()
          .single();
      return UserModel.fromJson(response)
          .copyWith(email: currentSession!.user.email);
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  // ------------------ UPDATE DISPLAY NAME ------------------ //
  @override
  Future<UserModel> updateDisplayName(String newName) async {
    try {
      await supabaseClient.auth.updateUser(
        UserAttributes(data: {'full_name': newName}),
      );
      final user = await getCurrentUserData();
      if (user == null) {
        throw ServerException(
            "Errore nel recuperare i dati dell'utente aggiornati");
      }
      return user;
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  // ------------------ UPDATE PASSWORD ------------------ //
  @override
  Future<void> updatePassword(
      String oldPassword, String newPassword, String captchaToken) async {
    try {
      final email = currentSession?.user.email;
      if (email == null) throw ServerException('Email utente non disponibile');
      try {
        await supabaseClient.auth.signInWithPassword(
          email: email,
          password: oldPassword,
          captchaToken: captchaToken,
        );
      } catch (_) {
        throw ServerException('La password attuale è errata');
      }
      await supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      await signOut();
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  // ------------------ DELETE ACCOUNT ------------------ //
  @override
  Future<void> deleteAccount() async {
    try {
      await supabaseClient.rpc('delete_user_account');
      _tokenSubscription?.cancel();
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  // ------------------ REMOVE CONSENTS ------------------ //
  @override
  Future<void> removeConsents({
    required bool isAdult,
    required bool isTermsAccepted,
  }) async {
    try {
      if (currentSession?.user.id == null) {
        throw ServerException('Nessuna sessione attiva');
      }
      await supabaseClient.auth.updateUser(
        UserAttributes(data: {
          'is_adult': isAdult,
          'is_terms_accepted': isTermsAccepted,
        }),
      );
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  // ------------------ UPDATE CONSENTS ------------------ //
  @override
  Future<UserModel> updateConsents({
    required bool isAdult,
    required bool isTermsAccepted,
  }) async {
    try {
      final userId = currentSession?.user.id;

      if (userId == null) throw ServerException('Nessuna sessione attiva');

      await supabaseClient.auth.updateUser(
        UserAttributes(data: {
          'is_adult': isAdult,
          'is_terms_accepted': isTermsAccepted,
        }),
      );

      final profileJson = await supabaseClient
          .from('profiles')
          .update({
            'is_adult': isAdult,
            'is_terms_accepted': isTermsAccepted,
          })
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(profileJson)
          .copyWith(email: currentSession!.user.email);
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  //------------------ UPDATE GENDER ------------------ //
  @override
  Future<UserModel> updateGender({required String gender}) async {
    try {
      final userId = currentSession?.user.id;

      if (userId == null) throw ServerException('Utente non autenticato');

      final response = await supabaseClient
          .from('profiles')
          .update({'gender': gender})
          .eq('id', userId)
          .select()
          .single();

      final updatedUser = UserModel.fromJson(response)
          .copyWith(email: currentSession!.user.email);

      return updatedUser;
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

// // ------------------ FCM TOKEN MANAGEMENT ------------------ //
  Future<StreamSubscription<String>> initTokenSubscription(
      {String? userId}) async {
    try {
      await firebaseMessaging.requestPermission();

      await updateFcmToken(userId: userId);

      return firebaseMessaging.onTokenRefresh.listen((newToken) async {
        await updateFcmTokenManually(newToken);
        debugPrint('🪙 FCM Token aggiornato: $newToken');
      });
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  Future<String> updateFcmToken({String? userId}) async {
    try {
      // For iOS, first try to get the APNs token
      await firebaseMessaging.getAPNSToken();

      // Get the FCM token
      final token = await firebaseMessaging.getToken();

      debugPrint('🪙 FCM Token: $token');

      if (token == null || token.isEmpty) {
        throw ServerException('FCM token non disponibile');
      }

      final targetId = userId ?? currentSession?.user.id;

      if (targetId == null) {
        throw ServerException('Utente non autenticato');
      }

      await supabaseClient
          .from('profiles')
          .update({'fcm_token': token}).eq('id', targetId);

      return token;
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }

  Future<String> updateFcmTokenManually(String newToken) async {
    try {
      if (currentSession == null) {
        throw ServerException('Utente non autenticato');
      }

      final userId = currentSession!.user.id;

      await supabaseClient
          .from('profiles')
          .update({'fcm_token': newToken}).eq('id', userId);

      return newToken;
    } catch (e) {
      throw ServerException(_extractErrorMessage(e));
    }
  }
}
