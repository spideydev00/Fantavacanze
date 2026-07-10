import '../../../domain/entities/partner/partner_round.dart';

class PartnerRoundModel extends PartnerRound {
  const PartnerRoundModel({
    required super.id,
    required super.name,
    required super.startDate,
    super.endDate,
    super.requiresPassword,
  });

  factory PartnerRoundModel.fromJson(Map<String, dynamic> json) {
    final String id = json['id'] as String;
    final String name = json['name'] as String;

    final String startDateStr =
        (json['start_date'] ?? json['startDate']) as String;
    final String? endDateStr = (json['end_date'] ?? json['endDate']) as String?;

    return PartnerRoundModel(
      id: id,
      name: name,
      startDate: DateTime.parse(startDateStr),
      endDate: endDateStr != null ? DateTime.parse(endDateStr) : null,
      requiresPassword:
          (json['requires_password'] ?? json['requiresPassword']) as bool? ??
              false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'requires_password': requiresPassword,
    };
  }
}
