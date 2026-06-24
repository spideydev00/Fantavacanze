import '../../../domain/entities/partner/partner.dart';

class PartnerModel extends Partner {
  const PartnerModel({
    required super.slug,
    required super.name,
    required super.kind,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      slug: json['slug'] as String,
      name: json['name'] as String,
      kind: json['kind'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'name': name,
      'kind': kind,
    };
  }
}
