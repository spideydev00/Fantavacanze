import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/manage_fs_league/winner_photo_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExistingWinnerPhotoCard extends StatelessWidget {
  final String photoUrl;
  final String? leagueId;
  final bool isLoading;

  const ExistingWinnerPhotoCard({
    super.key,
    required this.photoUrl,
    required this.leagueId,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<AppUserCubit, AppUserState>(
          builder: (context, state) {
            if (state is AppUserIsLoggedIn && state.user.gender == "female") {
              return Text(
                "La più baddie.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Falcon Sport One",
                  fontSize: ThemeSizes.lg,
                ),
              );
            }
            return Text(
              "L'eroe della serata.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Falcon Sport One",
                fontSize: ThemeSizes.lg,
              ),
            );
          },
        ),
        SizedBox(height: ThemeSizes.md),
        SizedBox(
          height: Constants.getHeight(context) * 0.28,
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Image.network(
              photoUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: context.secondaryBgColor,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: context.secondaryBgColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: context.textSecondaryColor,
                      ),
                      const SizedBox(height: ThemeSizes.sm),
                      Text(
                        'Errore nel caricamento',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // Action buttons row
        WinnerPhotoActions(
          photoUrl: photoUrl,
          leagueId: leagueId,
          isLoading: isLoading,
        ),
      ],
    );
  }
}
