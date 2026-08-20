import 'package:fantavacanze_official/features/drop/domain/entities/drop.dart';

class DropModel extends Drop {
  DropModel({
    required super.code,
    required super.imageUrls,
    required super.imageDescriptions,
    required super.ctaLabel,
    required super.ctaUrl,
  });

  factory DropModel.fromJson(Map<String, dynamic> json) {
    final rawImageUrls = json['image_urls'];
    if (rawImageUrls is! List<dynamic> ||
        rawImageUrls.length != Drop.imageCount ||
        rawImageUrls.any((url) => url is! String || url.isEmpty)) {
      throw const FormatException(
          'Il drop deve contenere tre immagini valide.');
    }

    final imageUrls = rawImageUrls.cast<String>().toList();
    if (imageUrls.toSet().length != Drop.imageCount) {
      throw const FormatException(
          'Le immagini del drop devono essere distinte.');
    }

    final rawDescriptions = json['image_descriptions'];
    if (rawDescriptions is! List<dynamic> ||
        rawDescriptions.length != Drop.imageCount ||
        rawDescriptions.any(
          (description) => description is! String || description.trim().isEmpty,
        )) {
      throw const FormatException(
        'Il drop deve descrivere tutte e tre le immagini.',
      );
    }

    return DropModel(
      code: json['code'] as String,
      imageUrls: imageUrls,
      imageDescriptions: rawDescriptions.cast<String>().toList(),
      ctaLabel: json['cta_label'] as String,
      ctaUrl: json['cta_url'] as String,
    );
  }
}
