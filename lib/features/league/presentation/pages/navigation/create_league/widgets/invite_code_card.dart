import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:share_plus/share_plus.dart';

class InviteCodeCard extends StatefulWidget {
  final String inviteCode;
  final String? leagueName;

  const InviteCodeCard({
    super.key,
    required this.inviteCode,
    this.leagueName,
  });

  @override
  State<InviteCodeCard> createState() => _InviteCodeCardState();
}

class _InviteCodeCardState extends State<InviteCodeCard> {
  bool _codeCopied = false;

  void _copyInviteCode() {
    Clipboard.setData(ClipboardData(text: widget.inviteCode));
    setState(() {
      _codeCopied = true;
    });

    showSnackBar(
      'Codice invito copiato negli appunti!',
      color: ColorPalette.success,
    );

    // Reset the copied state after some delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _codeCopied = false;
        });
      }
    });
  }

  void _shareInviteCode() {
    final title = widget.leagueName != null
        ? 'Unisciti alla lega "${widget.leagueName}"!'
        : 'Unisciti alla mia lega!';
    final subject = widget.leagueName != null
        ? 'Invito lega - ${widget.leagueName}'
        : 'Invito lega';

    SharePlus.instance.share(
      ShareParams(
        title: title,
        text: '🔥 Codice invito: ${widget.inviteCode}\n\n'
            'Invita i tuoi amici a partecipare su Fantavacanze.',
        subject: subject,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorPalette.darkerGrey.withValues(alpha: 0.1),
            context.secondaryBgColor,
          ],
        ),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(ThemeSizes.md),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.key,
                      size: 20,
                    ),
                    const SizedBox(width: ThemeSizes.xs),
                    Text(
                      'Codice Invito',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ThemeSizes.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: ThemeSizes.md,
                    horizontal: ThemeSizes.lg,
                  ),
                  decoration: BoxDecoration(
                    color: context.bgColor,
                    borderRadius:
                        BorderRadius.circular(ThemeSizes.borderRadiusMd),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.inviteCode,
                        style: context.textTheme.headlineSmall?.copyWith(
                          letterSpacing: 2,
                          color:
                              context.textPrimaryColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ThemeSizes.md,
              ThemeSizes.sm,
              ThemeSizes.md,
              ThemeSizes.lg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyInviteCode,
                    icon: Icon(
                      _codeCopied ? Icons.check_circle : Icons.copy_rounded,
                    ),
                    label: Text(
                      _codeCopied ? 'Copiato!' : 'Copia',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: context.textSecondaryColor,
                        width: 1,
                      ),
                      foregroundColor: context.textSecondaryColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: ThemeSizes.md,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: ThemeSizes.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareInviteCode,
                    icon: const Icon(Icons.share_rounded),
                    label: const Text(
                      'Condividi',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          ColorPalette.success.withValues(alpha: 0.3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: ThemeSizes.md,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
