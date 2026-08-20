import 'package:fantavacanze_official/features/drop/domain/entities/drop.dart';

class DropModel extends Drop {
  const DropModel({
    required super.code,
    required super.imageUrl,
    required super.ctaLabel,
    required super.ctaUrl,
  });

  factory DropModel.fromJson(Map<String, dynamic> json) {
    return DropModel(
      code: json['code'] as String,
      imageUrl: json['image_url'] as String,
      ctaLabel: json['cta_label'] as String,
      ctaUrl: json['cta_url'] as String,
    );
  }
}
