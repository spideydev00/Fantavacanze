import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class Usecase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

abstract class StreamUsecase<SuccessType, Params> {
  Stream<Either<Failure, SuccessType>> call(Params params);
}

class NoParams {}
