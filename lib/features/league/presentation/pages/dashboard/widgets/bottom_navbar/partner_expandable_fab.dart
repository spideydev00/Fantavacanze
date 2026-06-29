import 'dart:math' as math;

import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

/// Una singola azione del [PartnerExpandableFab].
class PartnerFabAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const PartnerFabAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

/// FAB partner espandibile: chiuso mostra il logo brand; al tap apre, con
/// animazione, le [actions] disposte a ventaglio verso l'alto sopra il
/// contenuto via Overlay, cosi esce dai limiti della BottomAppBar.
class PartnerExpandableFab extends StatefulWidget {
  final Color brandColor;
  final Color backgroundColor;
  final String? logo;
  final List<PartnerFabAction> actions;
  final double distance;

  const PartnerExpandableFab({
    super.key,
    required this.brandColor,
    required this.backgroundColor,
    required this.logo,
    required this.actions,
    this.distance = 96,
  });

  @override
  State<PartnerExpandableFab> createState() => _PartnerExpandableFabState();
}

class _PartnerExpandableFabState extends State<PartnerExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expand;
  OverlayEntry? _entry;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expand = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeOutQuad,
    );
  }

  @override
  void dispose() {
    _removeEntry();
    _controller.dispose();
    super.dispose();
  }

  void _removeEntry() {
    _entry?.remove();
    _entry = null;
  }

  void _toggle() => _open ? _close() : _openMenu();

  void _openMenu() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final overlay = Overlay.of(context);
    final center = box.localToGlobal(box.size.center(Offset.zero));

    _entry = OverlayEntry(
      builder: (_) => _PartnerFabOverlay(
        center: center,
        progress: _expand,
        distance: widget.distance,
        actions: widget.actions,
        onDismiss: _close,
        onActionTap: (action) {
          _close();
          action.onTap();
        },
      ),
    );
    overlay.insert(_entry!);
    setState(() => _open = true);
    _controller.forward();
  }

  void _close() {
    if (!_open) return;
    _controller.reverse().whenComplete(() {
      _removeEntry();
      if (mounted) setState(() => _open = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.brandColor.withValues(alpha: 0.4),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: 'partner-fab',
        shape: const CircleBorder(),
        backgroundColor: widget.backgroundColor,
        elevation: 2,
        onPressed: _toggle,
        child: AnimatedRotation(
          turns: _open ? 0.125 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: widget.logo == null
              ? Icon(Icons.travel_explore_rounded, color: widget.brandColor)
              : Padding(
                  padding: const EdgeInsets.all(ThemeSizes.xs),
                  child: Image.asset(
                    widget.logo!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.travel_explore_rounded,
                      color: widget.brandColor,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _PartnerFabOverlay extends StatelessWidget {
  final Offset center;
  final Animation<double> progress;
  final double distance;
  final List<PartnerFabAction> actions;
  final VoidCallback onDismiss;
  final void Function(PartnerFabAction) onActionTap;

  const _PartnerFabOverlay({
    required this.center,
    required this.progress,
    required this.distance,
    required this.actions,
    required this.onDismiss,
    required this.onActionTap,
  });

  static const double _radius = 26;

  @override
  Widget build(BuildContext context) {
    final count = actions.length;
    const totalSpreadDeg = 120.0;
    const startDeg = -90.0 - totalSpreadDeg / 2;
    final stepDeg = count > 1 ? totalSpreadDeg / (count - 1) : 0.0;

    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        final t = progress.value.clamp(0.0, 1.0).toDouble();
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDismiss,
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.45 * t),
                ),
              ),
            ),
            for (var i = 0; i < count; i++)
              _buildAction(i, startDeg + stepDeg * i, t),
          ],
        );
      },
    );
  }

  Widget _buildAction(int i, double deg, double t) {
    final offset = Offset.fromDirection(deg * math.pi / 180.0, distance * t);
    final action = actions[i];

    return Positioned(
      left: center.dx + offset.dx - _radius,
      top: center.dy + offset.dy - _radius,
      child: Transform.scale(
        scale: t,
        child: Opacity(
          opacity: t,
          child: Tooltip(
            message: action.label,
            child: Material(
              color: action.color,
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => onActionTap(action),
                child: SizedBox(
                  width: _radius * 2,
                  height: _radius * 2,
                  child: Icon(action.icon, color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
