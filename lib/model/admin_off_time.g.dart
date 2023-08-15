// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_off_time.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminOffTime _$AdminOffTimeFromJson(Map<String, dynamic> json) => AdminOffTime(
      json['id'] as int,
      json['userId'] as int,
      json['startAt'] as String?,
      json['endAt'] as String?,
      json['note'] as String?,
      json['type'] as int,
      json['days'] as int,
      json['year'] as int? ?? 2021,
      json['approved'] as int?,
      const JsonDateTimeConverter().fromJson(json['createdAt'] as int?),
      const JsonDateTimeConverter().fromJson(json['updatedAt'] as int?),
    );

Map<String, dynamic> _$AdminOffTimeToJson(AdminOffTime instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startAt': instance.startAt,
      'endAt': instance.endAt,
      'note': instance.note,
      'type': instance.type,
      'days': instance.days,
      'year': instance.year,
      'approved': instance.status,
      'createdAt': const JsonDateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const JsonDateTimeConverter().toJson(instance.updatedAt),
      'userId': instance.userId,
    };
