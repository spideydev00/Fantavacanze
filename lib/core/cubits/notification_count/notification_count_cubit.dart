import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationCountCubit extends Cubit<int> {
  NotificationCountCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state > 0 ? state - 1 : 0);
  void setCount(int count) => emit(count);
  void reset() => emit(0);
}
