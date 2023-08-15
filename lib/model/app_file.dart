import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/model/uploader.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

import 'project.dart';

part 'app_file.g.dart';

@JsonSerializable()
@JsonDateTimeConverter()
@HiveType(typeId: 5)
class AppFile extends Equatable {
  const AppFile(
    this.id,
    this.sessionId,
    this.name,
    this.type,
    this.size,
    this.note,
    //0 = awaits creation if possible, 1 = creation started, 2 = ready, 9 = error
    this.thumbnailStatus,
    this.fileDownloadUrl,
    this.thumbnailDownloadUrl,
    this.uploader,
    this.project,
    this.createdAt,
    this.updatedAt,
  );
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final int? sessionId;
  @HiveField(2)
  final String? name;
  @HiveField(3)
  final String? type;
  @HiveField(4)
  final int? size;
  @HiveField(5)
  final String? note;
  @HiveField(6)
  final int? thumbnailStatus;
  @HiveField(7)
  final String? fileDownloadUrl;
  @HiveField(8)
  final String? thumbnailDownloadUrl;
  @HiveField(9)
  final Uploader? uploader;
  @HiveField(10)
  final Project? project;
  @HiveField(11)
  final DateTime? createdAt;
  @HiveField(12)
  final DateTime? updatedAt;

  factory AppFile.fromJson(Map<String, dynamic> json) => _$AppFileFromJson(json);

  Map<String, dynamic> toJson() => _$AppFileToJson(this);

  @override
  String toString() =>
      'File{id: $id, sessionId: $sessionId, name: $name, type: $type, size: $size, note: $note, thumbnailStatus:$thumbnailStatus, fileDownloadUrl:$fileDownloadUrl, thumbnailDownloadUrl:$thumbnailDownloadUrl, uploader:$uploader,project:$project, createdAt: $createdAt, updatedAt: $updatedAt}';

  @override
  List<Object?> get props => [
        this.id,
        this.sessionId,
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
