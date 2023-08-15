// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiError _$ApiErrorFromJson(Map<String, dynamic> json) => ApiError(
      json['status'] as int?,
      json['code'] as int?,
      json['name'] as String?,
      json['message'] as String?,
    );

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) => <String, dynamic>{
      'status': instance.status,
      'code': instance.code,
      'name': instance.name,
      'message': instance.message,
    };

FormErrorMessage _$FormErrorMessageFromJson(Map<String, dynamic> json) =>
    FormErrorMessage(
      json['field'] as String?,
      json['message'] as String?,
    );

Map<String, dynamic> _$FormErrorMessageToJson(FormErrorMessage instance) =>
    <String, dynamic>{
      'field': instance.field,
      'message': instance.message,
    };
