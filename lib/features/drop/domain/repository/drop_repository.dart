import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/features/drop/domain/entities/drop.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class DropRepository {
  Future<Either<Failure, DropCheck>> getDropCheck();
  Future<Either<Failure, Unit>> markSeen(String code);
}
