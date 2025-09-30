import 'package:fantavacanze_official/core/cubits/app_fs_league/app_fs_league_cubit.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/buttons/gradient_option_button.dart';
import 'package:fantavacanze_official/features/fantaserata/data/utils/winner_photo_util.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/manage_fs_league/existing_winner_photo_card.dart';

class WinnerPhotoSection extends StatefulWidget {
  final String? leagueId;
  final bool isLoading;

  const WinnerPhotoSection({
    super.key,
    required this.leagueId,
    required this.isLoading,
  });

  @override
  State<WinnerPhotoSection> createState() => _WinnerPhotoSectionState();
}

class _WinnerPhotoSectionState extends State<WinnerPhotoSection> {
  bool _isOpeningCamera = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppFsLeagueCubit, AppFsLeagueState>(
      listener: (context, state) {
        if (state is AppFsLeagueNotExists) {
          showSnackBar('Lega Non Trovata', color: ColorPalette.error);
        }
      },
      builder: (context, state) {
        if (state is AppFsLeagueExists &&
            (state.league.winnerPhotoUrl != null)) {
          return ExistingWinnerPhotoCard(
            photoUrl: state.league.winnerPhotoUrl!,
            leagueId: widget.leagueId,
            isLoading: widget.isLoading,
          );
        }

        // 3) Altrimenti mostra il bottone per scattare/caricare
        final bool busy = _isOpeningCamera || widget.isLoading;

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GradientOptionButton(
                isSelected: true,
                label:
                    busy ? "Caricamento in corso..." : "Condividi la vittoria.",
                labelFontSize: ThemeSizes.lg,
                fontFamily: "Falcon Sport One",
                description: busy
                    ? "Preparazione in corso..."
                    : "Clicca per scattare e condividere la foto del vincitore della Fantaserata!",
                icon: busy ? Icons.hourglass_empty : Icons.camera_enhance,
                onTap: busy
                    ? () {}
                    : () => _captureWinnerPhoto(context, CameraDevice.front),
                primaryColor: ColorPalette.infoDarker,
                secondaryColor: context.primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _captureWinnerPhoto(
      BuildContext context, CameraDevice cameraDevice) async {
    final leagueId = widget.leagueId;
    if (leagueId == null || leagueId.isEmpty) return;

    setState(() => _isOpeningCamera = true);

    try {
      // 1) Scatta, brandizza, uploada e condividi
      await WinnerPhotoUtil.captureBrandUploadAndShareWinner(
        context: context,
        leagueId: leagueId,
        preferredCameraDevice: cameraDevice,
      );
    } catch (e) {
      showSnackBar('Impossibile completare l\'operazione',
          color: ColorPalette.error);
    } finally {
      if (mounted) setState(() => _isOpeningCamera = false);
    }
  }
}
