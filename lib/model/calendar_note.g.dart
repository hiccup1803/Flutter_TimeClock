// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarNote _$CalendarNoteFromJson(Map<String, dynamic> json) => CalendarNote(
      json['id'] as int,
      json['taskId'] as int?,
      json['author'] as String?,
      json['editor'] as String?,
      json['note'] as String?,
      json['file'] == null
          ? null
          : AppFile.fromJson(json['file'] as Map<String, dynamic>),
      const JsonDateTimeConverter().fromJson(json['createdAt'] as int?),
      const JsonDateTimeConverter().fromJson(json['updatedAt'] as int?),
    );

Map<String, dynamic> _$CalendarNoteToJson(CalendarNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'author': instance.author,
      'editor': instance.editor,
      'note': instance.note,
      'file': instance.file,
      'createdAt': const JsonDateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const JsonDateTimeConverter().toJson(instance.updatedAt),
    };
