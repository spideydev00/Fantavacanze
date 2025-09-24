import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateIsSingleStatus implements Usecase<User, String?> {
  final AuthRepository authRepository;

  UpdateIsSingleStatus({required this.authRepository});

  @override
  Future<Either<Failure, User>> call(String? status) async {
    return await authRepository.updateIsSingleStatus(status: status);
  }
}
