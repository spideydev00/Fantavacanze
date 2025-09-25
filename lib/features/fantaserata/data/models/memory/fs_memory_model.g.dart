// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fs_memory_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FsMemoryModelAdapter extends TypeAdapter<FsMemoryModel> {
  @override
  final int typeId = 17;

  @override
  FsMemoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FsMemoryModel(
      id: fields[0] as String,
      imageUrl: fields[1] as String,
      description: fields[2] as String,
      createdAt: fields[3] as DateTime,
      userId: fields[4] as String,
      participantName: fields[5] as String,
      relatedEventId: fields[6] as String?,
      eventName: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FsMemoryModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imageUrl)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.participantName)
      ..writeByte(6)
      ..write(obj.relatedEventId)
      ..writeByte(7)
      ..write(obj.eventName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FsMemoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
