import '../../../domain/entities/partner/partner_destination.dart';
import '../rule_model/rule_model.dart';
import 'partner_round_model.dart';

class PartnerDestinationModel extends PartnerDestination {
  const PartnerDestinationModel({
    required super.id,
    required super.name,
    super.description,
    required super.rules,
    super.imageUrl,
    super.activeRound,
    super.requiresPassword,
  });

  factory PartnerDestinationModel.fromJson(Map<String, dynamic> json) {
    final rawRules = json['rules'] as List<dynamic>? ?? [];
    final rulesList = rawRules
        .map((e) => RuleModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final activeRoundRaw = json['active_round'] ?? json['activeRound'];
    final activeRoundModel = activeRoundRaw != null
        ? PartnerRoundModel.fromJson(activeRoundRaw as Map<String, dynamic>)
        : null;

    return PartnerDestinationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      rules: rulesList,
      imageUrl: (json['image_url'] ?? json['imageUrl']) as String?,
      activeRound: activeRoundModel,
      requiresPassword:
          (json['requires_password'] ?? json['requiresPassword']) as bool? ??
              false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'rules': rules.map((rule) => (rule as RuleModel).toJson()).toList(),
      'image_url': imageUrl,
      'active_round': activeRound != null
          ? (activeRound as PartnerRoundModel).toJson()
          : null,
      'requires_password': requiresPassword,
    };
  }
}
