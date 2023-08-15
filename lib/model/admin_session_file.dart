import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/model/app_file.dart';
import 'package:staffmonitor/model/uploader.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

import 'project.dart';

part 'admin_session_file.g.dart';

@JsonSerializable()
@JsonDateTimeConverter()
class AdminSessionFile extends AppFile {
  const AdminSessionFile(
    int? id,
    this.clockId,
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
  ) : super(id, 0, name, type, size, note, thumbnailStatus, fileDownloadUrl, thumbnailDownloadUrl,uploader,project,
            createdAt, updatedAt);

  final int? clockId;

  factory AdminSessionFile.fromJson(Map<String, dynamic> json) => _$AdminSessionFileFromJson(json);

  Map<String, dynamic> toJson() => _$AdminSessionFileToJson(this);

  @override
  String toString() =>
      'File{id: $id, sessionId: $clockId, name: $name, type: $type, size: $size,note: $note, thumbnailStatus:$thumbnailStatus, fileDownloadUrl:$fileDownloadUrl, thumbnailDownloadUrl:$thumbnailDownloadUrl, uploader:$uploader, project:$project, createdAt: $createdAt, updatedAt: $updatedAt}';

  AdminSessionFile copyWithSessionFile({String? note}) {
    return AdminSessionFile(id, clockId, name, type, size, note ?? this.note, thumbnailStatus,
        fileDownloadUrl, thumbnailDownloadUrl,uploader,project, createdAt, updatedAt);
  }

  @override
  List<Object?> get props => [
        this.id,
        this.clockId,
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
class ApiSessionFile {
  @JsonKey(includeIfNull: false)
  final int? id;
  @JsonKey(includeIfNull: false)
  final int? clockId;
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

  ApiSessionFile(
    this.id, {
    this.clockId,
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

  factory ApiSessionFile.fromAdminFile(AdminSessionFile file) => ApiSessionFile(
        file.id,
        clockId: file.clockId,
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

  factory ApiSessionFile.fromJson(Map<String, dynamic> json) => _$ApiSessionFileFromJson(json);

  Map<String, dynamic> toJson() => _$ApiSessionFileToJson(this);
}
