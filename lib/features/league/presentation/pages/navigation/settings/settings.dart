import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/theme/theme.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/social_login.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/sections/dashboard.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/core/pages/app_terms.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/settings/privacy_policy.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/settings/widgets/app_info_dialog.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/settings/widgets/support_contact_dialog.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/settings/widgets/user_profile_menu.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/settings/widgets/settings_widgets.dart';
import 'package:fantavacanze_official/core/widgets/buttons/danger_action_button.dart';
import 'package:fantavacanze_official/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatelessWidget {
  static const String routeName = '/settings';

  static get route => MaterialPageRoute(
        builder: (context) => const SettingsPage(),
        settings: const RouteSettings(name: routeName),
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
                      style: context.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                            onTap: () {
                              Navigator.push(context, UserProfileMenu.route);
                            },
                          ),
                          //divider
                          _buildDivider("Aspetto"),
                          //section
                          _buildAppearanceSection(context),
                          //divider
                          _buildDivider("Privacy e Sicurezza"),
                          //section
                          _buildPrivacySection(context),
                          //divider
                          _buildDivider("Informazioni"),
                          //section
                          _buildAboutSection(context),
                          const SizedBox(height: ThemeSizes.spaceBtwSections),
                          _buildLogoutButton(context),
                          const SizedBox(
                            height: ThemeSizes.spaceBtwSections,
                          ),
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
    return DangerActionButton(
      title: 'Disconnetti',
      description: 'Esci dal tuo account',
      icon: Icons.logout,
      onTap: () => _handleLogout(context),
      color: ColorPalette.error,
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (_) => ConfirmationDialog.logOut(
        onExit: () async {
          // Chiudo il dialog
          navigatorKey.currentState!.pop();

          await context.read<AppUserCubit>().signOut();

          if (context.mounted) {
            await context.read<AppLeagueCubit>().clearCache();
          }

          // Azzero tutto lo stack e mostro solo SocialLoginPage
          navigatorKey.currentState!.pushAndRemoveUntil(
            SocialLoginPage.route,
            (route) => false,
          );
        },
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection(BuildContext context) {
    return Column(
      children: [
        SettingsTile(
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          onTap: () {
            Navigator.push(context, PrivacyPolicyPage.route);
          },
        ),
        const SizedBox(height: ThemeSizes.sm),
        SettingsTile(
          icon: Icons.description,
          title: 'Termini di Servizio',
          onTap: () {
            Navigator.push(context, AppTermsPage.route);
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
          //TODO: Get version dynamically
          subtitle: '1.0.7',
          onTap: () {
            AppInfoDialog.show(context);
          },
        ),
        const SizedBox(height: ThemeSizes.sm),
        SettingsTile(
          icon: Icons.contact_support,
          title: 'Supporto',
          onTap: () {
            SupportContactDialog.show(context);
          },
        ),
      ],
    );
  }

  Widget _buildDivider(String text) {
    return Column(
      children: [
        const SizedBox(height: ThemeSizes.md),
        CustomDivider(text: text),
        const SizedBox(height: ThemeSizes.sm),
      ],
    );
  }
}
