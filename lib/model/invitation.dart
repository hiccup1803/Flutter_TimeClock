import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

part 'invitation.g.dart';

@JsonSerializable()
@JsonDateTimeConverter()
class Invitation extends Equatable {
  final int? id;
  final String? code;
  final String? note;
  final String? link;
  final String? lang;
  final DateTime? createdAt;

  const Invitation(this.id, this.code, this.note, this.link, this.lang, this.createdAt);


  factory Invitation.fromJson(Map<String, dynamic> json) =>
      _$InvitationFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationToJson(this);

  @override
  List<Object?> get props => [this.id, this.code, this.note, this.link, this.lang, this.createdAt];
}
