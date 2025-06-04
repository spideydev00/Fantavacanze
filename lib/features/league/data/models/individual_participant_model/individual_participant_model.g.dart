// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'individual_participant_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IndividualParticipantModelAdapter
    extends TypeAdapter<IndividualParticipantModel> {
  @override
  final int typeId = 3;

  @override
  IndividualParticipantModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IndividualParticipantModel(
      userId: fields[0] as String,
      name: fields[1] as String,
      points: fields[2] as double,
      malusTotal: fields[3] as double,
      bonusTotal: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, IndividualParticipantModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.points)
      ..writeByte(3)
      ..write(obj.malusTotal)
      ..writeByte(4)
      ..write(obj.bonusTotal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndividualParticipantModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
