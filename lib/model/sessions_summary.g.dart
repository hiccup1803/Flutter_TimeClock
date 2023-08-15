// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionsSummary _$SessionsSummaryFromJson(Map<String, dynamic> json) =>
    SessionsSummary(
      json['userId'] as int?,
      const JsonDateTimeConverter().fromJson(json['from'] as int?),
      const JsonDateTimeConverter().fromJson(json['to'] as int?),
      json['projectId'] as int?,
      json['summary'] as int?,
      json['sessions'] as int?,
      (json['wages'] as List<dynamic>)
          .map((e) => Wage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SessionsSummaryToJson(SessionsSummary instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'from': const JsonDateTimeConverter().toJson(instance.from),
      'to': const JsonDateTimeConverter().toJson(instance.to),
      'projectId': instance.projectId,
      'summary': instance.summary,
      'sessions': instance.sessionsCount,
      'wages': instance.wages,
    };
