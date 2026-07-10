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
    super.rounds,
    super.requiresPassword,
  });

  factory PartnerDestinationModel.fromJson(Map<String, dynamic> json) {
    final rawRules = json['rules'] as List<dynamic>? ?? [];
    final rulesList = rawRules
        .map((e) => RuleModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final rawRounds = json['rounds'] as List<dynamic>?;
    final activeRoundRaw = json['active_round'] ?? json['activeRound'];
    final roundsList = rawRounds != null
        ? rawRounds
            .map(
              (e) => PartnerRoundModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList()
        : [
            if (activeRoundRaw != null)
              PartnerRoundModel.fromJson(
                Map<String, dynamic>.from(activeRoundRaw as Map),
              ),
          ];

    return PartnerDestinationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      rules: rulesList,
      imageUrl: (json['image_url'] ?? json['imageUrl']) as String?,
      rounds: roundsList,
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
      'rounds':
          rounds.map((round) => (round as PartnerRoundModel).toJson()).toList(),
      'requires_password': requiresPassword,
    };
  }
}
