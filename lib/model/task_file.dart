import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

part 'task_file.g.dart';

@JsonSerializable()
@JsonDateTimeConverter()
class TaskFile extends Equatable {
  const TaskFile(
    this.id,
    this.taskNoteId,
    this.name,
    this.type,
    this.size,
    //0 = awaits creation if possible, 1 = creation started, 2 = ready, 9 = error
    this.thumbnailStatus,
    this.fileDownloadUrl,
    this.thumbnailDownloadUrl,
    this.createdAt,
    this.updatedAt,
  );

  final int? id;
  final int? taskNoteId;
  final String? name;
  final String? type;
  final int? size;
  final int? thumbnailStatus;
  final String? fileDownloadUrl;
  final String? thumbnailDownloadUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory TaskFile.fromJson(Map<String, dynamic> json) => _$TaskFileFromJson(json);

  Map<String, dynamic> toJson() => _$TaskFileToJson(this);

  @override
  String toString() =>
      'File{id: $id, taskNoteId: $taskNoteId, name: $name, type: $type, size: $size, thumbnailStatus:$thumbnailStatus, fileDownloadUrl:$fileDownloadUrl, thumbnailDownloadUrl:$thumbnailDownloadUrl, createdAt: $createdAt, updatedAt: $updatedAt}';

  @override
  List<Object?> get props => [
        this.id,
        this.taskNoteId,
        this.name,
        this.type,
        this.size,
        this.thumbnailStatus,
        this.fileDownloadUrl,
        this.thumbnailDownloadUrl,
        this.createdAt,
        this.updatedAt,
      ];
}
