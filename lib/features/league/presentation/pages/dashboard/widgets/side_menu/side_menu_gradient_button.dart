import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SideMenuGradientButton extends StatefulWidget {
  final String title;
  final String svgIcon;
  final VoidCallback onTap;
  final bool isActive;
  final String? emojiPath;

  const SideMenuGradientButton({
    super.key,
    required this.title,
    required this.svgIcon,
    required this.onTap,
    this.isActive = false,
    this.emojiPath,
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

    // Start infinite pulsing animation
    _pulseController.repeat(reverse: true);
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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeSizes.lg,
        vertical: ThemeSizes.xs,
      ),
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value * _pulseAnimation.value,
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
                          colors: ColorPalette.fsGradients,
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(width: ThemeSizes.sm),

                          // Arrow icon
                          const Icon(
                            Icons.double_arrow_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),

                    // Background emoji positioned on the right (solo se emojiPath è fornito)
                    if (widget.emojiPath != null)
                      Positioned(
                        right: -65,
                        top: 0,
                        bottom: 0,
                        child: Opacity(
                          opacity: 0.3,
                          child: SvgPicture.asset(
                            widget.emojiPath!,
                            height: 160,
                            width: 160,
                            fit: BoxFit.contain,
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
}
