import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:fantavacanze_official/core/secrets/app_secrets.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';

class CloudflareTurnstileWidget extends StatefulWidget {
  final Function(String token) onTokenReceived;
  final bool isInvisible;

  const CloudflareTurnstileWidget({
    super.key,
    required this.onTokenReceived,
    this.isInvisible = false,
  });

  @override
  State<CloudflareTurnstileWidget> createState() =>
      CloudflareTurnstileWidgetState();
}

class CloudflareTurnstileWidgetState extends State<CloudflareTurnstileWidget> {
  // Use a key to force widget rebuild and reset
  Key _turnstileKey = UniqueKey();

  // Public method to reset the widget
  void resetWidget() {
    setState(() {
      // Change the key to force widget rebuild
      _turnstileKey = UniqueKey();
      // Clear the token
      widget.onTokenReceived('');
    });
  }

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

    return !widget.isInvisible
        ? CloudflareTurnstile(
            key: _turnstileKey,
            siteKey: AppSecrets.turnstileKey,
            baseUrl: AppSecrets.supabaseUrl,
            options: options,
            onTokenReceived: widget.onTokenReceived,
          )
        : CloudflareTurnstile.invisible(
            siteKey: AppSecrets.turnstileKey,
            baseUrl: AppSecrets.supabaseUrl,
            options: options,
            onTokenReceived: widget.onTokenReceived,
          );
  }
}
