import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/utils/color_utils.dart';

export 'package:staffmonitor/utils/color_utils.dart';

part 'project.g.dart';

@JsonSerializable()
@HiveType(typeId: 2)
class Project extends Equatable {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @JsonKey(name: 'color', defaultValue: '')
  @HiveField(2)
  final String colorHash;

  static Project noProject = Project(-1, '-- no project --', '#000000');

  static Project ownProject = Project(-2, '-- new project --', '#f1f3f4');

  Project(this.id, this.name, this.colorHash);

  factory Project.create({required String name, required Color color}) =>
      Project(-1, name, color.toHexHash());

  @JsonKey(ignore: true)
  Color? get color => HexColor.parse(colorHash);

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  @override
  List<Object?> get props => [this.id, this.name, this.colorHash];

  @override
  String toString() => 'Project{id: $id, name: $name, color: $colorHash}';
}
