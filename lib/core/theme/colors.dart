import 'package:flutter/material.dart';

class ColorPalette {
  // ===== UTILITY METHODS =====

  /// Method to get dynamic colors based on theme mode
  static Color getColor(
      Color darkModeColor, Color lightModeColor, ThemeMode themeMode) {
    return themeMode == ThemeMode.dark ? darkModeColor : lightModeColor;
  }

  // ===== PRIMARY APP THEME COLORS =====

  /// Main brand color - consistent across light and dark themes
  static Color primary(ThemeMode themeMode) => getColor(
      const Color.fromARGB(255, 196, 67, 67),
      const Color.fromARGB(255, 196, 67, 67),
      themeMode);

  /// Secondary brand color - lighter variations of primary
  static Color secondary(ThemeMode themeMode) => getColor(
      const Color.fromARGB(255, 242, 166, 166),
      const Color.fromARGB(255, 222, 146, 146),
      themeMode);

  /// Tertiary brand color - lightest variations for subtle elements
  static Color ternary(ThemeMode themeMode) => getColor(
      const Color.fromARGB(255, 255, 219, 219),
      const Color.fromARGB(255, 235, 199, 199),
      themeMode);

  /// Accent color for highlights and important elements
  static Color accent(ThemeMode themeMode) => getColor(
      const Color.fromARGB(255, 157, 49, 49),
      const Color.fromARGB(255, 196, 67, 67),
      themeMode);

  // ===== TEXT COLORS =====

  /// Primary text color - main content text
  static Color textPrimary(ThemeMode themeMode) => getColor(
      const Color(0xFFF6F6F6),
      const Color.fromARGB(255, 20, 20, 20),
      themeMode);

  /// Secondary text color - subtitles and less important text
  static Color textSecondary(ThemeMode themeMode) => getColor(
      const Color.fromARGB(255, 214, 214, 214),
      const Color.fromARGB(255, 47, 47, 47),
      themeMode);

  // ===== BACKGROUND COLORS =====

  /// Main background color for screens
  static Color bgColor(ThemeMode themeMode) => getColor(
      const Color.fromARGB(255, 11, 11, 13),
      const Color.fromARGB(255, 236, 229, 229),
      themeMode);

  /// Secondary background color for cards and containers
  static Color secondaryBgColor(ThemeMode themeMode) => getColor(
      const Color.fromARGB(255, 24, 26, 33),
      const Color.fromARGB(255, 243, 243, 243),
      themeMode);

  // ===== BORDER COLORS =====

  /// Standard border color for inputs and containers
  static Color borderColor(ThemeMode themeMode) =>
      getColor(const Color(0xFFD9D9D9), const Color(0xFFB9B9B9), themeMode);

  /// Border color for focused/active elements
  static const Color focusedBorder = Color.fromARGB(255, 196, 67, 67);

  // ===== SOCIAL AUTHENTICATION COLORS =====

  /// Google sign-in button gradient colors
  static const List<Color> googleGradientsBg = [
    Color.fromARGB(255, 187, 57, 57),
    Color.fromARGB(255, 226, 225, 119),
    Color.fromARGB(255, 83, 140, 183),
  ];

  /// Discord authentication button color
  static const Color discord = Color.fromARGB(255, 103, 125, 205);

  /// Apple authentication button color
  static const Color apple = Colors.black;

  /// Facebook authentication button color
  static const Color facebook = Color.fromARGB(255, 32, 71, 134);

  // ===== BUTTON STATE COLORS =====

  /// Disabled button color
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  // ===== STATUS & FEEDBACK COLORS =====

  /// Error states and validation failures
  static const Color error = Color(0xFFD32F2F);

  /// Success states and positive feedback
  static const Color success = Color(0xFF388E3C);

  /// Warning states and cautionary feedback
  static const Color warning = Color(0xFFF57C00);

  /// Informational states and neutral feedback
  static const Color info = Color.fromARGB(255, 135, 126, 209);

  /// Darker variant of info color
  static const Color infoDarker = Color.fromARGB(255, 113, 105, 174);

  // ===== NEUTRAL COLOR PALETTE =====

  /// Pure black variant
  static const Color black = Color(0xFF232323);

  /// Soft black for subtle contrast
  static const Color softBlack = Color.fromARGB(255, 59, 59, 59);

  /// Darker grey for secondary elements
  static const Color darkerGrey = Color.fromARGB(255, 91, 91, 91);

  /// Medium grey for borders and dividers
  static const Color darkGrey = Color(0xFF939393);

  /// Light grey for backgrounds
  static const Color grey = Color(0xFFE0E0E0);

  /// Very light grey for subtle backgrounds
  static const Color softGrey = Color(0xFFF4F4F4);

  /// Almost white grey
  static const Color lightGrey = Color(0xFFF9F9F9);

