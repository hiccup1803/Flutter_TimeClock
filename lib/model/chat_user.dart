import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

part 'chat_user.g.dart';

@JsonSerializable()
@JsonDateTimeConverter()
class ChatUser extends Equatable {
  final int id;
  final String name;

  const ChatUser(this.id, this.name);

  factory ChatUser.fromJson(Map<String, dynamic> json) => _$ChatUserFromJson(json);

  Map<String, dynamic> toJson() => _$ChatUserToJson(this);

  @override
  String toString() => 'ChatUser{id: $id,name: $name}';

  @override
  // TODO: implement props
  List<Object?> get props => [this.id, this.name];
}
