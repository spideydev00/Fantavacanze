import 'package:fantavacanze_official/features/games/domain/entities/truth_or_dare_question.dart';

class TruthOrDareQuestionModel extends TruthOrDareQuestion {
  const TruthOrDareQuestionModel({
    required super.id,
    required super.content,
    required super.type,
    super.difficulty,
    super.author,
  });

  factory TruthOrDareQuestionModel.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['id'];

    String idString;
    if (idValue is int) {
      idString = idValue.toString();
    } else if (idValue is String) {
      idString = idValue;
    } else {
      idString = '';
    }

    final content = json['content'] as String;
    final typeString = json['type'] as String?;
    final difficulty = json['difficulty'] as String?;
    final author = json['author'] as String?;

    return TruthOrDareQuestionModel(
      id: idString,
      content: content,
      type: _cardTypeFromString(typeString),
      difficulty: difficulty,
      author: author,
    );
  }

  static TruthOrDareCardType _cardTypeFromString(String? typeStr) {
    if (typeStr == null) {
      return TruthOrDareCardType.unknown;
    }
    // Compare with the exact strings used in your database ENUM/values
    if (typeStr == 'Verità') {
      return TruthOrDareCardType.truth;
    } else if (typeStr == 'Obbligo') {
      return TruthOrDareCardType.dare;
    }

    return TruthOrDareCardType.unknown;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.toString().split('.').last,
      'difficulty': difficulty,
      'author': author,
    };
  }
}
