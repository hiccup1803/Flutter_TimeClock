// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceToken _$DeviceTokenFromJson(Map<String, dynamic> json) => DeviceToken(
      json['id'] as int,
      json['device'] as String,
      DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$DeviceTokenToJson(DeviceToken instance) =>
    <String, dynamic>{
      'id': instance.id,
      'device': instance.token,
      'createdAt': instance.createdAt.toIso8601String(),
    };
