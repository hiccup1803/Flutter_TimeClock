import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'invitation_details.g.dart';

@JsonSerializable()
class InvitationDetails extends Equatable {
  InvitationDetails(this.companyName, this.lang);

  @JsonKey(name: 'company')
  final String? companyName;
  final String? lang;


  factory InvitationDetails.fromJson(Map<String, dynamic> json) =>
      _$InvitationDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationDetailsToJson(this);

  @override
  String toString() =>
      'InvitationDetails{companyName: $companyName, lang: $lang}';

  @override
  List<Object?> get props => [this.companyName, this.lang];
}
