import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class CustomDivider extends StatefulWidget {
  final String text;
  final double thickness;
  final double lineHeight;
  final EdgeInsets padding;
  final int? sectionNumber;
  final Color? color;
  final bool hasDropdown;
  final String? dropdownText;

  const CustomDivider({
    super.key,
    required this.text,
    this.thickness = 0.25,
    this.lineHeight = 1,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.sectionNumber,
    this.color,
    this.hasDropdown = false,
    this.dropdownText,
  });

  @override
  State<CustomDivider> createState() => _CustomDividerState();
}

class _CustomDividerState extends State<CustomDivider>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.hasDropdown) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _expandAnimation = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    if (widget.hasDropdown) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _toggleExpanded() {
    if (!widget.hasDropdown) return;

    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor =
        widget.color ?? context.textSecondaryColor.withValues(alpha: 0.6);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: widget.lineHeight,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: dividerColor,
                        width: widget.thickness,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: widget.padding,
                child: Row(
                  children: [
                    if (widget.sectionNumber != null)
                      Container(
                        width: 26,
                        height: 26,
                        margin: const EdgeInsets.only(right: ThemeSizes.sm),
                        decoration: BoxDecoration(
                          color: context.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${widget.sectionNumber}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    Text(
                      widget.text,
                      style: context.textTheme.labelMedium!.copyWith(
                        color: dividerColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (widget.hasDropdown) ...[
                      const SizedBox(width: ThemeSizes.xs),
                      GestureDetector(
                        onTap: _toggleExpanded,
                        child: Icon(
                          _isExpanded
                              ? Icons.close
                              : Icons.info_outline_rounded,
                          size: 18,
                          color: context.colorScheme.onSurface
                              .withValues(alpha: .7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  height: widget.lineHeight,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: dividerColor,
                        width: widget.thickness,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.hasDropdown && widget.dropdownText != null)
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
              child: Text(
                widget.dropdownText!,
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: .7),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A text divider with gradient background for section headers
class GradientSectionDivider extends StatelessWidget {
  final String text;
  final int? sectionNumber;
  final Color color;

  const GradientSectionDivider({
    super.key,
    required this.text,
    this.sectionNumber,
    this.color = ColorPalette.info,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
      child: Row(
        children: [
          // Left line segment with gradient
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      color.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Center container with text
          Container(
            margin: const EdgeInsets.symmetric(horizontal: ThemeSizes.sm),
            padding: const EdgeInsets.symmetric(
                horizontal: ThemeSizes.md, vertical: ThemeSizes.xs),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.8),
                  color,
                ],
              ),
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (sectionNumber != null) ...[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$sectionNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: ThemeSizes.xs),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Right line segment with gradient
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
