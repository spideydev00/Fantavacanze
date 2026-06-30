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
        String? profileImageUrl;

        if (state is AppUserIsLoggedIn) {
          displayName = state.user.name;
          email = state.user.email;
          profileImageUrl = state.user.profileImageUrl;
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
                  _buildAvatar(context, displayName, profileImageUrl),
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
                        Text(
                          "Cambia immagine profilo da qui!",
                          style: context.textTheme.labelSmall!.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
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

  Widget _buildAvatar(
    BuildContext context,
    String displayName,
    String? profileImageUrl,
  ) {
    final hasImage = profileImageUrl != null && profileImageUrl.isNotEmpty;

    return CircleAvatar(
      radius: 28,
      backgroundColor: context.primaryColor.withValues(alpha: 0.2),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                profileImageUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _buildInitial(context, displayName),
              )
            : _buildInitial(context, displayName),
      ),
    );
  }

  Widget _buildInitial(BuildContext context, String displayName) {
    final initial = displayName.trim().isNotEmpty
        ? displayName.trim()[0].toUpperCase()
        : 'U';

    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Text(
          initial,
          style: context.textTheme.titleLarge?.copyWith(
            color: context.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
