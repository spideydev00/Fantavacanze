// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fs_rule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FsRuleTypeAdapter extends TypeAdapter<FsRuleType> {
  @override
  final int typeId = 14;

  @override
  FsRuleType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FsRuleType.bonus;
      case 1:
        return FsRuleType.malus;
      default:
        return FsRuleType.bonus;
    }
  }

  @override
  void write(BinaryWriter writer, FsRuleType obj) {
    switch (obj) {
      case FsRuleType.bonus:
        writer.writeByte(0);
        break;
      case FsRuleType.malus:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FsRuleTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
