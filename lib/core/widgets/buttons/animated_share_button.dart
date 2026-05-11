import 'dart:async';

import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/cubits/share_button_animation/share_button_animation_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:flutter/material.dart';

class AnimatedShareButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;
  final IconData icon;

  /// If set, the collapse animation only schedules once the
  /// [AppNavigationCubit] reports this index. Needed when the button lives in
  /// a screen mounted via IndexedStack: without it the timer would fire while
  /// the page is still off-screen.
  final int? triggerOnNavIndex;

  const AnimatedShareButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.label = 'Condividi sui social',
    this.icon = Icons.ios_share_outlined,
    this.triggerOnNavIndex,
  });

  @override
  State<AnimatedShareButton> createState() => _AnimatedShareButtonState();
}

class _AnimatedShareButtonState extends State<AnimatedShareButton>
    with SingleTickerProviderStateMixin {
  static const double _expandedWidth = 210.0;
  static const double _collapsedWidth = 60.0;
  static const double _height = 60.0;

  static const Duration _collapseDelay = Duration(seconds: 4);
  static const Duration _animationDuration = Duration(milliseconds: 600);

  late final AnimationController _controller;
  late final Animation<double> _widthAnimation;
  late final Animation<double> _textOpacityAnimation;

  late final ShareButtonAnimationCubit _animationCubit;
  StreamSubscription<int>? _navSubscription;
  bool _animationScheduled = false;

  @override
  void initState() {
    super.initState();

    _animationCubit = serviceLocator<ShareButtonAnimationCubit>();

    _controller = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _widthAnimation = Tween<double>(
      begin: _expandedWidth,
      end: _collapsedWidth,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    _textOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    if (_animationCubit.hasAnimationPlayed) {
      _controller.value = 1.0;
      _animationScheduled = true;
      return;
    }

    final navIndex = widget.triggerOnNavIndex;
    if (navIndex == null) {
      _scheduleCollapse();
      return;
    }

    final navCubit = serviceLocator<AppNavigationCubit>();
    if (navCubit.state == navIndex) {
      _scheduleCollapse();
    } else {
      _navSubscription = navCubit.stream.listen((index) {
        if (index == navIndex) {
          _scheduleCollapse();
          _navSubscription?.cancel();
          _navSubscription = null;
        }
      });
    }
  }

  void _scheduleCollapse() {
    if (_animationScheduled) return;
    _animationScheduled = true;
    Future.delayed(_collapseDelay, () {
      if (!mounted) return;
      if (_animationCubit.hasAnimationPlayed) return;
      _controller.forward();
      _animationCubit.markAnimationAsPlayed();
    });
  }

  @override
  void dispose() {
    _navSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.primaryColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: _widthAnimation.value,
          height: _height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withValues(alpha: 0.6),
                primaryColor,
                primaryColor,
                primaryColor.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(_height / 2),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: StadiumBorder(),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: widget.isLoading ? null : widget.onPressed,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: widget.isLoading
                          ? const Loader(color: Colors.white)
                          : Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 22,
                            ),
                    ),
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: _textOpacityAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Opacity(
                            opacity: _textOpacityAnimation.value,
                            child: Text(
                              widget.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
