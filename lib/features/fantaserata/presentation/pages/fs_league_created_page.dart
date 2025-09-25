import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_page_specific_snackbar.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_invite_code_card.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_league_created/fs_success_animation.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_league_created/fs_success_header.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_league_created/fs_info_section.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_league_created/fs_navigation_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class FsLeagueCreatedPage extends StatefulWidget {
  final FsLeague league;

  static route(FsLeague league) => MaterialPageRoute(
        builder: (context) => FsLeagueCreatedPage(league: league),
        settings: const RouteSettings(name: '/fs-league-created'),
      );

  const FsLeagueCreatedPage({
    super.key,
    required this.league,
  });

  @override
  State<FsLeagueCreatedPage> createState() => _FsLeagueCreatedPageState();
}

class _FsLeagueCreatedPageState extends State<FsLeagueCreatedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
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
        title: Text(
          'Lega Creata!',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
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
                const SizedBox(height: ThemeSizes.md),

                // Success animation
                FsSuccessAnimation(scale: _scaleAnimation.value),

                const SizedBox(height: ThemeSizes.xl),

                // Header text
                FsSuccessHeader(leagueName: widget.league.name),

                const SizedBox(height: ThemeSizes.xl),

                // Invite code card
                FsInviteCodeCard(
                  inviteCode: widget.league.inviteCode,
                  onCopy: () {
                    Clipboard.setData(
                        ClipboardData(text: widget.league.inviteCode));
                    showSpecificSnackBar(
                      context,
                      'Codice invito copiato negli appunti!',
                      color: ColorPalette.success,
                    );
                  },
                  onShare: () {
                    SharePlus.instance.share(ShareParams(
                      title:
                          'Unisciti alla FantaSerata "${widget.league.name}"!',
                      text: '🔥 Codice invito: ${widget.league.inviteCode}\n\n'
                          '⏰ Ricorda: la lega si autodistrugge alle 7:00 del mattino.',
                      subject: 'Invito FantaSerata - ${widget.league.name}',
                    ));
                  },
                ),

                const SizedBox(height: ThemeSizes.xl),

                // Info containers
                const FsInfoSection(),

                const SizedBox(height: ThemeSizes.xl),

                // Navigation buttons
                const FsNavigationButtons(),

                const SizedBox(height: ThemeSizes.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
