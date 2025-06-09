import 'package:fantavacanze_official/features/games/domain/entities/never_have_i_ever_question.dart';

class NeverHaveIEverQuestionModel extends NeverHaveIEverQuestion {
  const NeverHaveIEverQuestionModel({
    required super.id,
    required super.content,
  });

  factory NeverHaveIEverQuestionModel.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['id'];

    String idString;
    if (idValue is int) {
      idString = idValue.toString();
    } else if (idValue is String) {
      idString = idValue;
    } else {
      idString = '';
    }

    return NeverHaveIEverQuestionModel(
      id: idString,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
    };
  }
}
