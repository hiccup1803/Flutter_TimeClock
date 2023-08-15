import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/model/admin_project.dart';
import 'package:staffmonitor/model/project.dart';
import 'package:staffmonitor/service/api/converter/json_string_converter.dart';
import '../service/api/converter/json_bool_converter.dart';
import '../service/api/converter/json_date_time_converter.dart';

part 'admin_terminal.g.dart';

@JsonSerializable()
@JsonBoolConverter()
@JsonDateTimeConverter()
class AdminTerminal extends Equatable {
  AdminTerminal(this.id, this.name, this.code, this.status, this.photoVerification, this.project,
      this.codeExpiresAt, this.createdAt, this.updatedAt);

  final String id;
  final String name;
  @JsonStringConverter()
  final String? code;
  final int status;
  final int? photoVerification;
  final AdminProject? project;
  final DateTime? codeExpiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @JsonKey(ignore: true)
  bool get isCreate => id.isEmpty;

  factory AdminTerminal.fromJson(Map<String, dynamic> json) => _$AdminTerminalFromJson(json);

  factory AdminTerminal.create() => AdminTerminal('', '', null, 0, 0, null, null, null, null);

  Map<String, dynamic> toJson() => _$AdminTerminalToJson(this);

  @override
  String toString() =>
      'AdminTerminal{id: $id, name: $name,  code: $code,status: $status,photoVerification: $photoVerification,project: $project,codeExpiresAt: $codeExpiresAt,createdAt: $createdAt, updatedAt: $updatedAt}';

  AdminTerminal copyWith({
    String? id,
    String? name,
    String? code,
    int? status,
    int? photoVerification,
    AdminProject? project,
    DateTime? codeExpiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminTerminal(
      id ?? this.id,
      name ?? this.name,
      code ?? this.code,
      status ?? this.status,
      photoVerification ?? this.photoVerification,
      project ?? this.project,
      codeExpiresAt ?? this.codeExpiresAt,
      createdAt ?? this.createdAt,
      updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        this.id,
        this.name,
        this.code,
        this.status,
        this.photoVerification,
        this.project,
        this.codeExpiresAt,
        this.createdAt,
        this.updatedAt,
      ];
}

@JsonSerializable()
@JsonDateTimeConverter()
@JsonBoolConverter()
class ApiTerminal {
  final String? name;
  @JsonKey(includeIfNull: true)
  final int? projectId;
  @JsonKey(includeIfNull: false)
  final int? photoVerification;

  ApiTerminal(
    this.name, {
    this.projectId,
    this.photoVerification,
  });

  factory ApiTerminal.fromAdminTerminal(AdminTerminal task, int? photoVerification) => ApiTerminal(
        task.name,
        projectId: task.project?.id == Project.noProject.id ? null : task.project?.id,
        photoVerification: photoVerification,
      );

  factory ApiTerminal.fromJson(Map<String, dynamic> json) => _$ApiTerminalFromJson(json);

  Map<String, dynamic> toJson() => _$ApiTerminalToJson(this);
}
