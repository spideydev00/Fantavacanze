import 'package:equatable/equatable.dart';

class NeverHaveIEverQuestion extends Equatable {
  final String id;
  final String content;

  const NeverHaveIEverQuestion({
    required this.id,
    required this.content,
  });

  @override
  List<Object?> get props => [id, content];
}
