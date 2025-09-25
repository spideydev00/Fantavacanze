// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fs_event_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FsEventModelAdapter extends TypeAdapter<FsEventModel> {
  @override
  final int typeId = 16;

  @override
  FsEventModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FsEventModel(
      id: fields[0] as String,
      name: fields[1] as String,
      points: fields[2] as double,
      targetParticipant: fields[3] as FsParticipantModel,
      createdAt: fields[4] as DateTime,
      type: fields[5] as FsRuleType,
    );
  }

  @override
  void write(BinaryWriter writer, FsEventModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.points)
      ..writeByte(3)
      ..write(obj.targetParticipant)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FsEventModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
