import 'package:fpdart/fpdart.dart';

abstract interface class Usecase<Failure, SuccessType> {
  Future<Either<Failure, SuccessType>> call(params);
}

class NoParams {}
