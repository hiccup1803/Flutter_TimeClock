import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/model/app_file.dart';
import 'package:staffmonitor/model/uploader.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

import 'project.dart';

part 'admin_task_file.g.dart';

@JsonSerializable()
@JsonDateTimeConverter()
class AdminTaskFile extends AppFile {
  const AdminTaskFile(
    int? id,
    this.taskNoteId,
    String? name,
    String? type,
    int? size,
    String? note,
    int? thumbnailStatus,
    String? fileDownloadUrl,
    String? thumbnailDownloadUrl,
    Uploader? uploader,
    Project? project,
    DateTime? createdAt,
    DateTime? updatedAt,
  ) : super(id, 0, name, type, size, note, thumbnailStatus, fileDownloadUrl, thumbnailDownloadUrl,
            uploader, project, createdAt, updatedAt);

  final int? taskNoteId;

  factory AdminTaskFile.fromJson(Map<String, dynamic> json) => _$AdminTaskFileFromJson(json);

  Map<String, dynamic> toJson() => _$AdminTaskFileToJson(this);

  @override
  String toString() =>
      'File{id: $id, taskNoteId: $taskNoteId, name: $name, type: $type, size: $size,note: $note,  thumbnailStatus:$thumbnailStatus, fileDownloadUrl:$fileDownloadUrl, thumbnailDownloadUrl:$thumbnailDownloadUrl, uploader:$uploader, project:$project, createdAt: $createdAt, updatedAt: $updatedAt}';

  AdminTaskFile copyWithTaskFile({String? note}) {
    return AdminTaskFile(
      id,
      taskNoteId,
      name,
      type,
      size,
      note ?? this.note,
      thumbnailStatus,
      fileDownloadUrl,
      thumbnailDownloadUrl,
      uploader,
      project,
      createdAt,
      updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        this.id,
        this.taskNoteId,
        this.name,
        this.type,
        this.size,
        this.note,
        this.thumbnailStatus,
        this.fileDownloadUrl,
        this.thumbnailDownloadUrl,
        this.uploader,
        this.project,
        this.createdAt,
        this.updatedAt,
      ];
}

@JsonSerializable()
@JsonDateTimeConverter()
class ApiTaskFile {
  @JsonKey(includeIfNull: false)
  final int? id;
  @JsonKey(includeIfNull: false)
  final int? taskNoteId;
  @JsonKey(includeIfNull: false)
  final String? name;
  @JsonKey(includeIfNull: false)
  final String? type;
  @JsonKey(includeIfNull: false)
  final int? size;
  @JsonKey(includeIfNull: false)
  final String? note;
  @JsonKey(includeIfNull: false)
  final int? thumbnailStatus;
  @JsonKey(includeIfNull: false)
  final String? fileDownloadUrl;
  @JsonKey(includeIfNull: false)
  final String? thumbnailDownloadUrl;
  @JsonKey(includeIfNull: false)
  final Uploader? uploader;
  @JsonKey(includeIfNull: false)
  final Project? project;
  @JsonKey(includeIfNull: false)
  final DateTime? createdAt;
  @JsonKey(includeIfNull: false)
  final DateTime? updatedAt;

  ApiTaskFile(
    this.id, {
    this.taskNoteId,
    this.name,
    this.type,
    this.size,
    this.note,
    this.thumbnailStatus,
    this.fileDownloadUrl,
    this.thumbnailDownloadUrl,
    this.uploader,
    this.project,
    this.createdAt,
    this.updatedAt,
  });

  factory ApiTaskFile.fromAdminFile(AdminTaskFile file) => ApiTaskFile(
        file.id,
        taskNoteId: file.taskNoteId,
        name: file.name,
        type: file.type,
        size: file.size,
        note: file.note,
        thumbnailStatus: file.thumbnailStatus,
        fileDownloadUrl: file.fileDownloadUrl,
        thumbnailDownloadUrl: file.thumbnailDownloadUrl,
        uploader: file.uploader,
        project: file.project,
        createdAt: file.createdAt,
        updatedAt: file.updatedAt,
      );

  factory ApiTaskFile.fromJson(Map<String, dynamic> json) => _$ApiTaskFileFromJson(json);

  Map<String, dynamic> toJson() => _$ApiTaskFileToJson(this);
}
