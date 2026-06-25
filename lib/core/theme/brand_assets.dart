class BrandAssets {
  const BrandAssets._();

  static const Map<String, String> _logos = {};

  static String? logoFor(String? slug) {
    return slug == null ? null : _logos[slug];
  }
}
