part of 'share_button_animation_cubit.dart';

class ShareButtonAnimationState {
  final bool hasAnimationPlayed;

  const ShareButtonAnimationState({required this.hasAnimationPlayed});

  ShareButtonAnimationState copyWith({bool? hasAnimationPlayed}) {
    return ShareButtonAnimationState(
      hasAnimationPlayed: hasAnimationPlayed ?? this.hasAnimationPlayed,
    );
  }
}
