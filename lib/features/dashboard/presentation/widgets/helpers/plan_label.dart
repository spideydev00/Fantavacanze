import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlanLabel extends StatelessWidget {
  const PlanLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppUserCubit, AppUserState>(
      builder: (context, state) {
        final isPremium = state is AppUserIsLoggedIn && state.user.isPremium;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: context.primaryColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPremium ? Icons.star : Icons.lock_outline,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                isPremium ? 'Premium' : 'Gratis',
                style: context.textTheme.labelMedium!.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
