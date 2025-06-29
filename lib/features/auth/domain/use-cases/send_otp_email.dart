import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SendOtpEmailParams {
  final String email;
  final String hCaptcha;

  SendOtpEmailParams({
    required this.email,
    required this.hCaptcha,
  });
}

class SendOtpEmail implements Usecase<void, SendOtpEmailParams> {
  final AuthRepository authRepository;

  SendOtpEmail({required this.authRepository});

  @override
  Future<Either<Failure, void>> call(SendOtpEmailParams params) async {
    return await authRepository.sendPasswordResetOtp(
      email: params.email,
      hCaptcha: params.hCaptcha,
    );
  }
}
