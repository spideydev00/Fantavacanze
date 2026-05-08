import 'package:flutter_bloc/flutter_bloc.dart';

part 'share_button_animation_state.dart';

class ShareButtonAnimationCubit extends Cubit<ShareButtonAnimationState> {
  ShareButtonAnimationCubit()
      : super(const ShareButtonAnimationState(hasAnimationPlayed: false));

  void markAnimationAsPlayed() {
    emit(state.copyWith(hasAnimationPlayed: true));
  }

  void resetAnimation() {
    emit(state.copyWith(hasAnimationPlayed: false));
  }

  bool get hasAnimationPlayed => state.hasAnimationPlayed;
}
