import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/info_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdatePage extends StatelessWidget {
  static const String routeName = '/force-update';

  static MaterialPageRoute<dynamic> route(String? storeUrl) =>
      MaterialPageRoute(
        builder: (_) => ForceUpdatePage(storeUrl: storeUrl),
        settings: const RouteSettings(name: routeName),
      );

  final String? storeUrl;

  const ForceUpdatePage({
    super.key,
    this.storeUrl,
  });

  Future<void> _openStore() async {
    final url = storeUrl;
    if (url == null) {
      debugPrint('Store URL non disponibile per force update');
      return;
    }

    try {
      final launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        debugPrint('Apertura store non riuscita: $url');
      }
    } catch (e) {
      debugPrint('Errore apertura store: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppThemeCubit, AppThemeState>(
      builder: (context, _) {
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
                          Icons.system_update_alt_rounded,
                          size: 80,
                          color: context.primaryColor,
                        ),
                      ),
                      const SizedBox(height: ThemeSizes.xl),
                      Text(
                        'Aggiornamento richiesto',
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: ThemeSizes.lg),
                      InfoContainer(
                        title: 'Nuova versione disponibile',
                        message:
                            "Per continuare a usare Fantavacanze devi installare l'ultima versione disponibile sullo store. Apprezziamo la tua pazienza!",
                        icon: Icons.info,
                        color: context.primaryColor,
                      ),
                      const SizedBox(height: ThemeSizes.lg),
                      ElevatedButton(
                        onPressed: _openStore,
                        child: const Text('Aggiorna ora'),
                      ),
                      const SizedBox(height: ThemeSizes.lg),
                      Text(
                        "Non potrai usare l'app finché non avrai aggiornato.",
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
