// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'league.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LeagueTypeAdapter extends TypeAdapter<LeagueType> {
  @override
  final int typeId = 18;

  @override
  LeagueType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LeagueType.individual;
      case 1:
        return LeagueType.team;
      default:
        return LeagueType.individual;
    }
  }

  @override
  void write(BinaryWriter writer, LeagueType obj) {
    switch (obj) {
      case LeagueType.individual:
        writer.writeByte(0);
        break;
      case LeagueType.team:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeagueTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
