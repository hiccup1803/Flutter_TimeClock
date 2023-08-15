// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_task_customfiled.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminTaskCustomFiled _$AdminTaskCustomFiledFromJson(
        Map<String, dynamic> json) =>
    AdminTaskCustomFiled(
      json['id'] as int,
      json['name'] as String,
      json['type'] as String,
      json['available'] as bool,
      json['target'] as String,
      json['extra'] as String?,
    );

Map<String, dynamic> _$AdminTaskCustomFiledToJson(
        AdminTaskCustomFiled instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'available': instance.available,
      'target': instance.target,
      'extra': instance.extra,
    };
