import 'dart:async';

import 'package:fantavacanze_official/core/errors/exceptions.dart';
import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/network/connection_checker.dart';
import 'package:fantavacanze_official/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final ConnectionChecker connectionChecker;

  AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.connectionChecker,
  });

  //Google
  @override
  Future<Either<Failure, User>> googleSignIn() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(
            Failure("Connessione a internet assente. Riprova più tardi."));
      }

      final user = await authRemoteDataSource.signInWithGoogle();
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  //Apple
  @override
  Future<Either<Failure, User>> appleSignIn() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(
            Failure("Connessione a internet assente. Riprova più tardi."));
      }

      final user = await authRemoteDataSource.signInWithApple();
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> removeConsents({
    required bool isAdult,
    required bool isTermsAccepted,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(
            Failure("Connessione a internet assente. Riprova più tardi."));
      }

      await authRemoteDataSource.removeConsents(
        isAdult: isAdult,
        isTermsAccepted: isTermsAccepted,
      );
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  //E-mail
  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
    required String hCaptcha,
    bool? isAdult,
    bool? isTermsAccepted,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(
            Failure("Connessione a internet assente. Riprova più tardi."));
      }

      final user = await authRemoteDataSource.loginWithEmailPassword(
        email: email,
        password: password,
        hCaptcha: hCaptcha,
      );
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required String hCaptcha,
    required bool isAdult,
    required bool isTermsAccepted,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(
            Failure("Connessione a internet assente. Riprova più tardi."));
      }

      // Verify age/terms
      if (!isAdult || !isTermsAccepted) {
        return left(Failure(
            "Devi avere almeno 18 anni e accettare i termini e condizioni."));
      }

      await authRemoteDataSource.signUpWithEmailPassword(
        name: name,
        email: email,
        password: password,
        hCaptcha: hCaptcha,
        isAdult: isAdult,
        isTermsAccepted: isTermsAccepted,
      );

      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> changeIsOnboardedValue(
      {required bool newValue}) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(
            Failure("Connessione a internet assente. Riprova più tardi."));
      }

      final user = await authRemoteDataSource.changeIsOnboardedValue(
        newValue: newValue,
      );

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  //Get User if logged in
  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      final user = await authRemoteDataSource.getCurrentUserData();
      if (user == null) {
        return left(Failure("No user logged in"));
      }
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await authRemoteDataSource.signOut();
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  // New methods for user profile management
  @override
  Future<Either<Failure, User>> updateDisplayName(String newName) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(
            "Nessuna connessione ad internet, riprova appena sarai connesso."));
      }

      final user = await authRemoteDataSource.updateDisplayName(newName);
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword(
    String oldPassword,
    String newPassword,
    String captchaToken,
  ) async {
    try {
      await authRemoteDataSource.updatePassword(
          oldPassword, newPassword, captchaToken);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(Failure(
            "Nessuna connessione ad internet, riprova appena sarai connesso."));
      }

      await authRemoteDataSource.deleteAccount();
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> updateConsents({
    required bool isAdult,
    required bool isTermsAccepted,
  }) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(
            Failure("Connessione a internet assente. Riprova più tardi."));
      }

      final user = await authRemoteDataSource.updateConsents(
        isAdult: isAdult,
        isTermsAccepted: isTermsAccepted,
      );
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
