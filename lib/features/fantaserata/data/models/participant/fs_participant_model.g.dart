// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fs_participant_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FsParticipantModelAdapter extends TypeAdapter<FsParticipantModel> {
  @override
  final int typeId = 15;

  @override
  FsParticipantModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FsParticipantModel(
      userId: fields[0] as String,
      name: fields[1] as String,
      points: fields[2] as String,
      malusTotal: fields[3] as String,
      bonusTotal: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FsParticipantModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.points)
      ..writeByte(3)
      ..write(obj.malusTotal)
      ..writeByte(4)
      ..write(obj.bonusTotal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FsParticipantModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
