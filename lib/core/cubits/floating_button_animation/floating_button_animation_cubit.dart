import 'package:flutter_bloc/flutter_bloc.dart';

part 'floating_button_animation_state.dart';

class FloatingButtonAnimationCubit extends Cubit<FloatingButtonAnimationState> {
  FloatingButtonAnimationCubit()
      : super(const FloatingButtonAnimationState(
          hasAnimationPlayed: false,
          isHidden: false,
        ));

  void markAnimationAsPlayed() {
    emit(state.copyWith(hasAnimationPlayed: true));
  }

  void resetAnimation() {
    emit(state.copyWith(hasAnimationPlayed: false));
  }

  void setHidden(bool isHidden) {
    emit(state.copyWith(isHidden: isHidden));
  }

  void hideButton() {
    emit(state.copyWith(isHidden: true));
  }

  void showButton() {
    emit(state.copyWith(isHidden: false));
  }

  bool get hasAnimationPlayed => state.hasAnimationPlayed;
  bool get isHidden => state.isHidden;
}
