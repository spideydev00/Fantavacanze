// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventModelAdapter extends TypeAdapter<EventModel> {
  @override
  final int typeId = 2;

  @override
  EventModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    final dynamic rawTargetKind = fields[4];
    final EventTargetKind targetKind;
    if (rawTargetKind is EventTargetKind) {
      targetKind = rawTargetKind;
    } else if (rawTargetKind is String) {
      targetKind = EventTargetKind.values.firstWhere(
        (kind) => kind.name == rawTargetKind,
        orElse: () => EventTargetKind.individual,
      );
    } else {
      targetKind = EventTargetKind.individual;
    }
    return EventModel(
      id: fields[0] as String,
      name: fields[1] as String,
      points: fields[2] as double,
      creatorId: fields[3] as String,
      target: EventTarget(
        kind: targetKind,
        userId: fields[5] as String?,
        teamName: fields[6] as String?,
        memberId: fields[7] as String?,
      ),
      createdAt: fields[8] as DateTime,
      type: fields[9] as RuleType,
      description: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EventModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.points)
      ..writeByte(3)
      ..write(obj.creatorId)
      ..writeByte(4)
      ..write(obj.hiveTargetKind)
      ..writeByte(5)
      ..write(obj.hiveTargetUserId)
      ..writeByte(6)
      ..write(obj.hiveTargetTeamName)
      ..writeByte(7)
      ..write(obj.hiveTargetMemberId)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.type)
      ..writeByte(10)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
