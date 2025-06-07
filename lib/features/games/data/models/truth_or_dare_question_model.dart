import 'package:fantavacanze_official/features/games/domain/entities/truth_or_dare_question.dart';

class TruthOrDareQuestionModel extends TruthOrDareQuestion {
  const TruthOrDareQuestionModel({
    required super.id,
    required super.content,
    required super.type,
  });

  factory TruthOrDareQuestionModel.fromJson(Map<String, dynamic> map) {
    return TruthOrDareQuestionModel(
      id: (map['id'] as int).toString(), // Assuming id is BIGINT
      content: map['content'] as String,
      type: (map['type'] as String) == 'truth'
          ? TruthOrDareCardType.truth
          : TruthOrDareCardType.dare,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': int.parse(id),
      'content': content,
      'type': type == TruthOrDareCardType.truth ? 'truth' : 'dare',
    };
  }
}
