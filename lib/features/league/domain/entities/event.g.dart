// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventTargetAdapter extends TypeAdapter<EventTarget> {
  @override
  final int typeId = 20;

  @override
  EventTarget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventTarget(
      kind: fields[0] as EventTargetKind,
      userId: fields[1] as String?,
      teamName: fields[2] as String?,
      memberId: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EventTarget obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.kind)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.teamName)
      ..writeByte(3)
      ..write(obj.memberId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventTargetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EventTargetKindAdapter extends TypeAdapter<EventTargetKind> {
  @override
  final int typeId = 19;

  @override
  EventTargetKind read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EventTargetKind.individual;
      case 1:
        return EventTargetKind.team;
      case 2:
        return EventTargetKind.teamMember;
      default:
        return EventTargetKind.individual;
    }
  }

  @override
  void write(BinaryWriter writer, EventTargetKind obj) {
    switch (obj) {
      case EventTargetKind.individual:
        writer.writeByte(0);
        break;
      case EventTargetKind.team:
        writer.writeByte(1);
        break;
      case EventTargetKind.teamMember:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventTargetKindAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
