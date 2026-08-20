/// Un drop di merchandising annunciato in-app.
class Drop {
  final String code;
  final String imageUrl;
  final String ctaLabel;
  final String ctaUrl;

  const Drop({
    required this.code,
    required this.imageUrl,
    required this.ctaLabel,
    required this.ctaUrl,
  });
}

/// Il drop attivo, se c'è, e l'ultimo che questo utente ha visto.
class DropCheck {
  final Drop? drop;
  final String? lastSeenDrop;

  const DropCheck({this.drop, this.lastSeenDrop});
}
