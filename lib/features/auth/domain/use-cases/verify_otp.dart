import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class VerifyOtpParams {
  final String email;
  final String otp;
  final bool isPasswordReset;

  VerifyOtpParams({
    required this.email,
    required this.otp,
    this.isPasswordReset = false,
  });
}

class VerifyOtp implements Usecase<void, VerifyOtpParams> {
  final AuthRepository authRepository;

  VerifyOtp({required this.authRepository});

  @override
  Future<Either<Failure, void>> call(VerifyOtpParams params) async {
    return await authRepository.verifyOtp(
      email: params.email,
      otp: params.otp,
      isPasswordReset: params.isPasswordReset,
    );
  }
}
