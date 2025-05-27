import 'package:fantavacanze_official/core/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';

class InviteCodeCard extends StatefulWidget {
  final String inviteCode;

  const InviteCodeCard({
    super.key,
    required this.inviteCode,
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
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _copyInviteCode,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(ThemeSizes.borderRadiusLg),
                bottomRight: Radius.circular(ThemeSizes.borderRadiusLg),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: ThemeSizes.md,
                ),
                decoration: BoxDecoration(
                  color: ColorPalette.success.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(ThemeSizes.borderRadiusLg),
                    bottomRight: Radius.circular(ThemeSizes.borderRadiusLg),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _codeCopied ? Icons.check_circle : Icons.content_copy,
                      size: 18,
                    ),
                    const SizedBox(width: ThemeSizes.sm),
                    Text(
                      _codeCopied ? 'Copiato!' : 'Copia Codice',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
