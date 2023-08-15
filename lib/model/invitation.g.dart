// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Invitation _$InvitationFromJson(Map<String, dynamic> json) => Invitation(
      json['id'] as int?,
      json['code'] as String?,
      json['note'] as String?,
      json['link'] as String?,
      json['lang'] as String?,
      const JsonDateTimeConverter().fromJson(json['createdAt'] as int?),
    );

Map<String, dynamic> _$InvitationToJson(Invitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'note': instance.note,
      'link': instance.link,
      'lang': instance.lang,
      'createdAt': const JsonDateTimeConverter().toJson(instance.createdAt),
    };
