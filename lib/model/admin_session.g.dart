// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminSession _$AdminSessionFromJson(Map<String, dynamic> json) => AdminSession(
      json['id'] as int,
      json['userId'] as int,
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

Map<String, dynamic> _$AdminSessionToJson(AdminSession instance) =>
    <String, dynamic>{
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
      'userId': instance.userId,
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
