// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskFile _$TaskFileFromJson(Map<String, dynamic> json) => TaskFile(
      json['id'] as int?,
      json['taskNoteId'] as int?,
      json['name'] as String?,
      json['type'] as String?,
      json['size'] as int?,
      json['thumbnailStatus'] as int?,
      json['fileDownloadUrl'] as String?,
      json['thumbnailDownloadUrl'] as String?,
      const JsonDateTimeConverter().fromJson(json['createdAt'] as int?),
      const JsonDateTimeConverter().fromJson(json['updatedAt'] as int?),
    );

Map<String, dynamic> _$TaskFileToJson(TaskFile instance) => <String, dynamic>{
      'id': instance.id,
      'taskNoteId': instance.taskNoteId,
      'name': instance.name,
      'type': instance.type,
      'size': instance.size,
      'thumbnailStatus': instance.thumbnailStatus,
      'fileDownloadUrl': instance.fileDownloadUrl,
      'thumbnailDownloadUrl': instance.thumbnailDownloadUrl,
      'createdAt': const JsonDateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const JsonDateTimeConverter().toJson(instance.updatedAt),
    };
