import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  final String message;
  final dynamic data;

  const Failure(this.message, {this.data});

  @override
  List<Object?> get props => [message, data];
}
