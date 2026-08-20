import 'package:fantavacanze_official/core/errors/failure.dart';
import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/drop/domain/repository/drop_repository.dart';
import 'package:fpdart/fpdart.dart';

class MarkDropSeen implements Usecase<Unit, String> {
  final DropRepository dropRepository;

  MarkDropSeen({required this.dropRepository});

  @override
  Future<Either<Failure, Unit>> call(String code) async {
    return dropRepository.markSeen(code);
  }
}
