import 'package:fantavacanze_official/core/constants/rules/default_rule.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';

const List<DefaultRule> mixedRulesSummer = [
  DefaultRule(
    id: 1,
    name: "Obbliga il barista a fare un drink inventato da te (robe assurde).",
    type: RuleType.bonus,
    points: 3,
  ),
  DefaultRule(
    id: 2,
    name: "Contratta all'eccesso con un venditore ambulante.",
    type: RuleType.bonus,
    points: 3,
  ),
  DefaultRule(
    id: 3,
    name:
        "Fai credere di essere una celebrità/influencer e ricevi un beneficio in cambio.",
    type: RuleType.bonus,
    points: 6,
  ),
  DefaultRule(
    id: 4,
    name: "Scambiati l'IG o il numero di telefono con una ragazza.",
    type: RuleType.bonus,
    points: 3,
  ),
  DefaultRule(
    id: 5,
    name: "Offri un giro di shot alla tua compagnia.",
    type: RuleType.bonus,
    points: 4,
  ),
  DefaultRule(
    id: 6,
    name: "Limone duro con una persona conosciuta il giorno stesso.",
    type: RuleType.bonus,
    points: 6,
  ),
  DefaultRule(
    id: 7,
    name: "Preliminari? (fatti).",
    type: RuleType.bonus,
    points: 10,
  ),
  DefaultRule(
    id: 8,
    name: "Fai un tuffo notturno in mare o in piscina.",
    type: RuleType.bonus,
    points: 5,
  ),
  DefaultRule(
    id: 9,
    name: "\"Passa la notte\" con una persona.",
    type: RuleType.bonus,
    points: 12,
  ),
  DefaultRule(
    id: 10,
    name: "Passa tutta la serata con gli occhiali da sole.",
    type: RuleType.bonus,
    points: 2,
  ),
  DefaultRule(
    id: 11,
    name: "Preliminari (ricevuti).",
    type: RuleType.bonus,
    points: 10,
  ),
  DefaultRule(
    id: 12,
    name:
        "Fai una foto con uno sconosciuto e tienila come blocco schermo per tutto il giorno.",
    type: RuleType.bonus,
    points: 3,
  ),
  DefaultRule(
    id: 13,
    name: "Fallo con almeno due persone in contemporanea.",
    type: RuleType.bonus,
    points: 20,
  ),
  DefaultRule(
    id: 14,
    name: "Scrocca una sigaretta ad una persona sconosciuta.",
    type: RuleType.bonus,
    points: 2,
  ),
  DefaultRule(
    id: 15,
    name: "Partecipa ad un boat party/pool party.",
    type: RuleType.bonus,
    points: 3,
  ),
  DefaultRule(
    id: 16,
    name: "Fingiti un fotografo o pr per rimorchiare e renditi credibile.",
    type: RuleType.bonus,
    points: 6,
  ),
  DefaultRule(
    id: 17,
    name: "Bacio a tre (italian idol).",
    type: RuleType.bonus,
    points: 8,
  ),
  DefaultRule(
    id: 18,
    name: "Fai mettere la canzone scelta da te al DJ.",
    type: RuleType.bonus,
    points: 5,
  ),
  DefaultRule(
    id: 19,
    name: "Scegli una persona e fagli un complimento molto esagerato.",
    type: RuleType.bonus,
    points: 5,
  ),

  // Malus
  DefaultRule(
    id: 20,
    name: "Perdi portafoglio, telefono o documenti.",
    type: RuleType.malus,
    points: -3,
  ),
  DefaultRule(
    id: 21,
    name: "Prendi un palo (capita anche ai migliori).",
    type: RuleType.malus,
    points: -0.5,
  ),
  DefaultRule(
    id: 22,
    name: "Rompi un oggetto nell'alloggio.",
    type: RuleType.malus,
    points: -2,
  ),
  DefaultRule(
    id: 23,
    name: "Litighi con un estraneo o ti fai buttare fuori.",
    type: RuleType.malus,
    points: -8,
  ),
  DefaultRule(
    id: 24,
    name: "Versi accidentalmente una bevanda addosso a qualcuno.",
    type: RuleType.malus,
    points: -4,
  ),
  DefaultRule(
    id: 25,
    name: "Perdi le chiavi della stanza.",
    type: RuleType.malus,
    points: -5,
  ),
  DefaultRule(
    id: 26,
    name: "Piangi in discoteca per un crollo emotivo alcolico.",
    type: RuleType.malus,
    points: -5,
  ),
  DefaultRule(
    id: 27,
    name: "Litighi preso dell'alcool con qualcuno del gruppo.",
    type: RuleType.malus,
    points: -8,
  ),
  DefaultRule(
    id: 28,
    name: "Ti addormenti prima delle 24.",
    type: RuleType.malus,
    points: -7,
  ),
  DefaultRule(
    id: 29,
    name:
        "Dimentichi di portare un oggetto utile per il gruppo (es: crema solare).",
    type: RuleType.malus,
    points: -3,
  ),
  DefaultRule(
    id: 30,
    name: "Un evento inaspettato fa floppare \"la nottata d'amore\".",
    type: RuleType.malus,
    points: -5,
  ),
  DefaultRule(
    id: 31,
    name: "Rifiuti una persona che ci prova spudoratamente (vola basso).",
    type: RuleType.malus,
    points: -4,
  ),
  DefaultRule(
    id: 32,
    name: "Bevi solo acqua per tutto il giorno.",
    type: RuleType.malus,
    points: -5,
  ),
  DefaultRule(
    id: 33,
    name: "Vomiti tutto.",
    type: RuleType.malus,
    points: -8,
  ),
  DefaultRule(
    id: 34,
    name: "Non hai messo nessuna storia taggando @fantavacanze",
    type: RuleType.malus,
    points: -10,
  ),
];
