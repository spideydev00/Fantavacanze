import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmbientGlow extends StatelessWidget {
  final Widget child;

  const AmbientGlow({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final partnerSlug = context.select<AppLeagueCubit, String?>((cubit) {
      final state = cubit.state;
      return state is AppLeagueExists ? state.selectedLeague.partner : null;
    });
    final glow = context.brandPrimaryColor(partnerSlug);

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.7, -0.6),
                  radius: 0.8,
                  colors: [
                    glow.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.8, 0.7),
                  radius: 0.7,
                  colors: [
                    glow.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
