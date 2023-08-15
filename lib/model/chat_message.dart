import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

part 'chat_message.g.dart';

@JsonSerializable()
@JsonDateTimeConverter()
class ChatMessage extends Equatable {
  final int id;
  final int? roomId;
  final int? userId;
  final int? participantId;
  final String? message;
  final DateTime? createdAt;

  const ChatMessage(
      this.id, this.roomId, this.userId, this.participantId, this.message, this.createdAt);

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  @override
  String toString() =>
      'ChatMessage{id: $id,roomId: $roomId, userId: $userId, participantId: $participantId, message: $message,createdAt: $createdAt}';

  @override
  // TODO: implement props
  List<Object?> get props => [
        this.id,
        this.roomId,
        this.userId,
        this.participantId,
        this.message,
        this.createdAt,
      ];
}

@JsonSerializable()
class ApiChatMessage {
  final int roomId;
  final String message;

  ApiChatMessage(this.roomId, this.message);

  factory ApiChatMessage.fromChatMessage(int roomId, String message) => ApiChatMessage(
        roomId,
        message,
      );

  factory ApiChatMessage.fromJson(Map<String, dynamic> json) => _$ApiChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ApiChatMessageToJson(this);
}
