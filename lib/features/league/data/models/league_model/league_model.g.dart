// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'league_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeagueModelAdapter extends TypeAdapter<LeagueModel> {
  @override
  final int typeId = 4;

  @override
  LeagueModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LeagueModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      createdAt: fields[3] as DateTime,
      participants: (fields[4] as List).cast<Participant>(),
      events: (fields[5] as List).cast<Event>(),
      memories: (fields[6] as List).cast<Memory>(),
      rules: (fields[7] as List).cast<Rule>(),
      admins: (fields[8] as List).cast<String>(),
      inviteCode: fields[9] as String,
      isTeamBased: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LeagueModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.participants)
      ..writeByte(5)
      ..write(obj.events)
      ..writeByte(6)
      ..write(obj.memories)
      ..writeByte(7)
      ..write(obj.rules)
      ..writeByte(8)
      ..write(obj.admins)
      ..writeByte(9)
      ..write(obj.inviteCode)
      ..writeByte(10)
      ..write(obj.isTeamBased);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeagueModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
