// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_break.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionBreakAdapter extends TypeAdapter<SessionBreak> {
  @override
  final int typeId = 4;

  @override
  SessionBreak read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionBreak(
      fields[0] as int,
      fields[1] as int?,
      fields[2] as DateTime?,
      end: fields[3] as DateTime?,
      paid: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SessionBreak obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionId)
      ..writeByte(2)
      ..write(obj.start)
      ..writeByte(3)
      ..write(obj.end)
      ..writeByte(4)
      ..write(obj.paid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionBreakAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionBreak _$SessionBreakFromJson(Map<String, dynamic> json) => SessionBreak(
      json['id'] as int,
      json['sessionId'] as int?,
      const JsonDateTimeConverter().fromJson(json['start'] as int?),
      end: const JsonDateTimeConverter().fromJson(json['end'] as int?),
      paid: json['paid'] == null
          ? false
          : const JsonBoolConverter().fromJson(json['paid'] as int?),
      createdAt:
          const JsonDateTimeConverter().fromJson(json['createdAt'] as int?),
      updatedAt:
          const JsonDateTimeConverter().fromJson(json['updatedAt'] as int?),
    );

Map<String, dynamic> _$SessionBreakToJson(SessionBreak instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sessionId': instance.sessionId,
      'start': const JsonDateTimeConverter().toJson(instance.start),
      'end': const JsonDateTimeConverter().toJson(instance.end),
      'paid': const JsonBoolConverter().toJson(instance.paid),
      'createdAt': const JsonDateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const JsonDateTimeConverter().toJson(instance.updatedAt),
    };
