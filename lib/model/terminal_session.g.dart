// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terminal_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TerminalSession _$TerminalSessionFromJson(Map<String, dynamic> json) =>
    TerminalSession(
      json['terminal'] as String,
      json['user'] as String,
      json['session'] as String,
      json['time'] as int?,
      json['clockId'] as int?,
    );

Map<String, dynamic> _$TerminalSessionToJson(TerminalSession instance) =>
    <String, dynamic>{
      'terminal': instance.terminalId,
      'user': instance.userName,
      'session': instance.sessionStatus,
      'time': instance.timeInSeconds,
      'clockId': instance.clockId,
    };
