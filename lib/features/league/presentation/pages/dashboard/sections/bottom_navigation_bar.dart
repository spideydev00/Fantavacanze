import 'package:fantavacanze_official/core/constants/navigation_items.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_navigation/app_navigation_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/entities/navigation/navigation_item.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/brand_assets.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/widgets/bottom_navbar/bottom_navigation_asset.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/partner/partner_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const int maxSlots = 4;

// >= altezza naturale di BottomNavigationAsset con margine per text scaling.
const double _barHeight = 64;
const double _notchRadius = 38;
const String _partnerSlug = 'invibe';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppThemeCubit, AppThemeState>(
      builder: (context, _) {
        return BlocBuilder<AppNavigationCubit, int>(
          builder: (context, selectedIndex) {
            return BlocBuilder<AppLeagueCubit, AppLeagueState>(
              builder: (context, leagueState) {
                final isDark =
                    context.read<AppThemeCubit>().isDarkMode(context);

                final List<NavigationItem> items;
                final List<int> originalIndices;

                if (leagueState is AppLeagueExists) {
                  final isAdmin = context.read<LeagueBloc>().isAdmin();
                  final hasPartnerRound =
                      leagueState.selectedLeague.partnerRoundId != null;

                  items = participantNavbarItems
                      .where(
                        (item) =>
                            (!item.isAdminOnly || isAdmin) &&
                            (!item.requiresPartnerRound || hasPartnerRound),
                      )
                      .take(maxSlots)
                      .toList();
                  originalIndices = items
                      .map((item) => participantNavbarItems.indexOf(item))
                      .toList();
                } else {
                  items = nonParticipantNavbarItems.take(2).toList();
                  originalIndices = List.generate(items.length, (i) => i);
                }

                // Distribuisco gli item ai due lati del notch centrale.
                final leftCount = (items.length / 2).ceil();
                final leftItems = items.sublist(0, leftCount);
                final rightItems = items.sublist(leftCount);
                final leftIdx = originalIndices.sublist(0, leftCount);
                final rightIdx = originalIndices.sublist(leftCount);

                Widget asset(NavigationItem item, int originalIndex) {
                  return BottomNavigationAsset(
                    svgIcon: isDark ? item.darkSvgIcon : item.lightSvgIcon,
                    title: item.title,
                    height: ThemeSizes.iconSm,
                    width: ThemeSizes.iconSm,
                    isActive: selectedIndex == originalIndex,
                    onTap: () => context
                        .read<AppNavigationCubit>()
                        .setIndex(originalIndex),
                  );
                }

                final size = MediaQuery.of(context).size;

                return BottomAppBar(
                  color: Colors.transparent,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      CustomPaint(
                        size: Size(size.width, _barHeight + 7),
                        painter: _BottomNavCurvePainter(
                          backgroundColor: context.secondaryBgColor,
                          insetRadius: _notchRadius,
                        ),
                      ),
                      // FAB InVibe nel notch centrale.
                      const Center(
                        heightFactor: 0.6,
                        child: _InvibeFab(),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ThemeSizes.xs,
                              vertical: ThemeSizes.xs,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ...List.generate(
                                  leftItems.length,
                                  (i) => Expanded(
                                    child: asset(leftItems[i], leftIdx[i]),
                                  ),
                                ),
                                const SizedBox(width: _notchRadius * 2),
                                ...List.generate(
                                  rightItems.length,
                                  (i) => Expanded(
                                    child: asset(rightItems[i], rightIdx[i]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

/// FAB centrale: mostra il logo InVibe su sfondo scuro e porta alla pagina di
/// creazione/unione lega InVibe.
class _InvibeFab extends StatelessWidget {
  const _InvibeFab();

  @override
  Widget build(BuildContext context) {
    final logo = BrandAssets.logoFor(
      _partnerSlug,
      isDark: context.read<AppThemeCubit>().isDarkMode(context),
    );

    return FloatingActionButton(
      heroTag: 'invibe-fab',
      shape: const CircleBorder(),
      backgroundColor: ColorPalette.black,
      elevation: 2,
      onPressed: () =>
          Navigator.push(context, PartnerDashboardPage.route(_partnerSlug)),
      child: logo == null
          ? const Icon(Icons.travel_explore_rounded, color: Colors.white)
          : Padding(
              padding: const EdgeInsets.all(ThemeSizes.sm),
              child: Image.asset(
                logo,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.travel_explore_rounded,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }
}

/// Disegna la barra con il notch centrale che ospita il FAB.
class _BottomNavCurvePainter extends CustomPainter {
  final Color backgroundColor;
  final double insetRadius;

  _BottomNavCurvePainter({
    required this.backgroundColor,
    this.insetRadius = 38,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    final path = Path()..moveTo(0, 12);

    final insetCurveBeginningX = size.width / 2 - insetRadius;
    final insetCurveEndX = size.width / 2 + insetRadius;
    final transitionToInsetCurveWidth = size.width * .05;

    path.quadraticBezierTo(size.width * 0.20, 0,
        insetCurveBeginningX - transitionToInsetCurveWidth, 0);
    path.quadraticBezierTo(
        insetCurveBeginningX, 0, insetCurveBeginningX, insetRadius / 2);
    path.arcToPoint(
      Offset(insetCurveEndX, insetRadius / 2),
      radius: const Radius.circular(10.0),
      clockwise: false,
    );
    path.quadraticBezierTo(
        insetCurveEndX, 0, insetCurveEndX + transitionToInsetCurveWidth, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 12);
    path.lineTo(size.width, size.height + 56);
    path.lineTo(0, size.height + 56);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BottomNavCurvePainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.insetRadius != insetRadius;
  }
}
