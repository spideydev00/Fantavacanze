import 'package:fantavacanze_official/core/constants/fantaserata/simple_fs_rule.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/divider.dart';
import 'package:fantavacanze_official/core/widgets/empty_state.dart';
import 'package:fantavacanze_official/core/widgets/info_banner.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_dashboard/fs_objective_card.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/bloc/fs_rules_bloc/fs_rules_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';

enum SectionView { bonus, malus }

class FsObjectivesSection extends StatefulWidget {
  final FsLeague league;

  const FsObjectivesSection({
    super.key,
    required this.league,
  });

  @override
  State<FsObjectivesSection> createState() => _FsObjectivesSectionState();
}

class _FsObjectivesSectionState extends State<FsObjectivesSection>
    with TickerProviderStateMixin {
  late final AnimationController _fadeAnimationController;
  late final AnimationController _expandAnimationController;
  late final AnimationController _iconController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _iconRotationAnimation;

  SectionView _currentView = SectionView.bonus;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();

    // Fade animation for initial load
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _fadeAnimationController, curve: Curves.easeInOut),
    );

    // Expand animation (la uso solo per triggerare un rebuild "soft")
    _expandAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _expandAnimation = Tween<double>(begin: 0.8, end: 0.95).animate(
      CurvedAnimation(
        parent: _expandAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Icon rotation animation (controller dedicato)
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _iconRotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeAnimationController.forward();
    _expandAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _expandAnimationController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  Future<void> _switchSection() async {
    if (_isTransitioning) return;
    setState(() => _isTransitioning = true);

    // piccola rotazione dell'icona ad ogni switch
    _iconController.forward(from: 0);

    if (_currentView == SectionView.bonus) {
      setState(() => _currentView = SectionView.malus);
    } else {
      setState(() => _currentView = SectionView.bonus);
    }

    // Attendi la durata dell’AnimatedSwitcher per evitare tap multipli
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _isTransitioning = false);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
        child: Column(
          children: [
            InfoBanner(
              message:
                  "Clicca su una card per assegnare bonus/malus. Per vedere i malus, usa il pulsante a lato.",
              color: ColorPalette.info,
            ),
            // Contenuto principale con leggero padding a destra
            CustomDivider(
              text: "Obiettivi Della Serata",
              hasDropdown: true,
              dropdownText:
                  "Ogni partecipante ha 5 bonus fissi e 3 obiettivi speciali diversi ogni volta. I malus sono 5, fissi per ogni serata. \n\nPuoi aggiungere obiettivi personalizzati nella tab \"Lega\". Siete tutti amministratori, anarchia.",
            ),

            SizedBox(
              height: ThemeSizes.md,
            ),

            Expanded(
              child: AnimatedBuilder(
                animation: _expandAnimation,
                builder: (context, child) {
                  const double buttonWidth = 48;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: buttonWidth / 3),
                        child: _buildCurrentSection(),
                      ),

                      // Control button "a cavallo" del bordo destro
                      Positioned(
                        right: -(buttonWidth / 3),
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: SizedBox(
                            width: buttonWidth,
                            height: buttonWidth,
                            child: _buildControlButton(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton() {
    final isBonus = _currentView == SectionView.bonus;

    final theme = context.read<AppThemeCubit>().state.themeMode;
    final isDarkMode = theme == ThemeMode.dark;

    final secondaryBgColor = isDarkMode
        ? ColorPalette.secondaryBgColor(ThemeMode.light)
        : ColorPalette.secondaryBgColor(ThemeMode.dark);

    final primaryTextColor = isDarkMode
        ? ColorPalette.textPrimary(ThemeMode.light)
        : ColorPalette.textPrimary(ThemeMode.dark);

    return Material(
      elevation: 8,
      shadowColor: primaryTextColor.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      color: Colors.transparent,
      child: InkWell(
        onTap: _isTransitioning ? null : _switchSection,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                secondaryBgColor.withValues(alpha: 0.9),
                secondaryBgColor,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryTextColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _iconRotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _iconRotationAnimation.value * 2 * 3.14159,
                  child: Icon(
                    isBonus
                        ? Icons.arrow_left_rounded
                        : Icons.arrow_right_rounded,
                    color: primaryTextColor,
                    size: 40,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSection() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        // slide orizzontale coerente con la direzione
        final slideAnimation = Tween<Offset>(
          begin: _currentView == SectionView.bonus
              ? const Offset(1.0, 0.0)
              : const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        ));

        // fade progressivo (mai > 1.0)
        final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
          ),
        );

        // scala con un leggero back (solo scala, non opacità)
        final scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        );

        return SlideTransition(
          position: slideAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        key: ValueKey(_currentView),
        child: _currentView == SectionView.bonus
            ? _buildBonusSection()
            : _buildMalusSection(),
      ),
    );
  }

  Widget _buildBonusSection() {
    return BlocConsumer<FsRulesBloc, FsRulesState>(
      listener: (context, state) {
        if (state is FsRulesFailure) {
          showSnackBar(
            state.message,
            color: ColorPalette.error,
          );
        }
      },
      builder: (context, state) {
        if (state is FsRulesLoading) {
          return _buildLoadingState();
        }

        final List<Widget> bonusCards = [];

        if (state is FsRulesLoaded) {
          // Get current user ID
          final currentUserId = _getCurrentUserId();

          if (currentUserId == null) {
            return _buildEmptyState('Utente non autenticato');
          }

          // Filter rules for current user only
          final userRules = state.rules
              .where((rule) => rule.userId == currentUserId)
              .toList();

          final bonusRules = userRules
              .where((rule) => rule.type == FsRuleType.bonus)
              .toList()
            ..sort((a, b) => a.position.compareTo(b.position));

          bonusCards.addAll(bonusRules.map((rule) => _buildRuleCard(rule)));
        }

        if (bonusCards.isEmpty) {
          return _buildEmptyState('Nessun bonus disponibile');
        }

        return _buildAnimatedList(bonusCards);
      },
    );
  }

  Widget _buildMalusSection() {
    return BlocConsumer<FsRulesBloc, FsRulesState>(
      listener: (context, state) {
        if (state is FsRulesFailure) {
          showSnackBar(
            state.message,
            color: ColorPalette.error,
          );
        }
      },
      builder: (context, state) {
        if (state is FsRulesLoading) {
          return _buildLoadingState();
        }

        final List<Widget> malusCards = [];

        if (state is FsRulesLoaded) {
          // Get current user ID
          final currentUserId = _getCurrentUserId();

          // Filter rules for current user only
          final userRules = state.rules
              .where((rule) => rule.userId == currentUserId)
              .toList();

          final malusRules = userRules
              .where((rule) => rule.type == FsRuleType.malus)
              .toList()
            ..sort((a, b) => a.position.compareTo(b.position));

          malusCards.addAll(malusRules.map((rule) => _buildRuleCard(rule)));
        }

        if (malusCards.isEmpty) {
          return _buildEmptyState('Nessun malus disponibile');
        }

        return _buildAnimatedList(malusCards);
      },
    );
  }

  Widget _buildAnimatedList(List<Widget> cards) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: cards.asMap().entries.map((entry) {
          final index = entry.key;
          final card = entry.value;

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, t, child) {
              // slide con back solo sul movimento
              final slideT = Curves.easeOutBack.transform(t);
              // opacità sempre clampata
              final opacityT = t.clamp(0.0, 1.0);
              return Transform.translate(
                offset: Offset(0, 50 * (1 - slideT)),
                child: Opacity(
                  opacity: opacityT,
                  child: card,
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRuleCard(FsRule rule) {
    final isDynamic =
        rule.position == 1 || rule.position == 2 || rule.position == 3;

    return FsObjectiveCard(
      rule: SimpleFsRule(
        id: rule.challengeId,
        name: rule.name,
        type: rule.type,
        points: rule.points,
        isCompleted: rule.isCompleted,
      ),
      isCompleted: rule.isCompleted,
      isLocked: !rule.isUnlocked,
      canRefresh: !rule.isRefreshed && !rule.isCompleted && rule.isUnlocked,
      position: rule.position.toInt(),
      isDynamic: isDynamic,
      onRefresh: (!rule.isRefreshed && !rule.isCompleted && rule.isUnlocked)
          ? () {
              context.read<FsRulesBloc>().add(
                    RefreshRuleEvent(
                      leagueId: widget.league.id,
                      challengeId: rule.challengeId,
                    ),
                  );
            }
          : null,
      onComplete: !rule.isCompleted && rule.isUnlocked
          ? () => _showSetRuleAsCompletedDialog(
                rule.name,
                rule.points,
                rule.challengeId,
                rule.type == FsRuleType.bonus,
                isDynamic: isDynamic,
              )
          : null,
      // Callback specifico per ads unlock (position 2)
      onAdUnlock: !rule.isUnlocked && rule.position.toInt() == 2
          ? () => _unlockRuleWithAds(rule)
          : null,
      // Callback specifico per premium unlock (position 3 e altri)
      onPremiumUnlock: !rule.isUnlocked && rule.position.toInt() != 2
          ? () => _unlockRuleWithPremium(rule)
          : null,
    );
  }

  /// Mostra il dialog di conferma per l'aggiunta di un evento
  void _showSetRuleAsCompletedDialog(
    String ruleName,
    double points,
    String challengeId,
    bool isBonus, {
    bool isDynamic = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog.setFsRuleCompleted(
        ruleName: ruleName,
        points: points,
        isBonus: isBonus,
        onConfirm: () {
          context.read<FsRulesBloc>().add(
                SetRuleAsCompletedEvent(
                  leagueId: widget.league.id,
                  challengeId: challengeId,
                  ruleName: ruleName,
                  points: points,
                  type: isBonus ? 'bonus' : 'malus',
                ),
              );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Loader(color: ColorPalette.fsGradients.first),
            const SizedBox(height: ThemeSizes.lg),
            Text(
              'Caricamento obiettivi...',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return EmptyState(
      icon: Icons.info_outline_rounded,
      title: 'Nessun Obiettivo',
      subtitle: message,
    );
  }

  /// Helper method to get current user ID
  String? _getCurrentUserId() {
    final userState = context.read<AppUserCubit>().state;
    if (userState is AppUserIsLoggedIn) {
      return userState.user.id;
    }
    return null;
  }

  /// Sblocca una regola tramite ads (position 2)
  void _unlockRuleWithAds(FsRule rule) {
    context.read<FsRulesBloc>().add(
          UnlockRuleEvent(
            leagueId: widget.league.id,
            challengeId: rule.challengeId,
          ),
        );
  }

  /// Sblocca una regola tramite premium (position 3 e altri)
  void _unlockRuleWithPremium(FsRule rule) {
    context.read<FsRulesBloc>().add(
          UnlockRuleEvent(
            leagueId: widget.league.id,
            challengeId: rule.challengeId,
          ),
        );
  }
}
