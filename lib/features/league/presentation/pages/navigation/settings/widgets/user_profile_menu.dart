import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/media/image_picker_util.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/buttons/danger_action_button.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/gdpr_consent_dialog.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/settings/widgets/consent_settings_dialog.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/settings/widgets/delete_account_dialog.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/settings/widgets/edit_profile_dialog.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/settings/widgets/password_change_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart' as image_picker;

class UserProfileMenu extends StatelessWidget {
  static const String routeName = '/user_profile_menu';

  static MaterialPageRoute<dynamic> get route => MaterialPageRoute(
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
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) {
          return previous is AuthProfileImageLoading &&
              (current is AuthSuccess ||
                  current is AuthFailure &&
                      current.operation == 'update_profile_image');
        },
        listener: (context, authState) {
          if (authState is AuthSuccess) {
            showSnackBar(
              'Immagine profilo aggiornata',
              color: ColorPalette.success,
            );
          } else if (authState is AuthFailure) {
            showSnackBar(
              authState.message,
              color: ColorPalette.error,
            );
          }
        },
        builder: (context, authState) {
          return BlocConsumer<AppUserCubit, AppUserState>(
            listener: (context, state) {
              if (state is AppUserIsLoggedIn && state.errorMessage != null) {
                showSnackBar(
                  state.errorMessage!,
                  color: ColorPalette.error,
                );

                context.read<AppUserCubit>().clearErrorMessage();
              }
            },
            builder: (context, state) {
              bool isEmailUser = false;
              if (state is AppUserIsLoggedIn) {
                isEmailUser = state.user.authProvider == 'email';
              }

              return ListView(
                padding: const EdgeInsets.all(ThemeSizes.md),
                children: [
                  if (state is AppUserIsLoggedIn) ...[
                    _buildProfileHeader(
                      context,
                      state,
                      authState is AuthProfileImageLoading,
                    ),
                    const SizedBox(height: ThemeSizes.lg),
                  ],
                  _buildSectionHeader(context, 'Profilo'),
                  _buildMenuItem(
                    context,
                    icon: Icons.person,
                    title: 'Modifica Profilo',
                    onTap: () => EditProfileDialog.show(context),
                  ),
                  if (isEmailUser)
                    _buildMenuItem(
                      context,
                      icon: Icons.password,
                      title: 'Cambia Password',
                      onTap: () => PasswordChangeDialog.show(context),
                    ),
                  const SizedBox(height: ThemeSizes.lg),
                  _buildSectionHeader(context, 'Privacy e Consensi'),
                  _buildMenuItem(
                    context,
                    icon: Icons.fact_check_rounded,
                    title: 'Consensi App',
                    subtitle: 'Modifica consensi età e termini di servizio',
                    onTap: () => ConsentSettingsDialog.show(context),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.ads_click_rounded,
                    title: 'Consenso Annunci (GDPR)',
                    subtitle: 'Gestisci preferenze per annunci personalizzati',
                    onTap: () => GdprConsentDialog.show(context),
                  ),
                  const SizedBox(height: ThemeSizes.lg),
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
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    AppUserIsLoggedIn state,
    bool isUploading,
  ) {
    return Card(
      color: context.secondaryBgColor,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeSizes.lg),
        child: Column(
          children: [
            GestureDetector(
              onTap:
                  isUploading ? null : () => _showProfileImageOptions(context),
              child: _buildProfileAvatar(context, state, isUploading),
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              state.user.name,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeSizes.xs),
            Text(
              state.user.email,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textSecondaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(
    BuildContext context,
    AppUserIsLoggedIn state,
    bool isUploading,
  ) {
    final imageUrl = state.user.profileImageUrl;
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Stack(
      children: [
        Container(
          width: 104,
          height: 104,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: context.primaryColor.withValues(alpha: 0.35),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: hasImage
                ? Image.network(
                    imageUrl,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildInitialAvatar(context, state.user.name),
                  )
                : _buildInitialAvatar(context, state.user.name),
          ),
        ),
        Positioned(
          right: 2,
          bottom: 2,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.primaryColor,
              border: Border.all(
                color: context.secondaryBgColor,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 17,
            ),
          ),
        ),
        if (isUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.45),
              ),
              child: const Center(
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitialAvatar(BuildContext context, String name) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';

    return Container(
      width: 96,
      height: 96,
      color: context.primaryColor.withValues(alpha: 0.18),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: context.textTheme.headlineMedium?.copyWith(
          color: context.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showProfileImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ThemeSizes.borderRadiusLg),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(ThemeSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Immagine profilo: ',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeSizes.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageSourceOption(
                  context,
                  icon: Icons.camera_alt_rounded,
                  label: 'Fotocamera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickProfileImage(
                      context,
                      image_picker.ImageSource.camera,
                    );
                  },
                ),
                _buildImageSourceOption(
                  context,
                  icon: Icons.photo_library_rounded,
                  label: 'Galleria',
                  onTap: () {
                    Navigator.pop(context);
                    _pickProfileImage(
                      context,
                      image_picker.ImageSource.gallery,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: ThemeSizes.md),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(ThemeSizes.md),
        decoration: BoxDecoration(
          color: context.secondaryBgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 26,
              color: context.textSecondaryColor,
            ),
            const SizedBox(height: ThemeSizes.sm),
            Text(
              label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickProfileImage(
    BuildContext context,
    image_picker.ImageSource source,
  ) async {
    final imageFile = await ImagePickerUtil.pickImage(
      context: context,
      enableCropping: true,
      isCircular: true,
      aspectRatio: 1.0,
      source: source,
    );

    if (imageFile == null || !context.mounted) return;

    context.read<AuthBloc>().add(
          UpdateProfileImageEvent(imageFile: imageFile),
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
