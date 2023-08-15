// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvitationDetails _$InvitationDetailsFromJson(Map<String, dynamic> json) =>
    InvitationDetails(
      json['company'] as String?,
      json['lang'] as String?,
    );

Map<String, dynamic> _$InvitationDetailsToJson(InvitationDetails instance) =>
    <String, dynamic>{
      'company': instance.companyName,
      'lang': instance.lang,
    };
