// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_customfiled.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskCustomFiled _$TaskCustomFiledFromJson(Map<String, dynamic> json) =>
    TaskCustomFiled(
      json['fieldId'] as int,
      json['name'] as String,
      json['value'],
      json['type'] as String,
      option:
          (json['option'] as List<dynamic>?)?.map((e) => e as String).toList(),
      available: json['available'] as bool? ?? true,
    );

Map<String, dynamic> _$TaskCustomFiledToJson(TaskCustomFiled instance) =>
    <String, dynamic>{
      'fieldId': instance.fieldId,
      'name': instance.name,
      'value': instance.value,
      'type': instance.type,
      'option': instance.option,
      'available': instance.available,
    };