  /// Pure white
  static const Color white = Color(0xFFFFFFFF);

  // ===== SPECIAL FEATURE COLORS =====

  /// Dark green for specific features
  static const Color darkerGreen = Color.fromARGB(255, 28, 60, 49);

  /// Premium user indicator color
  static const Color premiumUser = Color.fromARGB(255, 197, 127, 6);

  // ===== GAME SPECIFIC COLORS =====

  /// Truth or Dare - Truth primary color
  static const Color truthPrimary = Color(0xFF00AEEF);

  /// Truth or Dare - Truth secondary color
  static const Color truthSecondary = Color(0xFF80D4F8);

  /// Truth or Dare - Dare primary color
  static const Color darePrimary = Color(0xFFED1C24);

  /// Truth or Dare - Dare secondary color
  static const Color dareSecondary = Color(0xFFF47A7E);

  // ===== FANTASERATA FLOATING BUTTON GRADIENTS =====

  /// Custom gradient collection for FantaSerata floating action button
  static const List<Color> fsGradients = [
    Color.fromARGB(255, 196, 67, 67),
    Color.fromARGB(255, 142, 40, 40),
    Color.fromARGB(255, 101, 18, 18),
  ];

  // ===== PREMIUM FEATURE GRADIENTS =====

  /// Premium feature gradient colors
  static const List<Color> premiumGradient = [
    Color.fromARGB(255, 197, 159, 21),
    Color.fromARGB(255, 219, 145, 34),
    Color.fromARGB(255, 192, 113, 33),
  ];

  /// Advertisement feature gradient colors
  static const List<Color> adsGradient = [
    Color(0xFF56ab2f),
    Color(0xFF2FAD6E),
    Color(0xFF00CCBB),
  ];

  // ===== NOTE GRADIENTS =====

  /// Gradient collection for notes - optimized for white text readability
  static List<LinearGradient> noteGradients = [
    // Deep blue to purple
    LinearGradient(
      colors: [
        const Color(0xFF3A1C71),
        const Color(0xFFD76D77),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // Dark teal to emerald
    LinearGradient(
      colors: [
        const Color(0xFF1A2980),
        const Color(0xFF26D0CE),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // Dark pink to orange
    LinearGradient(
      colors: [
        const Color(0xFF833ab4),
        const Color(0xFFfd1d1d),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // Dark purple to pink
    LinearGradient(
      colors: [
        const Color(0xFF6A11CB),
        const Color(0xFF2575FC),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // Deep orange to amber
    LinearGradient(
      colors: [
        const Color(0xFFEB3349),
        const Color(0xFFF45C43),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // Dark green to light green
    LinearGradient(
      colors: [
        const Color(0xFF134E5E),
        const Color(0xFF71B280),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // Indigo to cyan
    LinearGradient(
      colors: [
        const Color(0xFF0F2027),
        const Color(0xFF203A43),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // Dark magenta to purple
    LinearGradient(
      colors: [
        const Color(0xFF614385),
        const Color(0xFF516395),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];

  // ===== DAILY CHALLENGE GRADIENTS =====

  /// Gradient collection for daily challenge cards (autumn vibes 🍂)
  static List<List<Color>> challengeGradients = [
    [
      const Color(0xFFEF6C00), // arancio bruciato
      const Color(0xFFD84315), // arancio scuro tendente al rame
    ],
    [
      const Color(0xFF8E3200), // marrone caldo / terra bruciata
      const Color(0xFF5D1F00), // marrone profondo
    ],
    [
      const Color(0xFF4E342E), // marrone intenso
      const Color(0xFF260E04), // quasi nero con riflessi bruno
    ],
  ];

  /// Differnet Gradient collection for daily challenge cards
  // static List<List<Color>> challengeGradients = [
  //   [
  //     const Color(0xFF134E5E),
  //     const Color(0xFF71B280),
  //   ],
  //   [
  //     const Color(0xFFFF8008),
  //     const Color.fromARGB(255, 231, 180, 51),
  //   ],
  //   [
  //     const Color(0xFF614385),
  //     const Color(0xFFD76D77),
  //   ],
  // ];

  // ===== GRADIENT UTILITY METHODS =====

  /// Get a challenge gradient by index
  static List<Color> getChallengeGradient(int index) {
    return challengeGradients[index % challengeGradients.length];
  }

  /// Get a note gradient based on a string ID for consistency
  static LinearGradient getGradientFromId(String id) {
    final index = id.hashCode.abs() % noteGradients.length;
    return noteGradients[index];
  }

  /// Get premium feature gradient
  static LinearGradient getPremiumGradient() => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: premiumGradient,
        stops: [0.0, 0.5, 1.0],
      );

  /// Get advertisement feature gradient
  static LinearGradient getAdsGradient() => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: adsGradient,
        stops: [0.0, 0.5, 1.0],
      );
}
