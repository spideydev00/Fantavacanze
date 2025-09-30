// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fs_league_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FsLeagueModelAdapter extends TypeAdapter<FsLeagueModel> {
  @override
  final int typeId = 18;

  @override
  FsLeagueModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FsLeagueModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      createdAt: fields[3] as DateTime,
      inviteCode: fields[4] as String,
      participants: (fields[5] as List).cast<FsParticipantModel>(),
      winnerPhotoUrl: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FsLeagueModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.inviteCode)
      ..writeByte(5)
      ..write(obj.participants)
      ..writeByte(6)
      ..write(obj.winnerPhotoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FsLeagueModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
