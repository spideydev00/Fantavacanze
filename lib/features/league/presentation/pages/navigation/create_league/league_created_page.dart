import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/buttons/modern_icon_button.dart';
import 'package:fantavacanze_official/core/widgets/info_container.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/create_league/league_admin_explainer_page.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/create_league/widgets/invite_code_card.dart';
import 'package:flutter/material.dart';

class LeagueCreatedPage extends StatefulWidget {
  final League league;

  const LeagueCreatedPage({
    super.key,
    required this.league,
  });

  @override
  State<LeagueCreatedPage> createState() => _LeagueCreatedPageState();
}

class _LeagueCreatedPageState extends State<LeagueCreatedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  String? _inviteCode;

  @override
  void initState() {
    super.initState();

    _inviteCode = widget.league.inviteCode;

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lega Creata'),
        elevation: 0,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          );
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(ThemeSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: ColorPalette.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 60,
                            color: ColorPalette.success,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: ThemeSizes.lg),

                // Header text
                Text(
                  'Congratulazioni!',
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.success,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ThemeSizes.sm),

                // Description text
                Text(
                  'La tua lega "${widget.league.name}" è stata creata con successo!',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ThemeSizes.xl),

                // Invite code card - Now using the extracted widget
                if (_inviteCode != null)
                  InviteCodeCard(
                    inviteCode: _inviteCode!,
                    leagueName: widget.league.name,
                  ),

                const SizedBox(height: ThemeSizes.xl),

                // "How to invite friends" - Using the extracted info container

                // Continue to the admin permissions explanation
                ModernIconButton(
                  icon: Icons.arrow_forward_rounded,
                  text: 'Continua',
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) =>
                            const LeagueAdminExplainerPage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                ),

                const SizedBox(height: ThemeSizes.xl),

                InfoContainer(
                  title: 'Come invitare amici',
                  message:
                      'Condividi questo codice invito con i tuoi amici. Potranno usarlo per partecipare.',
                  icon: Icons.info_outline,
                  color: ColorPalette.warning,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
