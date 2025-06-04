// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_challenge_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyChallengeModelAdapter extends TypeAdapter<DailyChallengeModel> {
  @override
  final int typeId = 1;

  @override
  DailyChallengeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyChallengeModel(
      id: fields[0] as String,
      userId: fields[8] as String,
      leagueId: fields[9] as String,
      tableChallengeId: fields[10] as String,
      name: fields[1] as String,
      points: fields[2] as double,
      isCompleted: fields[3] as bool,
      completedAt: fields[4] as DateTime?,
      isRefreshed: fields[5] as bool,
      refreshedAt: fields[6] as DateTime,
      createdAt: fields[11] as DateTime,
      position: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DailyChallengeModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.points)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.completedAt)
      ..writeByte(5)
      ..write(obj.isRefreshed)
      ..writeByte(6)
      ..write(obj.refreshedAt)
      ..writeByte(7)
      ..write(obj.position)
      ..writeByte(8)
      ..write(obj.userId)
      ..writeByte(9)
      ..write(obj.leagueId)
      ..writeByte(10)
      ..write(obj.tableChallengeId)
      ..writeByte(11)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyChallengeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
