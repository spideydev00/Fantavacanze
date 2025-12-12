import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/app/domain/entities/app_status.dart';
import 'package:fantavacanze_official/features/app/domain/repository/app_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAppStatus implements Usecase<AppStatus, NoParams> {
  final AppRepository appRepository;

  GetAppStatus({required this.appRepository});

  @override
  Future<Either<Failure, AppStatus>> call(NoParams params) async {
    return await appRepository.getAppStatus();
  }
}
