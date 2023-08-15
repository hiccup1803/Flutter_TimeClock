import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

part 'chat_participants.g.dart';

@JsonSerializable()
@JsonDateTimeConverter()
class ChatParticipants extends Equatable {
  final int id;
  final int? roomId;
  final int? userId;
  final String? userName;
  final String? userCompany;
  final int? newMessage;
  @JsonKey(defaultValue: 0)
  final int? deleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ChatParticipants(this.id, this.roomId, this.userId, this.userName, this.userCompany,
      this.newMessage, this.deleted, this.createdAt, this.updatedAt);

  factory ChatParticipants.fromJson(Map<String, dynamic> json) => _$ChatParticipantsFromJson(json);

  Map<String, dynamic> toJson() => _$ChatParticipantsToJson(this);

  @override
  String toString() =>
      'ChatParticipants{id: $id,roomId: $roomId, userId: $userId, userName: $userName,userCompany: $userCompany, newMessage: $newMessage,deleted: $deleted, createdAt: $createdAt, updatedAt: $updatedAt}';

  @override
  // TODO: implement props
  List<Object?> get props => [
        this.id,
        this.roomId,
        this.userId,
        this.userName,
        this.userCompany,
        this.newMessage,
        this.deleted,
        this.createdAt,
        this.updatedAt
      ];
}

@JsonSerializable()
class ApiChatParticipant {
  final int roomId;
  final int userId;

  ApiChatParticipant(this.roomId, this.userId);

  factory ApiChatParticipant.fromChatParticipant(int roomId, int userId) => ApiChatParticipant(
        roomId,
        userId,
      );

  factory ApiChatParticipant.fromJson(Map<String, dynamic> json) =>
      _$ApiChatParticipantFromJson(json);

  Map<String, dynamic> toJson() => _$ApiChatParticipantToJson(this);
}
