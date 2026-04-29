import 'package:flutter_bloc/flutter_bloc.dart';

class AppNavigationCubit extends Cubit<int> {
  AppNavigationCubit() : super(0);

  void setIndex(int index) {
    emit(index);
  }
}
