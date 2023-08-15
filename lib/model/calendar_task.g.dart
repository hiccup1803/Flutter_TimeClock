// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarTask _$CalendarTaskFromJson(Map<String, dynamic> json) => CalendarTask(
      json['id'] as int,
      const JsonDateTimeConverter().fromJson(json['start'] as int?),
      const JsonDateTimeConverter().fromJson(json['end'] as int?),
      json['title'] as String?,
      const JsonBoolConverter().fromJson(json['wholeDay'] as int?),
      json['location'] as String?,
      json['status'] as int? ?? 0,
      json['project'] == null
          ? null
          : Project.fromJson(json['project'] as Map<String, dynamic>),
      (json['notes'] as List<dynamic>?)
              ?.map((e) => CalendarNote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      const JsonDateTimeConverter().fromJson(json['createdAt'] as int?),
      const JsonDateTimeConverter().fromJson(json['updatedAt'] as int?),
      (json['assignees'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          [],
      (json['customFields'] as List<dynamic>)
          .map((e) => TaskCustomFiled.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['priority'] as int?,
      json['authorId'] as int?,
    );

Map<String, dynamic> _$CalendarTaskToJson(CalendarTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'start': const JsonDateTimeConverter().toJson(instance.start),
      'end': const JsonDateTimeConverter().toJson(instance.end),
      'title': instance.title,
      'wholeDay': const JsonBoolConverter().toJson(instance.wholeDay),
      'location': instance.location,
      'status': instance.status,
      'project': instance.project,
      'notes': instance.notes,
      'assignees': instance.assignees,
      'customFields': instance.customFields,
      'createdAt': const JsonDateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const JsonDateTimeConverter().toJson(instance.updatedAt),
      'priority': instance.priority,
      'authorId': instance.authorId,
    };

ApiCalendarTask _$ApiCalendarTaskFromJson(Map<String, dynamic> json) =>
    ApiCalendarTask(
      json['title'] as String?,
      const JsonDateTimeConverter().fromJson(json['start'] as int?),
      (json['assignees'] as List<dynamic>?)?.map((e) => e as int).toList(),
      end: const JsonDateTimeConverter().fromJson(json['end'] as int?),
      wholeDay: json['wholeDay'] as int?,
      location: json['location'] as String?,
      projectId: json['projectId'] as int?,
      newProject: json['newProject'] as String?,
      projectColor: json['projectColor'] as String?,
      sendEmail: json['sendEmail'] as int?,
      sendPush: json['sendPush'] as int?,
      sendImmediately: json['sendImmediately'] as int?,
      status: json['status'] as int?,
      priority: json['priority'] as int?,
      customFields: (json['customFields'] as List<dynamic>?)
          ?.map((e) => TaskCustomValueFiled.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ApiCalendarTaskToJson(ApiCalendarTask instance) {
  final val = <String, dynamic>{
    'title': instance.title,
    'start': const JsonDateTimeConverter().toJson(instance.start),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('assignees', instance.assignees);
  writeNotNull('end', const JsonDateTimeConverter().toJson(instance.end));
  writeNotNull('wholeDay', instance.wholeDay);
  writeNotNull('location', instance.location);
  writeNotNull('projectId', instance.projectId);
  writeNotNull('newProject', instance.newProject);
  writeNotNull('projectColor', instance.projectColor);
  writeNotNull('sendEmail', instance.sendEmail);
  writeNotNull('sendPush', instance.sendPush);
  writeNotNull('sendImmediately', instance.sendImmediately);
  writeNotNull('status', instance.status);
  writeNotNull('priority', instance.priority);
  writeNotNull('customFields', instance.customFields);
  return val;
}

ApiUserTask _$ApiUserTaskFromJson(Map<String, dynamic> json) => ApiUserTask(
      status: json['status'] as int?,
      priority: json['priority'] as int?,
    );

Map<String, dynamic> _$ApiUserTaskToJson(ApiUserTask instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('status', instance.status);
  writeNotNull('priority', instance.priority);
  return val;
}
