import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/app/domain/entities/app_status.dart';
import 'package:fpdart/fpdart.dart';

abstract class AppRepository {
  Future<Either<Failure, AppStatus>> getAppStatus();
}
