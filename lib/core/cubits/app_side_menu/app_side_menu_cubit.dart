import 'package:flutter_bloc/flutter_bloc.dart';

class AppSideMenuCubit extends Cubit<bool> {
  AppSideMenuCubit() : super(false);

  void openSideMenu() {
    emit(true);
  }

  void closeSideMenu() {
    emit(false);
  }
}
