import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfileCard extends StatelessWidget {
  final String? name;
  final VoidCallback? onTap;

  const UserProfileCard({
    super.key,
    this.name,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppUserCubit, AppUserState>(
      builder: (context, state) {
        String displayName = name ?? 'Utente';
        String email = '';

        if (state is AppUserIsLoggedIn) {
          displayName = state.user.name;
          email = state.user.email;
        }

        return Card(
          color: context.secondaryBgColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
            child: Padding(
              padding: const EdgeInsets.all(ThemeSizes.md),
              child: Row(
                children: [
                  // Avatar Circle with Icon
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        context.primaryColor.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: context.primaryColor,
                    ),
                  ),
                  const SizedBox(width: ThemeSizes.md),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayName,
                          style: context.textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            style: context.textTheme.bodyMedium!.copyWith(
                              color: context.textSecondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // Edit Icon
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: context.textPrimaryColor.withValues(alpha: 0.5),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
