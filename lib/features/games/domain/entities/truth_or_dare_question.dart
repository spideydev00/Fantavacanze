import 'package:equatable/equatable.dart';

enum TruthOrDareCardType { truth, dare }

class TruthOrDareQuestion extends Equatable {
  final String id;
  final String content;
  final TruthOrDareCardType type;

  const TruthOrDareQuestion({
    required this.id,
    required this.content,
    required this.type,
  });

  @override
  List<Object?> get props => [id, content, type];
}
