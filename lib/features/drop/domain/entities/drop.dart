/// Un drop di merchandising annunciato in-app.
class Drop {
  static const imageCount = 3;

  final String code;
  final List<String> imageUrls;
  final List<String> imageDescriptions;
  final String ctaLabel;
  final String ctaUrl;

  Drop({
    required this.code,
    required List<String> imageUrls,
    required List<String> imageDescriptions,
    required this.ctaLabel,
    required this.ctaUrl,
  })  : imageUrls = List.unmodifiable(imageUrls),
        imageDescriptions = List.unmodifiable(imageDescriptions);
}

/// Il drop attivo, se c'è, e l'ultimo che questo utente ha visto.
class DropCheck {
  final Drop? drop;
  final String? lastSeenDrop;

  const DropCheck({this.drop, this.lastSeenDrop});
}
