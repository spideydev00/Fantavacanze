import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:fantavacanze_official/core/secrets/app_secrets.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class CloudflareTurnstileWidget extends StatelessWidget {
  final Function(String token) onTokenReceived;
  final bool isInvisible;

  const CloudflareTurnstileWidget(
      {super.key, required this.onTokenReceived, this.isInvisible = false});

  @override
  Widget build(BuildContext context) {
    final TurnstileOptions options = TurnstileOptions(
      size: TurnstileSize.normal,
      theme: TurnstileTheme.light,
      language: 'IT',
      retryAutomatically: false,
      refreshTimeout: TurnstileRefreshTimeout.auto,
      borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
    );

    return !isInvisible
        ? CloudflareTurnstile(
            siteKey: AppSecrets.turnstileKey,
            baseUrl: AppSecrets.supabaseUrl,
            options: options,
            onTokenReceived: onTokenReceived,
          )
        : CloudflareTurnstile.invisible(
            siteKey: AppSecrets.turnstileKey,
            baseUrl: AppSecrets.supabaseUrl,
            options: options,
            onTokenReceived: onTokenReceived,
          );
  }
}
