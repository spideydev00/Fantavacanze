part of 'floating_button_animation_cubit.dart';

class FloatingButtonAnimationState {
  final bool hasAnimationPlayed;
  final bool isHidden;

  const FloatingButtonAnimationState({
    required this.hasAnimationPlayed,
    required this.isHidden,
  });

  FloatingButtonAnimationState copyWith({
    bool? hasAnimationPlayed,
    bool? isHidden,
  }) {
    return FloatingButtonAnimationState(
      hasAnimationPlayed: hasAnimationPlayed ?? this.hasAnimationPlayed,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}
