// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_participant_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TeamParticipantModelAdapter extends TypeAdapter<TeamParticipantModel> {
  @override
  final int typeId = 11;

  @override
  TeamParticipantModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TeamParticipantModel(
      members: (fields[0] as List).cast<SimpleParticipant>(),
      captainId: fields[1] as String,
      name: fields[2] as String,
      points: fields[3] as double,
      malusTotal: fields[4] as double,
      bonusTotal: fields[5] as double,
      teamLogoUrl: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TeamParticipantModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.members)
      ..writeByte(1)
      ..write(obj.captainId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.points)
      ..writeByte(4)
      ..write(obj.malusTotal)
      ..writeByte(5)
      ..write(obj.bonusTotal)
      ..writeByte(6)
      ..write(obj.teamLogoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamParticipantModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
