import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationCountCubit extends Cubit<int> {
  NotificationCountCubit() : super(0);

  void increment() => emit(state + 1);

  void decrement() {
    // Prevent negative counts
    if (state > 0) {
      emit(state - 1);
    }
  }

  void setCount(int count) {
    // Ensure count is never negative
    emit(count < 0 ? 0 : count);
  }

  void reset() => emit(0);
}
