// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_challenge_notification_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyChallengeNotificationModelAdapter
    extends TypeAdapter<DailyChallengeNotificationModel> {
  @override
  final int typeId = 7;

  @override
  DailyChallengeNotificationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyChallengeNotificationModel(
      id: fields[0] as String,
      title: fields[1] as String,
      message: fields[2] as String,
      createdAt: fields[3] as DateTime,
      userId: fields[4] as String,
      leagueId: fields[5] as String,
      challengeId: fields[6] as String,
      challengeName: fields[7] as String,
      challengePoints: fields[8] as double,
      targetUserIds: (fields[9] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, DailyChallengeNotificationModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.userId)
      ..writeByte(5)
      ..write(obj.leagueId)
      ..writeByte(6)
      ..write(obj.challengeId)
      ..writeByte(7)
      ..write(obj.challengeName)
      ..writeByte(8)
      ..write(obj.challengePoints)
      ..writeByte(9)
      ..write(obj.targetUserIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyChallengeNotificationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
