// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terminal_access.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TerminalAccess _$TerminalAccessFromJson(Map<String, dynamic> json) =>
    TerminalAccess(
      json['terminal'] as String,
      json['name'] as String,
      json['company'] as String,
      json['status'] as int,
    );

Map<String, dynamic> _$TerminalAccessToJson(TerminalAccess instance) =>
    <String, dynamic>{
      'terminal': instance.terminalId,
      'name': instance.name,
      'company': instance.companyName,
      'status': instance.status,
    };
