// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terminal_session_nfc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TerminalSessionNfc _$TerminalSessionNfcFromJson(Map<String, dynamic> json) =>
    TerminalSessionNfc(
      json['nfc'] as String?,
      json['terminal'] as String?,
      json['user'] as String?,
      json['session'] as String?,
      json['time'] as int?,
      json['clockId'] as int?,
    );

Map<String, dynamic> _$TerminalSessionNfcToJson(TerminalSessionNfc instance) =>
    <String, dynamic>{
      'nfc': instance.nfc,
      'terminal': instance.terminalId,
      'user': instance.userName,
      'session': instance.sessionStatus,
      'time': instance.timeInSeconds,
      'clockId': instance.clockId,
    };
