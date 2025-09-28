import 'package:fantavacanze_official/core/cubits/app_fs_league/app_fs_league_cubit.dart';
import 'package:fantavacanze_official/core/cubits/floating_button_animation/floating_button_animation_cubit.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/init_dependencies/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnimatedFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onShow;
  final void Function(void Function())? onRegisterShowCallback;

  const AnimatedFloatingActionButton({
    super.key,
    this.onPressed,
    this.onShow,
    this.onRegisterShowCallback,
  });

  @override
  State<AnimatedFloatingActionButton> createState() =>
      _AnimatedFloatingActionButtonState();
}

class _AnimatedFloatingActionButtonState
    extends State<AnimatedFloatingActionButton> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _slideController;
  late Animation<double> _widthAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _iconOpacityAnimation;
  late Animation<double> _inviteOpacityAnimation;
  late Animation<double> _borderRadiusAnimation;
  late Animation<double> _slideAnimation;

  bool _isExpanded = true;
  bool _isHidden = false;
  late FloatingButtonAnimationCubit _animationCubit;

  @override
  void initState() {
    super.initState();

    _animationCubit = serviceLocator<FloatingButtonAnimationCubit>();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Animazione per la larghezza del button
    _widthAnimation = Tween<double>(
      begin: 160.0,
      end: 80.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOutCubic),
    ));

    // Animazione per nascondere/mostrare il button da destra
    _slideAnimation = Tween<double>(
      begin: 0.0, // Posizione normale
      end:
          90.0, // Nascosto di più (solo 10px visibili di un button da 80px) - aumentato da 70 a 90
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOutCubic,
    ));

    // Animazione per l'opacità del testo "Fanta Serata"
    _textOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));

    // Animazione per l'opacità delle lettere "FS"
    _iconOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    ));

    // Animazione per l'opacità del testo "Prova Ora!"
    _inviteOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    ));

    // Animazione per il border radius
    _borderRadiusAnimation = Tween<double>(
      begin: 28.0,
      end: 28.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    // Check if animation was already played and restore visibility state
    if (_animationCubit.hasAnimationPlayed) {
      // Skip animation and go directly to collapsed state
      _isExpanded = false;
      _controller.value = 1.0; // Set to end state
    } else {
      // Avvia l'animazione dopo 5 secondi solo se non è mai stata giocata
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && !_animationCubit.hasAnimationPlayed) {
          _startCollapseAnimation();
        }
      });
    }

    // Restore visibility state from cubit
    if (_animationCubit.isHidden) {
      _isHidden = true;
      _slideController.value = 1.0; // Set to hidden state
    }

    // Registra il callback per mostrare il button dal parent
    widget.onRegisterShowCallback?.call(_showButton);
  }

  void _startCollapseAnimation() {
    setState(() {
      _isExpanded = false;
    });
    _controller.forward();
    // Mark animation as played
    _animationCubit.markAnimationAsPlayed();
  }

  void _hideButton() {
    setState(() {
      _isHidden = true;
    });
    _slideController.forward();
    // Update cubit state
    _animationCubit.hideButton();
  }

  void _showButton() {
    setState(() {
      _isHidden = false;
    });
    _slideController.reverse();
    // Update cubit state
    _animationCubit.showButton();
    // Notifica il parent che il button è stato mostrato
    widget.onShow?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _slideController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: GestureDetector(
            onTap: () {
              if (_isHidden) {
                // Se nascosto, cliccando sulla parte visibile lo mostra
                _showButton();
              } else {
                // Se visibile, esegue l'azione normale
                widget.onPressed?.call();
              }
            },
            onPanStart: (DragStartDetails details) {
              // Inizializza il drag
            },
            onPanUpdate: (DragUpdateDetails details) {
              // Durante il drag, non fare nulla per evitare conflitti
            },
            onPanEnd: (DragEndDetails details) {
              // Gestisci il drag finale
              if (details.velocity.pixelsPerSecond.dx.abs() > 300) {
                // Solo se la velocità è sufficiente
                if (details.velocity.pixelsPerSecond.dx > 0 && !_isHidden) {
                  // Swipe verso destra = nasconde
                  _hideButton();
                } else if (details.velocity.pixelsPerSecond.dx < 0 &&
                    _isHidden) {
                  // Swipe verso sinistra = mostra
                  _showButton();
                }
              }
            },
            child: Container(
              width: _widthAnimation.value,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: ColorPalette.fsGradients,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.circular(_borderRadiusAnimation.value),
                boxShadow: [
                  BoxShadow(
                    color: ColorPalette.fsGradients[0].withValues(alpha: 0.3),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: ColorPalette.fsGradients[0].withValues(alpha: 0.1),
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: BlocBuilder<AppFsLeagueCubit, AppFsLeagueState>(
                builder: (context, state) {
                  return Center(
                    child: SizedBox(
                      width: _widthAnimation.value - 16,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Testo "FantaSerata" - visibile all'inizio
                          if (_isExpanded || _textOpacityAnimation.value > 0)
                            Opacity(
                              opacity: _textOpacityAnimation.value,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    state is AppFsLeagueExists
                                        ? "Entra nella tua"
                                        : "Gioca ora al",
                                    style:
                                        context.textTheme.labelSmall!.copyWith(
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    "Fanta Serata",
                                    style: const TextStyle(
                                      fontFamily: "Falcon Sport One",
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                          // Layout "FS" + "Prova Ora!" - visibile alla fine
                          Opacity(
                            opacity: _iconOpacityAnimation.value,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Testo "FS"
                                Text(
                                  "FS",
                                  style: const TextStyle(
                                    fontFamily: "Falcon Sport One",
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                Opacity(
                                  opacity: _inviteOpacityAnimation.value,
                                  child: Text(
                                    state is AppFsLeagueExists
                                        ? "Entra!"
                                        : "Prova Ora!",
                                    style:
                                        context.textTheme.labelSmall!.copyWith(
                                      fontSize: 9,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
