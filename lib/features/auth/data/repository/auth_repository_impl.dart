import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/errors/server_exception.dart';
import 'package:fantavacanze_official/features/auth/data/remote_data_source/auth_remote_data_source.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  AuthRepositoryImpl({required this.authRemoteDataSource});

  @override
  Future<Either<Failure, User>> googleSignIn() async {
    try {
      final user = await authRemoteDataSource.signInWithGoogle();

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> appleSignIn() async {
    try {
      final user = await authRemoteDataSource.signInWithApple();

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> facebookSignIn() async {
    try {
      final user = await authRemoteDataSource.signInWithFacebook();

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
