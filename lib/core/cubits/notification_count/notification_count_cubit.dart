import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationCountCubit extends Cubit<int> {
  NotificationCountCubit() : super(0);

  void increment() {
    final newCount = state + 1;
    emit(newCount);
  }

  void decrement() {
    // Prevent negative counts
    if (state > 0) {
      final newCount = state - 1;
      emit(newCount);
    }
  }

  void setCount(int count) {
    // Ensure count is never negative
    final newCount = count < 0 ? 0 : count;

    // Always emit, even if the count is the same, to ensure UI updates
    emit(newCount);
  }

  void reset() {
    emit(0);
  }
}
