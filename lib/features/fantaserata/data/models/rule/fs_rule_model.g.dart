// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fs_rule_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FsRuleModelAdapter extends TypeAdapter<FsRuleModel> {
  @override
  final int typeId = 13;

  @override
  FsRuleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FsRuleModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      leagueId: fields[2] as String,
      challengeId: fields[3] as String,
      name: fields[4] as String,
      points: fields[5] as double,
      type: fields[6] as FsRuleType,
      position: fields[7] as double,
      isCompleted: fields[8] as bool,
      isRefreshed: fields[9] as bool,
      isUnlocked: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FsRuleModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.leagueId)
      ..writeByte(3)
      ..write(obj.challengeId)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.points)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.position)
      ..writeByte(8)
      ..write(obj.isCompleted)
      ..writeByte(9)
      ..write(obj.isRefreshed)
      ..writeByte(10)
      ..write(obj.isUnlocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FsRuleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
