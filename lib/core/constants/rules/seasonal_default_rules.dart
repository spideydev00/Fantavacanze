import 'package:fantavacanze_official/core/constants/rules/default_rule.dart';
import 'package:fantavacanze_official/core/constants/rules/female_rules_summer.dart';
import 'package:fantavacanze_official/core/constants/rules/female_rules_winter.dart';
import 'package:fantavacanze_official/core/constants/rules/male_rules_summer.dart';
import 'package:fantavacanze_official/core/constants/rules/male_rules_winter.dart';
import 'package:fantavacanze_official/core/constants/rules/mixed_rules_summer.dart';
import 'package:fantavacanze_official/core/constants/rules/mixed_rules_winter.dart';

// Stagione estiva: aprile-settembre (mesi 4-9). Negli altri mesi e' inverno.
bool isSummerSeason([DateTime? now]) {
  final m = (now ?? DateTime.now()).month;
  return m >= 4 && m <= 9;
}

// Restituisce le regole di default in base al mode della lega e alla stagione corrente.
// Per mode == 'custom' ritorna lista vuota. Per mode sconosciuti, fallback a mixed.
List<DefaultRule> defaultRulesFor(String mode, {DateTime? now}) {
  if (mode == 'custom') return const [];
  final summer = isSummerSeason(now);
  switch (mode) {
    case 'male':
      return summer ? maleRulesSummer : maleRulesWinter;
    case 'female':
      return summer ? femaleRulesSummer : femaleRulesWinter;
    case 'mixed':
      return summer ? mixedRulesSummer : mixedRulesWinter;
    default:
      return summer ? mixedRulesSummer : mixedRulesWinter;
  }
}
