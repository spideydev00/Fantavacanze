import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/theme/theme.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/social_login.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/core/confirmation_dialog.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/core/divider.dart';
import 'package:fantavacanze_official/features/league/presentation/widgets/settings/settings_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  static get route => MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      );
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppThemeCubit, AppThemeState>(
      builder: (context, state) {
        return AnimatedTheme(
            data: AppTheme.getTheme(context),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutQuart,
            child: Scaffold(
              backgroundColor: context.bgColor,
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: false,
                    title: Text(
                      'Impostazioni',
                      style: context.textTheme.titleLarge!,
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: BackButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          DashboardScreen.route,
                          (route) => false,
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(ThemeSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UserProfileCard(
                            name: 'Alex',
                            avatarAsset: 'assets/images/avatar.png',
                            onTap: () {
                              // Navigate to profile edit page
                            },
                          ),
                          const SizedBox(height: ThemeSizes.lg),
                          CustomDivider(text: "Aspetto"),
                          const SizedBox(height: ThemeSizes.md),
                          _buildAppearanceSection(context),
                          const SizedBox(height: ThemeSizes.lg),
                          CustomDivider(text: "Notifiche"),
                          const SizedBox(height: ThemeSizes.md),
                          _buildNotificationsSection(context),
                          const SizedBox(height: ThemeSizes.lg),
                          CustomDivider(text: "Privacy e Sicurezza"),
                          const SizedBox(height: ThemeSizes.md),
                          _buildPrivacySection(context),
                          const SizedBox(height: ThemeSizes.lg),
                          CustomDivider(text: "Informazioni"),
                          const SizedBox(height: ThemeSizes.md),
                          _buildAboutSection(context),
                          const SizedBox(height: ThemeSizes.spaceBtwSections),
                          _buildLogoutButton(context),
                          const SizedBox(
                              height: ThemeSizes.spaceBtwSections + 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => _handleLogout(context),
        style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              // Mantieni lo stesso stile ma cambia solo dimensioni o altre proprietà specifiche
              maximumSize: WidgetStatePropertyAll(
                Size.fromWidth(
                  Constants.getWidth(context) * 0.5,
                ),
              ),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout),
            const SizedBox(width: ThemeSizes.sm),
            const Text('Disconnetti'),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return Column(
      children: [
        SettingsTile(
          icon: Icons.dark_mode,
          title: 'Night Mode',
          trailing: BlocBuilder<AppThemeCubit, AppThemeState>(
            builder: (context, state) {
              final isDark = context.read<AppThemeCubit>().isDarkMode(context);
              return Switch(
                value: isDark,
                onChanged: (_) {
                  context.read<AppThemeCubit>().toggleTheme();
                },
                activeColor: context.primaryColor,
                activeTrackColor: context.secondaryColor,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    return Column(
      children: [
        SettingsTile(
          icon: Icons.notifications,
          title: 'Notifiche Push',
          trailing: Switch(
            value: true,
            onChanged: (value) {
              // Toggle push notifications
            },
            activeColor: context.primaryColor,
            activeTrackColor: context.secondaryColor,
          ),
        ),
        SizedBox(height: ThemeSizes.sm),
        SettingsTile(
          icon: Icons.email,
          title: 'Email',
          trailing: Switch(
            value: true,
            onChanged: (value) {
              // Toggle email notifications
            },
            activeColor: context.primaryColor,
            activeTrackColor: context.secondaryColor,
          ),
        ),
        SizedBox(height: ThemeSizes.sm),
        SettingsTile(
          icon: Icons.volume_up,
          title: 'Suoni',
          trailing: Switch(
            value: false,
            onChanged: (value) {
              // Toggle sounds
            },
            activeColor: context.primaryColor,
            activeTrackColor: context.secondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection(BuildContext context) {
    return Column(
      children: [
        SettingsTile(
          icon: Icons.lock,
          title: 'Cambia Password',
          onTap: () {
            // Navigate to change password screen
          },
        ),
        SizedBox(height: ThemeSizes.sm),
        SettingsTile(
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          onTap: () {
            // Show privacy policy
          },
        ),
        SizedBox(height: ThemeSizes.sm),
        SettingsTile(
          icon: Icons.description,
          title: 'Termini di Servizio',
          onTap: () {
            // Show terms of service
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      children: [
        SettingsTile(
          icon: Icons.info,
          title: 'Versione App',
          subtitle: '1.0.0',
          onTap: () {
            // Show app version details
          },
        ),
        SizedBox(height: ThemeSizes.sm),
        SettingsTile(
          icon: Icons.star,
          title: 'Valuta l\'App',
          onTap: () {
            // Open app store for rating
          },
        ),
        SizedBox(height: ThemeSizes.sm),
        SettingsTile(
          icon: Icons.contact_support,
          title: 'Supporto',
          onTap: () {
            // Navigate to support screen
          },
        ),
      ],
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog.logOut(
        onExit: () async {
          Navigator.of(context).pop();

          Navigator.pushAndRemoveUntil(
            context,
            SocialLoginPage.route,
            (route) => false,
          );

          // esci dall'account
          await context.read<AppUserCubit>().signOut();
        },
      ),
    );
  }
}
