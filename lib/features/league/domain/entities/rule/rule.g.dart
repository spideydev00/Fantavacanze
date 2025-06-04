// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RuleTypeAdapter extends TypeAdapter<RuleType> {
  @override
  final int typeId = 12;

  @override
  RuleType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RuleType.bonus;
      case 1:
        return RuleType.malus;
      default:
        return RuleType.bonus;
    }
  }

  @override
  void write(BinaryWriter writer, RuleType obj) {
    switch (obj) {
      case RuleType.bonus:
        writer.writeByte(0);
        break;
      case RuleType.malus:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuleTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
