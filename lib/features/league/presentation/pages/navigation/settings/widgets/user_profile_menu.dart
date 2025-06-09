import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/buttons/danger_action_button.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/settings/widgets/consent_settings_dialog.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/gdpr_consent_dialog.dart'; // Import the new dialog
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/settings/widgets/delete_account_dialog.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/settings/widgets/edit_profile_dialog.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/settings/widgets/password_change_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfileMenu extends StatelessWidget {
  static const String routeName = '/user_profile_menu';

  static get route => MaterialPageRoute(
        builder: (context) => const UserProfileMenu(),
        settings: const RouteSettings(name: routeName),
      );

  const UserProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Impostazioni Profilo',
          style: context.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: BlocConsumer<AppUserCubit, AppUserState>(
        listener: (context, state) {
          // Show error message in snackbar if available
          if (state is AppUserIsLoggedIn && state.errorMessage != null) {
            showSnackBar(
              state.errorMessage!,
              color: ColorPalette.error,
            );

            // Clear the error message after showing it
            context.read<AppUserCubit>().clearErrorMessage();
          }
        },
        builder: (context, state) {
          // Check if user is logged in and using email provider
          bool isEmailUser = false;
          if (state is AppUserIsLoggedIn) {
            isEmailUser = state.user.authProvider == 'email';
          }

          return ListView(
            padding: const EdgeInsets.all(ThemeSizes.md),
            children: [
              // Profile Section
              _buildSectionHeader(context, 'Profilo'),
              _buildMenuItem(
                context,
                icon: Icons.person,
                title: 'Modifica Profilo',
                onTap: () => EditProfileDialog.show(context),
              ),
              // Only show password change option for email users
              if (isEmailUser)
                _buildMenuItem(
                  context,
                  icon: Icons.password,
                  title: 'Cambia Password',
                  onTap: () => PasswordChangeDialog.show(context),
                ),
              const SizedBox(height: ThemeSizes.lg),

              // Privacy Section
              _buildSectionHeader(context, 'Privacy e Consensi'),
              _buildMenuItem(
                context,
                icon: Icons.fact_check_rounded,
                title: 'Consensi App',
                subtitle: 'Modifica consensi età e termini di servizio',
                onTap: () => ConsentSettingsDialog.show(context),
              ),
              _buildMenuItem(
                // New menu item for GDPR
                context,
                icon: Icons.ads_click_rounded,
                title: 'Consenso Annunci (GDPR)',
                subtitle: 'Gestisci preferenze per annunci personalizzati',
                onTap: () => GdprConsentDialog.show(context),
              ),
              const SizedBox(height: ThemeSizes.lg),

              // Account Section
              _buildSectionHeader(context, 'Account', isWarning: true),
              DangerActionButton(
                title: 'Elimina Account',
                description: 'Questa azione è irreversibile',
                icon: Icons.delete_forever,
                onTap: () => DeleteAccountDialog.show(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title,
      {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(
        left: ThemeSizes.sm,
        bottom: ThemeSizes.sm,
        top: ThemeSizes.sm,
      ),
      child: Text(
        title,
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: isWarning ? Colors.red : context.primaryColor,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      color: context.secondaryBgColor,
      margin: const EdgeInsets.only(bottom: ThemeSizes.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : context.primaryColor,
        ),
        title: Text(
          title,
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : null,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: context.textPrimaryColor.withValues(alpha: 0.5),
        ),
        onTap: onTap,
      ),
    );
  }
}
