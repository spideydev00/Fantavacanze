import 'package:fantavacanze_official/core/use-case/usecase.dart';
import 'package:fantavacanze_official/features/drop/domain/entities/drop.dart';
import 'package:fantavacanze_official/features/drop/domain/use_cases/get_drop_check.dart';
import 'package:fantavacanze_official/features/drop/domain/use_cases/mark_drop_seen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class DropState {
  const DropState();
}

final class DropHidden extends DropState {
  const DropHidden();
}

final class DropVisible extends DropState {
  const DropVisible(this.drop);

  final Drop drop;
}

class DropCubit extends Cubit<DropState> {
  DropCubit({
    required GetDropCheck getDropCheck,
    required MarkDropSeen markDropSeen,
  })  : _getDropCheck = getDropCheck,
        _markDropSeen = markDropSeen,
        super(const DropHidden());

  final GetDropCheck _getDropCheck;
  final MarkDropSeen _markDropSeen;

  Future<void> check() async {
    final result = await _getDropCheck.call(NoParams());
    result.fold((_) {}, (check) {
      final drop = check.drop;
      if (drop != null && drop.code != check.lastSeenDrop) {
        emit(DropVisible(drop));
      }
    });
  }

  Future<void> dismiss() async {
    final current = state;
    if (current is! DropVisible) return;

    emit(const DropHidden());
    await _markDropSeen.call(current.drop.code);
  }

  void imageFailed() {
    if (state is DropVisible) emit(const DropHidden());
  }
}
