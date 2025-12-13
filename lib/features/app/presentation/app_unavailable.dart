import 'package:fantavacanze_official/core/widgets/info_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';

class AppUnavailablePage extends StatelessWidget {
  static const String routeName = '/app-unavailable';

  static get route => MaterialPageRoute(
        builder: (context) => const AppUnavailablePage(),
        settings: const RouteSettings(name: routeName),
      );

  final String? customMessage;

  const AppUnavailablePage({
    super.key,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppThemeCubit, AppThemeState>(
      builder: (context, themeState) {
        final message = customMessage ??
            "Stiamo lavorando ad un problema critico, l'applicazione sarà presto disponibile. Siamo un team piccolo e facciamo del nostro meglio per garantirti la migliore esperienza possibile. Ci scusiamo per il disagio.";

        return Scaffold(
          backgroundColor: context.bgColor,
          appBar: AppBar(
            title: _buildLogo(context),
            centerTitle: true,
            elevation: 0,
            toolbarHeight: Constants.getHeight(context) * 0.15,
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            forceMaterialTransparency: true,
          ),
          body: PopScope(
            canPop: false,
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.build_circle_outlined,
                          size: 80,
                          color: context.primaryColor,
                        ),
                      ),
                      const SizedBox(height: ThemeSizes.xl),
                      Text(
                        'App in manutenzione',
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: ThemeSizes.lg),
                      InfoContainer(
                        title: "Importante",
                        message: message,
                        icon: Icons.info,
                        color: context.primaryColor,
                      ),
                      const SizedBox(height: ThemeSizes.lg),
                      Text(
                        'Ora puoi uscire dall\'app. Potrebbero volerci tra le 6 e le 12 ore.',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: ThemeSizes.xxl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final widthFactor = isTablet ? 0.20 : 0.25;

    return Image.asset(
      context.read<AppThemeCubit>().isDarkMode(context)
          ? 'assets/images/logos/logo-neon.png'
          : 'assets/images/logos/logo-naked.png',
      width: Constants.getWidth(context) * widthFactor,
    );
  }
}
