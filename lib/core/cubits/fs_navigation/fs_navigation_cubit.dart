import 'package:flutter_bloc/flutter_bloc.dart';

part 'fs_navigation_state.dart';

class FsNavigationCubit extends Cubit<FsNavigationState> {
  FsNavigationCubit() : super(FsNavigationState(selectedIndex: 0));

  /// Set the selected navigation index
  void setIndex(int index) {
    emit(FsNavigationState(selectedIndex: index));
  }

  /// Get current selected index
  int get selectedIndex => state.selectedIndex;
}
