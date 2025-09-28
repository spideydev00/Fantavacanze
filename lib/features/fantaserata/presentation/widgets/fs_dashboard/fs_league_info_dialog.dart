import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_page_specific_snackbar.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fantavacanze_official/core/widgets/buttons/danger_action_button.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/bloc/fs_league_bloc/fs_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/sections/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FsLeagueInfoDialog extends StatelessWidget {
  final FsLeague league;

  const FsLeagueInfoDialog({
    super.key,
    required this.league,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<FsBloc, FsState>(
      listener: (context, state) {
        if (state is FsLeagueDeleted) {
          // Close dialog and navigate to main page
          Navigator.of(context).pop(); // Close dialog

          Navigator.of(context).pushAndRemoveUntil(
            DashboardScreen.route,
            (route) => route.isFirst,
          );

          showSpecificSnackBar(
            context,
            'Lega eliminata con successo',
            color: ColorPalette.success,
          );
        } else if (state is FantaserataFailure) {
          showSpecificSnackBar(
            context,
            state.message,
            color: ColorPalette.error,
          );
        }
      },
      child: Dialog(
        backgroundColor: context.bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(ThemeSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(ThemeSizes.sm),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: ColorPalette.fsGradients,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: ThemeSizes.md),
                    Expanded(
                      child: Text(
                        'Info Lega',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: ThemeSizes.lg),

                // Info rows
                _InfoRow(
                  icon: Icons.drive_file_rename_outline_rounded,
                  label: 'Nome',
                  value: league.name,
                ),

                const SizedBox(height: ThemeSizes.md),

                if (league.description != null &&
                    league.description!.isNotEmpty) ...[
                  _InfoRow(
                    icon: Icons.format_quote_rounded,
                    label: 'Motto',
                    value: league.description!,
                  ),
                  const SizedBox(height: ThemeSizes.md),
                ],

                _InfoRow(
                  icon: Icons.vpn_key_rounded,
                  label: 'Codice',
                  value: league.inviteCode,
                  copyable: true,
                  onCopy: () {
                    Clipboard.setData(ClipboardData(text: league.inviteCode));
                    Navigator.of(context).pop();
                    showSpecificSnackBar(
                      context,
                      'Codice invito copiato!',
                      color: ColorPalette.success,
                    );
                  },
                ),

                const SizedBox(height: ThemeSizes.md),

                _InfoRow(
                  icon: Icons.people_rounded,
                  label: 'Partecipanti',
                  value: '${league.participants.length}',
                ),

                const SizedBox(height: ThemeSizes.xl),

                // Danger Zone
                DangerActionButton(
                  title: 'Elimina Lega',
                  description:
                      'Questa azione eliminerà definitivamente la lega',
                  icon: Icons.delete_forever_rounded,
                  onTap: () {
                    _showDeleteConfirmation(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmationDialog.delete(
        itemType: 'lega "${league.name}"',
        customMessage:
            'Sei sicuro di voler eliminare definitivamente questa lega? '
            'Tutti i dati, partecipanti e memories verranno persi per sempre.',
        onDelete: () {
          // Trigger delete event
          context.read<FsBloc>().add(
                DeleteFsLeagueEvent(leagueId: league.id),
              );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool copyable;
  final VoidCallback? onCopy;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.copyable = false,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeSizes.md),
      decoration: BoxDecoration(
        color: context.secondaryBgColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: context.primaryColor,
            size: 20,
          ),
          const SizedBox(width: ThemeSizes.md),
          Text(
            '$label:',
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: ThemeSizes.sm),
          Expanded(
            child: Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textSecondaryColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
          if (copyable) ...[
            const SizedBox(width: ThemeSizes.sm),
            GestureDetector(
              onTap: onCopy,
              child: Icon(
                Icons.copy_rounded,
                size: 18,
                color: context.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
