// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_participants.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatParticipants _$ChatParticipantsFromJson(Map<String, dynamic> json) =>
    ChatParticipants(
      json['id'] as int,
      json['roomId'] as int?,
      json['userId'] as int?,
      json['userName'] as String?,
      json['userCompany'] as String?,
      json['newMessage'] as int?,
      json['deleted'] as int? ?? 0,
      const JsonDateTimeConverter().fromJson(json['createdAt'] as int?),
      const JsonDateTimeConverter().fromJson(json['updatedAt'] as int?),
    );

Map<String, dynamic> _$ChatParticipantsToJson(ChatParticipants instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roomId': instance.roomId,
      'userId': instance.userId,
      'userName': instance.userName,
      'userCompany': instance.userCompany,
      'newMessage': instance.newMessage,
      'deleted': instance.deleted,
      'createdAt': const JsonDateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const JsonDateTimeConverter().toJson(instance.updatedAt),
    };

ApiChatParticipant _$ApiChatParticipantFromJson(Map<String, dynamic> json) =>
    ApiChatParticipant(
      json['roomId'] as int,
      json['userId'] as int,
    );

Map<String, dynamic> _$ApiChatParticipantToJson(ApiChatParticipant instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'userId': instance.userId,
    };
