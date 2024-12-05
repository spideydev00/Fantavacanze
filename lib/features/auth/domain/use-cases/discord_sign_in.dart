import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class DiscordSignIn implements Usecase<User, NoParams> {
  final AuthRepository authRepository;

  DiscordSignIn({required this.authRepository});

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await authRepository.discordSignIn();
  }
}
