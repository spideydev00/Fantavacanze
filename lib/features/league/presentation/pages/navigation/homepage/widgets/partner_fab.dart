import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/create_league/create_league_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/join_league/search_league_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/partner_dashboard_page.dart';
import 'package:flutter/material.dart';

class PartnerFab extends StatefulWidget {
  const PartnerFab({super.key});

  @override
  State<PartnerFab> createState() => _PartnerFabState();
}

class _PartnerFabState extends State<PartnerFab> {
  static const String _partnerSlug = 'invibe';

  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final brandColor = context.brandPrimaryColor(_partnerSlug);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _isOpen
              ? Column(
                  key: const ValueKey('partner-actions'),
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _FabAction(
                      label: 'Leghe',
                      icon: Icons.groups_2_outlined,
                      color: context.primaryColor,
                      onPressed: _openLeagueActions,
                    ),
                    const SizedBox(height: ThemeSizes.sm),
                    _FabAction(
                      label: 'InVibe',
                      icon: Icons.travel_explore_rounded,
                      color: brandColor,
                      onPressed: _openPartner,
                    ),
                    const SizedBox(height: ThemeSizes.sm),
                  ],
                )
              : const SizedBox.shrink(key: ValueKey('partner-actions-empty')),
        ),
        FloatingActionButton.extended(
          heroTag: 'partner-fab',
          onPressed: _toggle,
          backgroundColor: brandColor,
          foregroundColor: Colors.white,
          icon: Icon(_isOpen ? Icons.close_rounded : Icons.handshake_rounded),
          label: const Text('Partner'),
        ),
      ],
    );
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _close() {
    if (!_isOpen) return;
    setState(() {
      _isOpen = false;
    });
  }

  void _openPartner() {
    _close();
    Navigator.push(context, PartnerDashboardPage.route(_partnerSlug));
  }

  void _openLeagueActions() {
    _close();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.secondaryBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ThemeSizes.borderRadiusXlg),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: ThemeSizes.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Crea Lega'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(context, CreateLeaguePage.route);
                },
              ),
              ListTile(
                leading: const Icon(Icons.search_rounded),
                title: const Text('Cerca Lega'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(context, SearchLeaguePage.route);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FabAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _FabAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      elevation: 3,
      borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusXlg),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusXlg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeSizes.md,
            vertical: ThemeSizes.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: ThemeSizes.iconSm),
              const SizedBox(width: ThemeSizes.sm),
              Text(
                label,
                style: context.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
