import 'package:fantavacanze_official/core/constants/fantaserata/default_fs_rule.dart';
import 'package:fantavacanze_official/core/cubits/app_theme/app_theme_cubit.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/auth/domain/entities/user.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/widgets/fs_dashboard/fs_objective_card.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/bloc/fs_fixed_rules_bloc/fs_fixed_rules_bloc.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/bloc/fs_dynamic_rules_bloc/fs_dynamic_rules_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum SectionView { bonus, malus }

class FsObjectivesSection extends StatefulWidget {
  final User user;
  final FsLeague league;

  const FsObjectivesSection({
    super.key,
    required this.user,
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

    // Initialize fixed rules
    context.read<FsFixedRulesBloc>().add(
          GetFixedRulesEvent(
            userId: widget.user.id,
            gender: widget.user.gender ?? 'mixed',
            sentimentalStatus: widget.user.sentimentalStatus ?? 'single',
          ),
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
            Expanded(
              child: AnimatedBuilder(
                animation: _expandAnimation,
                builder: (context, child) {
                  const double buttonWidth = 48; // dimensione fissa

                  return Stack(
                    clipBehavior: Clip.none, // permette metà bottone fuori
                    children: [
                      // Contenuto principale con leggero padding a destra
                      Padding(
                        // spazio per non far coprire il contenuto dal bottone
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
    return BlocBuilder<FsDynamicRulesBloc, FsDynamicRulesState>(
      builder: (context, dynamicState) {
        return BlocBuilder<FsFixedRulesBloc, FsFixedRulesState>(
          builder: (context, fixedState) {
            if (dynamicState is FsDynamicRulesLoading ||
                fixedState is FsFixedRulesLoading) {
              return _buildLoadingState();
            }

            final List<Widget> bonusCards = [];

            if (dynamicState is FsDynamicRulesLoaded) {
              final dynamicBonus = dynamicState.rules
                  .where((rule) => rule.type == FsRuleType.bonus)
                  .toList();
              bonusCards.addAll(
                  dynamicBonus.map((rule) => _buildDynamicRuleCard(rule)));
            }

            if (fixedState is FsFixedRulesLoaded) {
              final fixedBonus = fixedState.rules
                  .where((rule) => rule.type == FsRuleType.bonus)
                  .toList();
              bonusCards
                  .addAll(fixedBonus.map((rule) => _buildFixedRuleCard(rule)));
            }

            if (bonusCards.isEmpty) {
              return _buildEmptyState('Nessun bonus disponibile');
            }

            return _buildAnimatedList(bonusCards);
          },
        );
      },
    );
  }

  Widget _buildMalusSection() {
    return BlocBuilder<FsDynamicRulesBloc, FsDynamicRulesState>(
      builder: (context, dynamicState) {
        return BlocBuilder<FsFixedRulesBloc, FsFixedRulesState>(
          builder: (context, fixedState) {
            if (dynamicState is FsDynamicRulesLoading ||
                fixedState is FsFixedRulesLoading) {
              return _buildLoadingState();
            }

            final List<Widget> malusCards = [];

            if (dynamicState is FsDynamicRulesLoaded) {
              final dynamicMalus = dynamicState.rules
                  .where((rule) => rule.type == FsRuleType.malus)
                  .toList();
              malusCards.addAll(
                  dynamicMalus.map((rule) => _buildDynamicRuleCard(rule)));
            }

            if (fixedState is FsFixedRulesLoaded) {
              final fixedMalus = fixedState.rules
                  .where((rule) => rule.type == FsRuleType.malus)
                  .toList();
              malusCards
                  .addAll(fixedMalus.map((rule) => _buildFixedRuleCard(rule)));
            }

            if (malusCards.isEmpty) {
              return _buildEmptyState('Nessun malus disponibile');
            }

            return _buildAnimatedList(malusCards);
          },
        );
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

  Widget _buildDynamicRuleCard(FsRule rule) {
    return FsObjectiveCard(
      rule: DefaultFsRule(
        id: int.tryParse(rule.challengeId) ?? 0,
        name: rule.name,
        type: rule.type,
        points: rule.points,
        isCompleted: rule.isCompleted,
      ),
      isCompleted: rule.isCompleted,
      isLocked: !rule.isUnlocked,
      canRefresh: !rule.isRefreshed && !rule.isCompleted && rule.isUnlocked,
      isDynamic: true,
      onRefresh: (!rule.isRefreshed && !rule.isCompleted && rule.isUnlocked)
          ? () {
              context.read<FsDynamicRulesBloc>().add(
                    RefreshDynamicRuleEvent(
                      userId: widget.user.id,
                      leagueId: widget.league.id,
                      challengeId: rule.challengeId,
                    ),
                  );
            }
          : null,
      onComplete: !rule.isCompleted && rule.isUnlocked
          ? () {
              context.read<FsDynamicRulesBloc>().add(
                    SetDynamicRuleAsCompletedEvent(
                      userId: widget.user.id,
                      leagueId: widget.league.id,
                      challengeId: rule.challengeId,
                      ruleName: rule.name,
                      points: rule.points,
                      type: rule.type == FsRuleType.bonus ? 'bonus' : 'malus',
                    ),
                  );
            }
          : null,
      onUnlock: !rule.isUnlocked
          ? () {
              context.read<FsDynamicRulesBloc>().add(
                    UnlockDynamicRuleEvent(
                      userId: widget.user.id,
                      leagueId: widget.league.id,
                      challengeId: rule.challengeId,
                    ),
                  );
            }
          : null,
    );
  }

  Widget _buildFixedRuleCard(DefaultFsRule rule) {
    return FsObjectiveCard(
      rule: rule,
      isCompleted: rule.isCompleted,
      isLocked: false,
      canRefresh: false,
      isDynamic: false,
      onComplete: !rule.isCompleted
          ? () {
              context.read<FsFixedRulesBloc>().add(
                    ToggleFixedRuleCompletionEvent(
                      ruleId: rule.id,
                      isCompleted: true,
                    ),
                  );
            }
          : null,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: context.textSecondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: ThemeSizes.lg),
            Text(
              'Nessun obiettivo',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: ThemeSizes.sm),
            Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
