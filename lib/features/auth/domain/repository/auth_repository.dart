import 'dart:async';

import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> googleSignIn();

  Future<Either<Failure, User>> appleSignIn();

  Future<Either<Failure, void>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    String? gender,
    required String hCaptcha,
    required bool isAdult,
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

  // Methods for user profile management
  Future<Either<Failure, User>> updateDisplayName(String newName);

  Future<Either<Failure, void>> updatePassword(
    String oldPassword,
    String newPassword,
    String captchaToken,
  );

  Future<Either<Failure, void>> deleteAccount();

  Future<Either<Failure, void>> removeConsents({
    required bool isAdult,
  });

  Future<Either<Failure, User>> updateConsents({
    required bool isAdult,
  });

  Future<Either<Failure, User>> updateGender({required String? gender});
  Future<Either<Failure, User>> becomePremium();
  Future<Either<Failure, User>> removePremium();

  // New methods for password reset
  Future<Either<Failure, void>> sendPasswordResetOtp({
    required String email,
    required String hCaptcha,
  });

  Future<Either<Failure, void>> verifyOtp({
    required String email,
    required String otp,
    bool isPasswordReset,
  });

  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  });
}
