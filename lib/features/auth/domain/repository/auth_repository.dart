import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> googleSignIn({
    required bool isAdult,
    required bool isTermsAccepted,
  });

  Future<Either<Failure, User>> appleSignIn({
    required bool isAdult,
    required bool isTermsAccepted,
  });

  Future<Either<Failure, void>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    required String hCaptcha,
    required bool isAdult,
    required bool isTermsAccepted,
  });

  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
    required String hCaptcha,
  });

  Future<Either<Failure, User>> changeIsOnboardedValue({
    required bool newValue,
  });

  Future<Either<Failure, User>> currentUser();

  Future<Either<Failure, void>> signOut();
}
