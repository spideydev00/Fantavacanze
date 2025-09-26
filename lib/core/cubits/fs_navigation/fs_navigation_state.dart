part of 'fs_navigation_cubit.dart';

class FsNavigationState {
  final int selectedIndex;

  const FsNavigationState({
    required this.selectedIndex,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FsNavigationState && other.selectedIndex == selectedIndex;
  }

  @override
  int get hashCode => selectedIndex.hashCode;
}
