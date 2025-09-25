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
      name: fields[0] as String,
      points: fields[1] as double,
      type: fields[2] as FsRuleType,
      isUnlocked: fields[3] as bool,
      isCompleted: fields[4] as bool,
      isRefreshed: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FsRuleModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.points)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.isUnlocked)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.isRefreshed);
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

class FsRuleTypeHiveAdapter extends TypeAdapter<FsRuleTypeHive> {
  @override
  final int typeId = 14;

  @override
  FsRuleTypeHive read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FsRuleTypeHive.bonus;
      case 1:
        return FsRuleTypeHive.malus;
      default:
        return FsRuleTypeHive.bonus;
    }
  }

  @override
  void write(BinaryWriter writer, FsRuleTypeHive obj) {
    switch (obj) {
      case FsRuleTypeHive.bonus:
        writer.writeByte(0);
        break;
      case FsRuleTypeHive.malus:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FsRuleTypeHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
