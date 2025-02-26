import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/errors/server_exception.dart';
import 'package:fantavacanze_official/features/auth/data/remote_data_source/auth_remote_data_source.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  AuthRepositoryImpl({required this.authRemoteDataSource});

  //Google
  @override
  Future<Either<Failure, User>> googleSignIn() async {
    try {
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
      final user = await authRemoteDataSource.signInWithApple();

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
      final user = await authRemoteDataSource.loginWithEmailPassword(
          email: email, password: password, hCaptcha: hCaptcha);

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword(
      {required String name,
      required String email,
      required String password,
      required String hCaptcha}) async {
    try {
      final user = await authRemoteDataSource.signUpWithEmailPassword(
          name: name, email: email, password: password, hCaptcha: hCaptcha);

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
        return left(Failure("Nessun utente autenticato."));
      }

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
