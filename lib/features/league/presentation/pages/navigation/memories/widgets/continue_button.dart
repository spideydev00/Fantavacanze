import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class ContinueButton extends StatefulWidget {
  final VoidCallback onTap;
  final int remainingCount;
  final String? customText;
  final IconData? customIcon;
  final bool isLoading;

  const ContinueButton({
    super.key,
    required this.onTap,
    required this.remainingCount,
    this.customText,
    this.customIcon,
    this.isLoading = false,
  });

  @override
  State<ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<ContinueButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
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
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
            child: GestureDetector(
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: widget.isLoading ? null : widget.onTap,
              child: Container(
                padding: const EdgeInsets.all(ThemeSizes.lg),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusLg),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ColorPalette.info.withValues(alpha: 0.1),
                      ColorPalette.infoDarker.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(
                    color: ColorPalette.infoDarker.withValues(alpha: 0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ColorPalette.infoDarker.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: widget.isLoading
                    ? _buildLoadingState(context)
                    : _buildNormalState(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: ColorPalette.info,
          ),
        ),
        const SizedBox(width: ThemeSizes.sm),
        Text(
          'Caricamento...',
          style: TextStyle(
            color: context.textSecondaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNormalState(BuildContext context) {
    return Column(
      children: [
        // Icon section with subtle animation
        Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorPalette.info.withValues(alpha: 0.2),
                  ColorPalette.infoDarker.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Icon(
              widget.customIcon ?? Icons.keyboard_arrow_down_rounded,
              color: context.textSecondaryColor,
              size: 24,
            ),
          ),
        ),

        const SizedBox(height: ThemeSizes.sm),

        // Main text
        // Text(
        //   widget.customText ?? 'Continua',
        //   style: TextStyle(
        //     color: context.primaryColor,
        //     fontWeight: FontWeight.w700,
        //     fontSize: 18,
        //     letterSpacing: 0.5,
        //   ),
        // ),

        const SizedBox(height: ThemeSizes.xs),

        // Subtitle with count
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeSizes.sm,
            vertical: ThemeSizes.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusSm),
            color: ColorPalette.info.withValues(alpha: 0.1),
          ),
          child: Text(
            widget.remainingCount == 1
                ? 'Carica ancora 1 ricordo...'
                : 'Carica altri ${widget.remainingCount} ricordi...',
            style: TextStyle(
              color: context.textSecondaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: ThemeSizes.xs),

        // Subtle hint
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swipe_up_outlined,
              size: 14,
              color: context.textSecondaryColor.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              'Tocca per vedere di più',
              style: TextStyle(
                color: context.textSecondaryColor.withValues(alpha: 0.6),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Versione alternativa più compatta se preferisci
class CompactContinueButton extends StatefulWidget {
  final VoidCallback onTap;
  final int remainingCount;
  final bool isLoading;

  const CompactContinueButton({
    super.key,
    required this.onTap,
    required this.remainingCount,
    this.isLoading = false,
  });

  @override
  State<CompactContinueButton> createState() => _CompactContinueButtonState();
}

class _CompactContinueButtonState extends State<CompactContinueButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
            child: Material(
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
              color: Colors.transparent,
              child: InkWell(
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                onTap: widget.isLoading ? null : widget.onTap,
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeSizes.lg,
                    vertical: ThemeSizes.md,
                  ),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusLg),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        context.primaryColor.withValues(alpha: 0.08),
                        context.secondaryColor.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: context.primaryColor.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: widget.isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: context.primaryColor,
                              ),
                            ),
                            const SizedBox(width: ThemeSizes.sm),
                            Text(
                              'Caricamento...',
                              style: TextStyle(
                                color: context.textSecondaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.expand_more_rounded,
                              color: context.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: ThemeSizes.sm),
                            Text(
                              'Continua',
                              style: TextStyle(
                                color: context.primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: ThemeSizes.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: context.primaryColor
                                    .withValues(alpha: 0.15),
                              ),
                              child: Text(
                                '+${widget.remainingCount}',
                                style: TextStyle(
                                  color: context.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
