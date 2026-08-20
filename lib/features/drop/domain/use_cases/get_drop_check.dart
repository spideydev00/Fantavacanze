import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/drop/domain/entities/drop.dart';
import 'package:fantavacanze_official/features/drop/domain/repository/drop_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetDropCheck implements Usecase<DropCheck, NoParams> {
  final DropRepository dropRepository;

  GetDropCheck({required this.dropRepository});

  @override
  Future<Either<Failure, DropCheck>> call(NoParams params) async {
    return dropRepository.getDropCheck();
  }
}
