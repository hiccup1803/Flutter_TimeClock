// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_task_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminTaskFile _$AdminTaskFileFromJson(Map<String, dynamic> json) =>
    AdminTaskFile(
      json['id'] as int?,
      json['taskNoteId'] as int?,
      json['name'] as String?,
      json['type'] as String?,
      json['size'] as int?,
      json['note'] as String?,
      json['thumbnailStatus'] as int?,
      json['fileDownloadUrl'] as String?,
      json['thumbnailDownloadUrl'] as String?,
      json['uploader'] == null
          ? null
          : Uploader.fromJson(json['uploader'] as Map<String, dynamic>),
      json['project'] == null
          ? null
          : Project.fromJson(json['project'] as Map<String, dynamic>),
      const JsonDateTimeConverter().fromJson(json['createdAt'] as int?),
      const JsonDateTimeConverter().fromJson(json['updatedAt'] as int?),
    );

Map<String, dynamic> _$AdminTaskFileToJson(AdminTaskFile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'size': instance.size,
      'note': instance.note,
      'thumbnailStatus': instance.thumbnailStatus,
      'fileDownloadUrl': instance.fileDownloadUrl,
      'thumbnailDownloadUrl': instance.thumbnailDownloadUrl,
      'uploader': instance.uploader,
      'project': instance.project,
      'createdAt': const JsonDateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const JsonDateTimeConverter().toJson(instance.updatedAt),
      'taskNoteId': instance.taskNoteId,
    };

ApiTaskFile _$ApiTaskFileFromJson(Map<String, dynamic> json) => ApiTaskFile(
      json['id'] as int?,
      taskNoteId: json['taskNoteId'] as int?,
      name: json['name'] as String?,
      type: json['type'] as String?,
      size: json['size'] as int?,
      note: json['note'] as String?,
      thumbnailStatus: json['thumbnailStatus'] as int?,
      fileDownloadUrl: json['fileDownloadUrl'] as String?,
      thumbnailDownloadUrl: json['thumbnailDownloadUrl'] as String?,
      uploader: json['uploader'] == null
          ? null
          : Uploader.fromJson(json['uploader'] as Map<String, dynamic>),
      project: json['project'] == null
          ? null
          : Project.fromJson(json['project'] as Map<String, dynamic>),
      createdAt:
          const JsonDateTimeConverter().fromJson(json['createdAt'] as int?),
      updatedAt:
          const JsonDateTimeConverter().fromJson(json['updatedAt'] as int?),
    );

Map<String, dynamic> _$ApiTaskFileToJson(ApiTaskFile instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('taskNoteId', instance.taskNoteId);
  writeNotNull('name', instance.name);
  writeNotNull('type', instance.type);
  writeNotNull('size', instance.size);
  writeNotNull('note', instance.note);
  writeNotNull('thumbnailStatus', instance.thumbnailStatus);
  writeNotNull('fileDownloadUrl', instance.fileDownloadUrl);
  writeNotNull('thumbnailDownloadUrl', instance.thumbnailDownloadUrl);
  writeNotNull('uploader', instance.uploader);
  writeNotNull('project', instance.project);
  writeNotNull(
      'createdAt', const JsonDateTimeConverter().toJson(instance.createdAt));
  writeNotNull(
      'updatedAt', const JsonDateTimeConverter().toJson(instance.updatedAt));
  return val;
}
