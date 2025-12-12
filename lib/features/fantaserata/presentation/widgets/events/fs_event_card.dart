import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_league.dart';
import 'package:fantavacanze_official/features/fantaserata/domain/entities/fs_rule/fs_rule.dart';
import 'package:fantavacanze_official/features/fantaserata/presentation/bloc/fs_rules_bloc/fs_rules_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FsEventCard extends StatefulWidget {
  final FsRule rule;
  final FsLeague league;

  const FsEventCard({
    super.key,
    required this.rule,
    required this.league,
  });

  @override
  State<FsEventCard> createState() => _FsEventCardState();
}

class _FsEventCardState extends State<FsEventCard>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _sizeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _sizeAnimation;

  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sizeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _sizeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _sizeController, curve: Curves.easeInOut),
    );

    _fadeController.value = 0.0;
    _sizeController.value = 0.0;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  /// Avvia le animazioni di dismissal in sequenza
  Future<void> _startDismissAnimation() async {
    if (_isDismissing) return;

    setState(() {
      _isDismissing = true;
    });

    // Prima fade out (opacità)
    await _fadeController.forward();

    // Poi size collapse (altezza)
    await _sizeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeController, _sizeController]),
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _sizeAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
          child: Dismissible(
              key: Key(widget.rule.completionId ?? widget.rule.id),
              direction: DismissDirection.startToEnd,
              background: _buildReactivateBackground(),
              confirmDismiss: (direction) async {
                final confirmed = await _showReactivateConfirmDialog(context);
                if (confirmed == true) {
                  // Avvia le animazioni prima della conferma di dismissal
                  await _startDismissAnimation();
                }
                return confirmed;
              },
              onDismissed: (direction) {
                // A questo punto le animazioni sono già completate
                _reactivateEvent(context);
              },
              child: Container(
                padding: const EdgeInsets.all(ThemeSizes.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getEventColor().withValues(alpha: 0.2),
                      context.secondaryBgColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusLg),
                  border: Border.all(
                    color: _getEventColor().withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.borderColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Event type indicator overlay
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getEventColor().withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        // Event type indicator
                        Container(
                          width: 4,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _getEventColor(),
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusSm),
                          ),
                        ),

                        const SizedBox(width: ThemeSizes.md),

                        // Event details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _getEventIcon(),
                                    size: ThemeSizes.iconSm,
                                    color: _getEventColor(),
                                  ),
                                  const SizedBox(width: ThemeSizes.xs),
                                  Expanded(
                                    child: Text(
                                      widget.rule.name,
                                      style: context.textTheme.titleSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: context.textPrimaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: ThemeSizes.xs),
                              Row(
                                children: [
                                  Text(
                                    'Partecipante: ',
                                    style:
                                        context.textTheme.bodySmall?.copyWith(
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      widget.rule.userName ??
                                          widget.rule.userId,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          context.textTheme.bodySmall?.copyWith(
                                        color: context.textPrimaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Points indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeSizes.sm,
                            vertical: ThemeSizes.xs,
                          ),
                          decoration: BoxDecoration(
                            color: _getEventColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusLg),
                            border: Border.all(
                              color: _getEventColor().withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${widget.rule.type == FsRuleType.bonus ? '+' : '-'}${widget.rule.points}',
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getEventColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReactivateBackground() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: ThemeSizes.xl),
      decoration: BoxDecoration(
        color: ColorPalette.error.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.delete_forever_rounded,
            color: ColorPalette.error,
            size: ThemeSizes.iconMd,
          ),
          const SizedBox(width: ThemeSizes.sm),
          Text(
            'Rimuovi',
            style: TextStyle(
              color: ColorPalette.error,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showReactivateConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog.reactivateEvent(
        eventName: widget.rule.name,
        onReactivate: () => _reactivateEvent(context),
      ),
    );
  }

  void _reactivateEvent(BuildContext context) {
    context.read<FsRulesBloc>().add(
          SetRuleAsUncompletedEvent(
            rule: widget.rule,
            completionId: widget.rule.completionId ??
                widget
                    .rule.id, // Use unique completion ID for targeted removal
          ),
        );
  }

  Color _getEventColor() {
    switch (widget.rule.type) {
      case FsRuleType.bonus:
        return ColorPalette.success;
      case FsRuleType.malus:
        return ColorPalette.error;
    }
  }

  IconData _getEventIcon() {
    switch (widget.rule.type) {
      case FsRuleType.bonus:
        return Icons.trending_up_rounded;
      case FsRuleType.malus:
        return Icons.trending_down_rounded;
    }
  }
}
