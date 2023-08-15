import 'package:hive_flutter/hive_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'uploader.g.dart';

@JsonSerializable()
@HiveType(typeId: 6)
class Uploader {
  Uploader(
    this.id,
    this.name,
  );

  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;

  factory Uploader.fromJson(Map<String, dynamic> json) => _$UploaderFromJson(json);

  Map<String, dynamic> toJson() => _$UploaderToJson(this);
}
