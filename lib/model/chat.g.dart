// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) => ChatRoom(
      json['id'] as int,
      json['name'] as String,
      json['group'] as int?,
      json['global'] as int?,
      json['moderated'] as int?,
      (json['participants'] as List<dynamic>?)
          ?.map((e) => ChatParticipants.fromJson(e as Map<String, dynamic>))
          .toList(),
      const JsonDateTimeConverter().fromJson(json['createdAt'] as int?),
      const JsonDateTimeConverter().fromJson(json['latestMessageAt'] as int?),
    );

Map<String, dynamic> _$ChatRoomToJson(ChatRoom instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'group': instance.group,
      'global': instance.global,
      'moderated': instance.moderated,
      'participants': instance.participants,
      'createdAt': const JsonDateTimeConverter().toJson(instance.createdAt),
      'latestMessageAt':
          const JsonDateTimeConverter().toJson(instance.latestMessageAt),
    };

ApiChatRoom _$ApiChatRoomFromJson(Map<String, dynamic> json) => ApiChatRoom(
      json['name'] as String,
      json['group'] as int,
      (json['users'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$ApiChatRoomToJson(ApiChatRoom instance) =>
    <String, dynamic>{
      'name': instance.name,
      'group': instance.group,
      'users': instance.users,
    };
