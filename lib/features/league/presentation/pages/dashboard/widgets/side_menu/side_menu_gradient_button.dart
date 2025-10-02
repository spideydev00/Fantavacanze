import 'package:fantavacanze_official/core/entities/fs_league/fs_night_type.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SideMenuGradientButton extends StatefulWidget {
  final String title;
  final String? svgIcon;
  final bool isActive;
  final String? emojiPath;
  final VoidCallback? onTap;
  final FsNightType? nightType;

  const SideMenuGradientButton({
    super.key,
    required this.title,
    this.svgIcon,
    required this.isActive,
    this.emojiPath,
    this.onTap,
    this.nightType,
  });

  /// Seasonal gradient button factory
  const SideMenuGradientButton.seasonal({
    super.key,
    required this.title,
    this.svgIcon,
    required this.isActive,
    this.emojiPath,
    this.onTap,
    required this.nightType,
  });

  @override
  State<SideMenuGradientButton> createState() => _SideMenuGradientButtonState();
}

class _SideMenuGradientButtonState extends State<SideMenuGradientButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start infinite pulsing animation only if active
    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SideMenuGradientButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle pulse animation based on active state
    if (widget.isActive && !oldWidget.isActive) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Get gradient colors based on night type
    final effectiveNightType =
        widget.nightType ?? _getCurrentNightType(context);

    final gradientColors = effectiveNightType != FsNightType.apresSki
        ? ColorPalette.getSeasonalGradient(effectiveNightType)
        : ColorPalette.fsGradients;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeSizes.lg,
        vertical: ThemeSizes.xs,
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
        builder: (context, child) {
          final scale = widget.isActive
              ? _scaleAnimation.value * _pulseAnimation.value
              : _scaleAnimation.value;

          return Transform.scale(
            scale: scale,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: widget.onTap,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusXlg),
                child: Stack(
                  children: [
                    // Main container with content
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeSizes.sm,
                        vertical: ThemeSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                            BorderRadius.circular(ThemeSizes.borderRadiusXlg),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Title centered
                          Text(
                            widget.title,
                            style: const TextStyle(
                                fontFamily: "Falcon Sport One",
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Color.fromARGB(132, 35, 35, 35),
                                    blurRadius: 8.0,
                                  ),
                                ]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Background emoji positioned on the right (solo se emojiPath è fornito)
                    if (widget.emojiPath != null)
                      Positioned(
                        right: -20,
                        top: 0,
                        bottom: 0,
                        child: Opacity(
                          opacity: 0.4,
                          child: SvgPicture.asset(
                            widget.emojiPath!,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Helper method to get current night type from seasonal cubit
  FsNightType _getCurrentNightType(BuildContext context) {
    try {
      return context.currentNightType;
    } catch (e) {
      // Fallback if seasonal cubit is not available
      return FsNightType.def;
    }
  }
}
