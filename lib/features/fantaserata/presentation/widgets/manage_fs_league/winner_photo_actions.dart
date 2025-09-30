import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/buttons/danger_action_button.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/bloc/fs_league_bloc/fs_bloc.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/manage_fs_league/share_photo_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WinnerPhotoActions extends StatelessWidget {
  final String photoUrl;
  final String? leagueId;
  final bool isLoading;

  const WinnerPhotoActions({
    super.key,
    required this.photoUrl,
    required this.leagueId,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DangerActionButton(
            title: "Elimina",
            description: "Rimuovi la foto!",
            icon: Icons.delete,
            onTap: isLoading ? () {} : () => _showDeleteConfirmation(context),
          ),
        ),
        const SizedBox(width: ThemeSizes.md),
        Expanded(
          child: SharePhotoButton(
            photoUrl: photoUrl,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => ConfirmationDialog.delete(
        itemType: "foto del vincitore",
        customMessage:
            "Sei sicuro di voler eliminare la foto del vincitore? Questa azione non può essere annullata.",
        onDelete: () => _deleteWinnerPhoto(context),
      ),
    );
  }

  void _deleteWinnerPhoto(BuildContext context) {
    if (leagueId == null) {
      showSnackBar(
        'Errore: ID lega non disponibile',
        color: Colors.red,
      );
      return;
    }

    context.read<FsBloc>().add(DeleteWinnerPhotoEvent(
          leagueId: leagueId!,
        ));
  }
}
