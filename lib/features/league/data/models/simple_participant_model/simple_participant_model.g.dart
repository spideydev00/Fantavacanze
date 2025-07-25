// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simple_participant_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SimpleParticipantModelAdapter
    extends TypeAdapter<SimpleParticipantModel> {
  @override
  final int typeId = 10;

  @override
  SimpleParticipantModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SimpleParticipantModel(
      userId: fields[0] as String,
      name: fields[1] as String,
      points: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SimpleParticipantModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.points);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimpleParticipantModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
