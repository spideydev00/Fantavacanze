import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> googleSignIn();
  Future<Either<Failure, User>> appleSignIn();
  Future<Either<Failure, User>> currentUser();
}
