// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fs_night_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FsNightTypeAdapter extends TypeAdapter<FsNightType> {
  @override
  final int typeId = 17;

  @override
  FsNightType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FsNightType.def;
      case 1:
        return FsNightType.halloween;
      case 2:
        return FsNightType.apresSki;
      case 3:
        return FsNightType.christmas;
      case 4:
        return FsNightType.carnival;
      case 5:
        return FsNightType.newYearsEve;
      default:
        return FsNightType.def;
    }
  }

  @override
  void write(BinaryWriter writer, FsNightType obj) {
    switch (obj) {
      case FsNightType.def:
        writer.writeByte(0);
        break;
      case FsNightType.halloween:
        writer.writeByte(1);
        break;
      case FsNightType.apresSki:
        writer.writeByte(2);
        break;
      case FsNightType.christmas:
        writer.writeByte(3);
        break;
      case FsNightType.carnival:
        writer.writeByte(4);
        break;
      case FsNightType.newYearsEve:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FsNightTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
