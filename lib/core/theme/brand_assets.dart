/// Loghi partner, indicizzati per slug, con variante per tema (dark/light).
class BrandAssets {
  const BrandAssets._();

  static const Map<String, ({String dark, String light})> _logos = {
    'invibe': (
      dark: 'assets/images/logos/invibe.png',
      light: 'assets/images/logos/invibe-naked.png',
    ),
    'b-eazy': (
      dark: 'assets/images/logos/b-eazy.png',
      light: 'assets/images/logos/b-eazy-naked.png',
    ),
  };

  /// Path del logo per [slug] e tema. Null se slug null o sconosciuto.
  static String? logoFor(String? slug, {required bool isDark}) {
    if (slug == null) return null;
    final entry = _logos[slug];
    if (entry == null) return null;
    return isDark ? entry.dark : entry.light;
  }
}
