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
  Future<Either<Failure, User>> googleSignIn({
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

      final user = await authRemoteDataSource.signInWithGoogle(
        isAdult: isAdult,
        isTermsAccepted: isTermsAccepted,
      );
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  //Apple
  @override
  Future<Either<Failure, User>> appleSignIn({
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

      final user = await authRemoteDataSource.signInWithApple(
        isAdult: isAdult,
        isTermsAccepted: isTermsAccepted,
      );
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  //E-mail
  @override
  Future<Either<Failure, User>> loginWithEmailPassword(
      {required String email,
      required String password,
      required String hCaptcha}) async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(
            Failure("Connessione a internet assente. Riprova più tardi."));
      }

      final user = await authRemoteDataSource.loginWithEmailPassword(
          email: email, password: password, hCaptcha: hCaptcha);
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
      if (!await connectionChecker.isConnected) {
        final session = authRemoteDataSource.currentSession;

        if (session == null) {
          return left(Failure("Nessun utente autenticato."));
        }

        return right(
          User(
            id: session.user.id,
            email: session.user.email ?? 'No email found.',
            name: 'No name found.',
            isOnboarded: true,
            isAdult: true,
            isTermsAccepted: true,
          ),
        );
      }

      final user = await authRemoteDataSource.getCurrentUserData();
      if (user == null) {
        return left(Failure("Nessun utente autenticato."));
      }

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      if (!await connectionChecker.isConnected) {
        return left(
            Failure("Connessione a internet assente. Riprova più tardi."));
      }

      await authRemoteDataSource.signOut();
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
