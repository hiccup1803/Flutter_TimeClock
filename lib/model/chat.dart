import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/service/api/converter/json_bool_converter.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

import 'chat_participants.dart';

part 'chat.g.dart';

@JsonSerializable()
@JsonDateTimeConverter()
class ChatRoom extends Equatable {
  final int id;
  final String name;
  final int? group; //Type (0 = 1:1 chat, 1 = group) = ['0', '1'],
  final int? global; //Whether Chat Room Is Global One = ['0', '1'],
  final int? moderated; //Whether Chat Room Is Moderated = ['0', '1'],
  final List<ChatParticipants>? participants;
  final DateTime? createdAt;
  final DateTime? latestMessageAt;

  bool get isGroup => group == 1;

  const ChatRoom(this.id, this.name, this.group, this.global, this.moderated, this.participants,
      this.createdAt, this.latestMessageAt);

  ChatRoom copyWith(
          {String? name,
          int? group,
          List<ChatParticipants>? participants,
          DateTime? createdAt,
          DateTime? latestMessageAt}) =>
      ChatRoom(
          id,
          name ?? this.name,
          group ?? this.group,
          global ?? this.global,
          moderated ?? this.moderated,
          participants ?? this.participants,
          createdAt ?? this.createdAt,
          latestMessageAt ?? this.latestMessageAt);

  factory ChatRoom.fromJson(Map<String, dynamic> json) => _$ChatRoomFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomToJson(this);

  @override
  String toString() =>
      'Chat{id: $id,name: $name, group: $group,global: $global,moderated: $moderated, participants: $participants, createdAt: $createdAt,latestMessageAt: $latestMessageAt}';

  @override
  // TODO: implement props
  List<Object?> get props => [
        this.id,
        this.name,
        this.group,
        this.global,
        this.moderated,
        this.participants,
        this.createdAt,
        this.latestMessageAt
      ];
}

@JsonSerializable()
@JsonDateTimeConverter()
@JsonBoolConverter()
class ApiChatRoom {
  final String name;
  final int group;
  final List<int> users;

  ApiChatRoom(this.name, this.group, this.users);

  factory ApiChatRoom.fromChatRoom(String name, int group, List<int> users) => ApiChatRoom(
        name,
        group,
        users,
      );

  factory ApiChatRoom.fromJson(Map<String, dynamic> json) => _$ApiChatRoomFromJson(json);

  Map<String, dynamic> toJson() => _$ApiChatRoomToJson(this);
}
