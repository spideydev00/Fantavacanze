import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class Usecase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

abstract class StreamUsecase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

class NoParams {}
