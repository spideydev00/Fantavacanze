import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

enum GameState {
  interview,
  firstPlayerChoice,
  firstPlayerResult,
  secondPlayerChoice,
  revealButton,
  calculating,
  finalResult,
}

enum Choice { smash, pass }

class SmashOrPass extends StatefulWidget {
  const SmashOrPass({super.key});

  @override
  State<SmashOrPass> createState() => _SmashOrPassState();
}

class _SmashOrPassState extends State<SmashOrPass>
    with TickerProviderStateMixin {
  GameState _gameState = GameState.interview;
  Choice? _firstPlayerChoice;
  Choice? _secondPlayerChoice;

  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _loadingController;
  late AnimationController _resultController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _loadingAnimation;
  late Animation<double> _resultScaleAnimation;
  late Animation<double> _resultOpacityAnimation;

  String _loadingText = "Calcolando il risultato...";
  bool _showAlternateText = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Slide animation for choice buttons
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    // Scale animation for result display
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.bounceOut,
    ));

    // Rotation animation for cards
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    // Loading animation
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_loadingController);

    // Final result animations
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _resultScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultController,
      curve: Curves.elasticOut,
    ));
    _resultOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    ));

    // Start with slide animation
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _loadingController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  void _makeChoice(Choice choice) {
    setState(() {
      if (_gameState == GameState.firstPlayerChoice) {
        _firstPlayerChoice = choice;
        _gameState = GameState.firstPlayerResult;
        _scaleController.forward();
      } else if (_gameState == GameState.secondPlayerChoice) {
        _secondPlayerChoice = choice;
        _gameState = GameState.revealButton;
      }
    });
  }

  void _skipToNext() {
    if (_gameState == GameState.firstPlayerResult) {
      setState(() {
        _gameState = GameState.secondPlayerChoice;
      });
      _scaleController.reset();
    }
  }

  void _revealResult() {
    setState(() {
      _gameState = GameState.calculating;
    });

    // Start loading animation with text alternation
    _loadingController.repeat();
    _startTextAlternation();

    // After 4 seconds, show final result
    Future.delayed(const Duration(seconds: 4), () {
      _loadingController.stop();
      setState(() {
        _gameState = GameState.finalResult;
      });
      _resultController.forward();
    });
  }

  void _startTextAlternation() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_gameState == GameState.calculating) {
        setState(() {
          _showAlternateText = !_showAlternateText;
          _loadingText = _showAlternateText
              ? "Scarica l'app e seguici..."
              : "Calcolando il risultato...";
        });
        _startTextAlternation(); // Continue alternating
      }
    });
  }

  void _resetGame() {
    setState(() {
      _gameState = GameState.interview;
      _firstPlayerChoice = null;
      _secondPlayerChoice = null;
      _showAlternateText = false;
    });

    // Reset all animations
    _scaleController.reset();
    _rotationController.reset();
    _loadingController.reset();
    _resultController.reset();
    _slideController.forward();
  }

  bool get _isMatch {
    return _firstPlayerChoice == Choice.smash &&
        _secondPlayerChoice == Choice.smash;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: context.bgColor,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(ThemeSizes.lg),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              context.textPrimaryColor.withValues(alpha: 0.5),
              context.textPrimaryColor.withValues(alpha: 0.2),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: _resetGame,
          icon: Icon(
            Icons.refresh,
            color: context.textPrimaryColor,
            size: 26,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_gameState) {
      case GameState.interview:
        return _buildInterviewScreen();
      case GameState.firstPlayerChoice:
        return _buildChoiceScreen("Primo intervistato", "Fai la tua scelta!");
      case GameState.firstPlayerResult:
        return _buildResultScreen(_firstPlayerChoice!);
      case GameState.secondPlayerChoice:
        return _buildChoiceScreen("Secondo intervistato", "È il tuo turno!");
      case GameState.revealButton:
        return _buildRevealScreen();
      case GameState.calculating:
        return _buildCalculatingScreen();
      case GameState.finalResult:
        return _buildFinalResultScreen();
    }
  }

  Widget _buildInterviewScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/logos/logo-smash-or-pass.png",
            height: 200,
          ),
          SizedBox(height: 40),
          _ModernButton(
            text: 'Inizia',
            onTap: () {
              setState(() {
                _gameState = GameState.firstPlayerChoice;
              });
            },
            gradient: [
              context.primaryColor,
              context.primaryColor.withValues(
                alpha: 0.7,
              )
            ],
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildChoiceScreen(String player, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Scegli un'opzione...",
            style: context.textTheme.titleLarge,
          ),
          SizedBox(height: 40),
          SlideTransition(
            position: _slideAnimation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ChoiceCard(
                  choice: Choice.smash,
                  onTap: () => _makeChoice(Choice.smash),
                  rotationAnimation: _rotationAnimation,
                  rotationController: _rotationController,
                ),
                _ChoiceCard(
                  choice: Choice.pass,
                  onTap: () => _makeChoice(Choice.pass),
                  rotationAnimation: _rotationAnimation,
                  rotationController: _rotationController,
                ),
              ],
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildResultScreen(Choice choice) {
    final bool isSmash = choice == Choice.smash;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(ThemeSizes.xl),
              margin: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSmash
                      ? [ColorPalette.success, const Color(0xFF4CAF50)]
                      : [ColorPalette.error, const Color(0xFFE57373)],
                ),
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusXlg),
                boxShadow: [
                  BoxShadow(
                    color: (isSmash ? ColorPalette.success : ColorPalette.error)
                        .withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                children: [
                  isSmash
                      ? Image.asset(
                          "assets/images/icons/homepage_icons/smash-illustration.png",
                          height: 200,
                        )
                      : Image.asset(
                          "assets/images/icons/homepage_icons/pass-illustration.png",
                          height: 200,
                        ),
                  const SizedBox(height: ThemeSizes.md),
                  Text(
                    isSmash ? "It's a smash!" : "It's a pass!",
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: ColorPalette.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: ThemeSizes.xxl),
          _ModernButton(
            text: 'Continua',
            onTap: _skipToNext,
            gradient: isSmash
                ? [
                    ColorPalette.success,
                    ColorPalette.darkerGreen,
                  ]
                : [
                    ColorPalette.darePrimary,
                    ColorPalette.darePrimary.withValues(alpha: 0.7)
                  ],
            textColor: ColorPalette.white,
          ),
        ],
      ),
    );
  }

  Widget _buildRevealScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeSizes.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Momento della verità!',
              textAlign: TextAlign.center,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimaryColor,
              ),
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              'Entrambe le scelte sono state fatte...',
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: ThemeSizes.xl),
            _ModernButton(
              text: 'Rivela',
              onTap: _revealResult,
              gradient: [
                context.primaryColor,
                context.primaryColor.withValues(alpha: 0.7),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _loadingAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    context.primaryColor,
                    context.secondaryColor,
                    ColorPalette.premiumUser,
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite,
                  size: 60,
                  color: ColorPalette.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: ThemeSizes.xl),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _loadingText,
              key: ValueKey(_loadingText),
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalResultScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _resultScaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(ThemeSizes.xl),
              margin: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isMatch
                      ? [
                          const Color(0xFF4CAF50),
                          const Color(0xFF8BC34A)
                        ] // Verde per match
                      : [
                          ColorPalette.error.withValues(alpha: 0.2),
                          ColorPalette.error.withValues(alpha: 0.5),
                          ColorPalette.error,
                        ], // Rosso per no match
                ),
                borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusXlg),
                boxShadow: [
                  BoxShadow(
                    color: (_isMatch
                            ? const Color(0xFF4CAF50) // Verde per match
                            : const Color(0xFFF44336)) // Rosso per no match
                        .withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _isMatch
                      ? SvgPicture.asset(
                          "assets/images/icons/homepage_icons/love-key-icon.svg",
                        )
                      : SvgPicture.asset(
                          "assets/images/icons/homepage_icons/broken-heart.svg",
                        ),
                  const SizedBox(height: ThemeSizes.lg),
                  FadeTransition(
                    opacity: _resultOpacityAnimation,
                    child: Text(
                      _isMatch ? "It's a match!" : "Non è sbocciato l'amore!",
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: ColorPalette.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: ThemeSizes.md),
                  FadeTransition(
                    opacity: _resultOpacityAnimation,
                    child: Text(
                      _isMatch
                          ? "Pronti per smashare davvero!"
                          : "Non tutti gli amori sono ricambiati...",
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: ColorPalette.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: ThemeSizes.xl),
          FadeTransition(
            opacity: _resultOpacityAnimation,
            child: _ModernButton(
              text: 'Gioca Ancora',
              onTap: _resetGame,
              gradient: _isMatch
                  ? [
                      ColorPalette.success,
                      ColorPalette.darkerGreen,
                    ]
                  : [
                      context.primaryColor,
                      context.primaryColor.withValues(alpha: 0.7),
                    ],
              textColor: ColorPalette.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatefulWidget {
  final Choice choice;
  final VoidCallback onTap;
  final Animation<double> rotationAnimation;
  final AnimationController rotationController;

  const _ChoiceCard({
    required this.choice,
    required this.onTap,
    required this.rotationAnimation,
    required this.rotationController,
  });

  @override
  State<_ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<_ChoiceCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isSmash = widget.choice == Choice.smash;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        widget.rotationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.rotationController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        widget.rotationController.reverse();
      },
      child: AnimatedBuilder(
        animation: widget.rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: widget.rotationAnimation.value * (isSmash ? 1 : -1),
            child: AnimatedScale(
              scale: _isPressed ? 0.95 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                width: 140,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isSmash
                        ? [
                            ColorPalette.success,
                            ColorPalette.success.withValues(alpha: 0.7)
                          ]
                        : [
                            ColorPalette.error,
                            ColorPalette.error.withValues(alpha: 0.7)
                          ],
                  ),
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusLg),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isSmash ? ColorPalette.success : ColorPalette.error)
                              .withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSmash ? Icons.favorite : Icons.close,
                      size: 60,
                      color: ColorPalette.white,
                    ),
                    const SizedBox(height: ThemeSizes.md),
                    Text(
                      isSmash ? 'SMASH' : 'PASS',
                      style: context.textTheme.titleLarge?.copyWith(
                        color: ColorPalette.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final List<Color> gradient;
  final Color? textColor;

  const _ModernButton({
    required this.text,
    required this.onTap,
    required this.gradient,
    this.textColor,
  });

  @override
  State<_ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<_ModernButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 250,
          padding: const EdgeInsets.symmetric(
            vertical: ThemeSizes.sm,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: widget.gradient),
            borderRadius: BorderRadius.circular(ThemeSizes.buttonRadius),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 10),
              Text(
                widget.text,
                style: const TextStyle(
                  fontFamily: "Falcon Sport One",
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 5),
              Icon(
                Icons.play_arrow_rounded,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
