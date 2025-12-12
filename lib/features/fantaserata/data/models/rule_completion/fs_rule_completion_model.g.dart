// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fs_rule_completion_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FsRuleCompletionModelAdapter extends TypeAdapter<FsRuleCompletionModel> {
  @override
  final int typeId = 21;

  @override
  FsRuleCompletionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FsRuleCompletionModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      userName: fields[2] as String?,
      leagueId: fields[3] as String,
      challengeId: fields[4] as String,
      name: fields[5] as String,
      points: fields[6] as double,
      type: fields[7] as FsRuleType,
      position: fields[8] as int?,
      isDynamic: fields[9] as bool,
      completedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FsRuleCompletionModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.userName)
      ..writeByte(3)
      ..write(obj.leagueId)
      ..writeByte(4)
      ..write(obj.challengeId)
      ..writeByte(5)
      ..write(obj.name)
      ..writeByte(6)
      ..write(obj.points)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.position)
      ..writeByte(9)
      ..write(obj.isDynamic)
      ..writeByte(10)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FsRuleCompletionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
