// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 2;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      isPro: fields[0] as bool,
      isFirstLaunch: fields[1] as bool,
      proDayBeforeNotifyHour: fields[2] as int?,
      proDayBeforeNotifyMinute: fields[3] as int?,
      hasSeenTutorial: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.isPro)
      ..writeByte(1)
      ..write(obj.isFirstLaunch)
      ..writeByte(2)
      ..write(obj.proDayBeforeNotifyHour)
      ..writeByte(3)
      ..write(obj.proDayBeforeNotifyMinute)
      ..writeByte(4)
      ..write(obj.hasSeenTutorial);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
