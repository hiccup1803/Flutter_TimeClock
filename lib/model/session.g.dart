// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionAdapter extends TypeAdapter<Session> {
  @override
  final int typeId = 3;

  @override
  Session read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Session(
      fields[0] as int,
      fields[1] as bool,
      fields[2] as DateTime?,
      fields[3] as DateTime?,
      fields[4] as DateTime?,
      fields[5] as DateTime?,
      fields[6] as String?,
      fields[7] as Project?,
      fields[9] as String?,
      fields[10] as String?,
      fields[11] as String?,
      fields[12] as String?,
      fields[13] as String?,
      fields[14] as bool?,
      fields[15] as bool?,
      (fields[16] as List?)?.cast<Multiplier>(),
      (fields[8] as List).cast<AppFile>(),
      fields[17] as DateTime?,
      fields[18] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.verified)
      ..writeByte(2)
      ..write(obj.clockIn)
      ..writeByte(3)
      ..write(obj.clockInProposed)
      ..writeByte(4)
      ..write(obj.clockOut)
      ..writeByte(5)
      ..write(obj.clockOutProposed)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.project)
      ..writeByte(8)
      ..write(obj.files)
      ..writeByte(9)
      ..write(obj.bonus)
      ..writeByte(10)
      ..write(obj.bonusProposed)
      ..writeByte(11)
      ..write(obj.hourRate)
      ..writeByte(12)
      ..write(obj.rateCurrency)
      ..writeByte(13)
      ..write(obj.totalWage)
      ..writeByte(14)
      ..write(obj.calculated)
      ..writeByte(15)
      ..write(obj.overtime)
      ..writeByte(16)
      ..write(obj.multiplier)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Session _$SessionFromJson(Map<String, dynamic> json) => Session(
      json['id'] as int,
      const JsonBoolConverter().fromJson(json['verified'] as int?),
      const JsonDateTimeConverter().fromJson(json['clockIn'] as int?),
      const JsonDateTimeConverter().fromJson(json['clockInProposed'] as int?),
      const JsonDateTimeConverter().fromJson(json['clockOut'] as int?),
      const JsonDateTimeConverter().fromJson(json['clockOutProposed'] as int?),
      json['note'] as String?,
      json['project'] == null
          ? null
          : Project.fromJson(json['project'] as Map<String, dynamic>),
      json['bonus'] as String?,
      json['bonusProposed'] as String?,
      json['hourRate'] as String?,
      json['rateCurrency'] as String?,
      fallbackWage(json['totalWage']),
      const JsonBoolConverter().fromJson(json['calculated'] as int?),
      const JsonBoolConverter().fromJson(json['overtime'] as int?),
      (json['multiplier'] as List<dynamic>?)
          ?.map((e) => Multiplier.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['files'] as List<dynamic>?)
              ?.map((e) => AppFile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      const JsonDateTimeConverter().fromJson(json['createdAt'] as int?),
      const JsonDateTimeConverter().fromJson(json['updatedAt'] as int?),
    );

Map<String, dynamic> _$SessionToJson(Session instance) => <String, dynamic>{
      'id': instance.id,
      'verified': const JsonBoolConverter().toJson(instance.verified),
      'clockIn': const JsonDateTimeConverter().toJson(instance.clockIn),
      'clockInProposed':
          const JsonDateTimeConverter().toJson(instance.clockInProposed),
      'clockOut': const JsonDateTimeConverter().toJson(instance.clockOut),
      'clockOutProposed':
          const JsonDateTimeConverter().toJson(instance.clockOutProposed),
      'note': instance.note,
      'project': instance.project,
      'files': instance.files,
      'bonus': instance.bonus,
      'bonusProposed': instance.bonusProposed,
      'hourRate': instance.hourRate,
      'rateCurrency': instance.rateCurrency,
      'totalWage': instance.totalWage,
      'calculated': _$JsonConverterToJson<int?, bool>(
          instance.calculated, const JsonBoolConverter().toJson),
      'overtime': _$JsonConverterToJson<int?, bool>(
          instance.overtime, const JsonBoolConverter().toJson),
      'multiplier': instance.multiplier,
      'createdAt': const JsonDateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const JsonDateTimeConverter().toJson(instance.updatedAt),
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

ApiSession _$ApiSessionFromJson(Map<String, dynamic> json) => ApiSession(
      json['projectId'] as int?,
      json['source'] as String,
      const JsonDateTimeConverter().fromJson(json['clockIn'] as int?),
      note: json['note'] as String?,
      bonus: json['bonus'] as String?,
      clockOut:
          const JsonDateTimeConverter().fromJson(json['clockOut'] as int?),
      defaultProject: json['defaultProject'] as int? ?? 0,
      newProject: json['newProject'] as String?,
      color: json['color'] as String?,
      hourRate: json['hourRate'] as String?,
      rateCurrency: json['rateCurrency'] as String?,
    );

Map<String, dynamic> _$ApiSessionToJson(ApiSession instance) {
  final val = <String, dynamic>{
    'defaultProject': instance.defaultProject,
    'projectId': instance.projectId,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'clockIn', const JsonDateTimeConverter().toJson(instance.clockIn));
  writeNotNull(
      'clockOut', const JsonDateTimeConverter().toJson(instance.clockOut));
  writeNotNull('note', instance.note);
  writeNotNull('bonus', instance.bonus);
  writeNotNull('newProject', instance.newProject);
  writeNotNull('color', instance.color);
  writeNotNull('hourRate', instance.hourRate);
  writeNotNull('rateCurrency', instance.rateCurrency);
  val['source'] = instance.source;
  return val;
}
