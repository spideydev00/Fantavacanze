import 'package:equatable/equatable.dart';

enum TruthOrDareCardType {
  truth,
  dare,
  unknown, // Optional: for fallback
}

class TruthOrDareQuestion extends Equatable {
  final String id;
  final String content;
  final TruthOrDareCardType type;
  final String? difficulty; // e.g., 'soft', 'medium', 'hot'
  final String? author; // Optional: if you track who added the question

  const TruthOrDareQuestion({
    required this.id,
    required this.content,
    required this.type,
    this.difficulty,
    this.author,
  });

  @override
  List<Object?> get props => [id, content, type, difficulty, author];
}
