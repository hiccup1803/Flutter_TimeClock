// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
      json['id'] as int,
      json['roomId'] as int?,
      json['userId'] as int?,
      json['participantId'] as int?,
      json['message'] as String?,
      const JsonDateTimeConverter().fromJson(json['createdAt'] as int?),
    );

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roomId': instance.roomId,
      'userId': instance.userId,
      'participantId': instance.participantId,
      'message': instance.message,
      'createdAt': const JsonDateTimeConverter().toJson(instance.createdAt),
    };

ApiChatMessage _$ApiChatMessageFromJson(Map<String, dynamic> json) =>
    ApiChatMessage(
      json['roomId'] as int,
      json['message'] as String,
    );

Map<String, dynamic> _$ApiChatMessageToJson(ApiChatMessage instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'message': instance.message,
    };
