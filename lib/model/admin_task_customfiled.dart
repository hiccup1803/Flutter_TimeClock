import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/model/task_customfiled.dart';

part 'admin_task_customfiled.g.dart';

@JsonSerializable()
class AdminTaskCustomFiled extends Equatable {
  const AdminTaskCustomFiled(
    this.id,
    this.name,
    this.type,
    this.available,
    this.target,
    this.extra,
  );

  final int id;
  final String name;
  final String type;
  final bool available;
  final String target;
  final String? extra;

  factory AdminTaskCustomFiled.create(String value) =>
      AdminTaskCustomFiled(-1, '', '', true, '', '');

  AdminTaskCustomFiled copyWith({
    int? taskId,
    String? name,
    String? type,
    bool? available,
    String? target,
    String? extra,
  }) =>
      AdminTaskCustomFiled(
        id,
        name ?? this.name,
        type ?? this.type,
        available ?? this.available,
        target ?? this.target,
        extra ?? this.extra,
      );

  @override
  String toString() =>
      'AdminTaskCustomFiled{id: $id, name: $name, type: $type,available: $available, target: $target,extra: $extra}';

  factory AdminTaskCustomFiled.fromJson(Map<String, dynamic> json) =>
      _$AdminTaskCustomFiledFromJson(json);

  Map<String, dynamic> toJson() => _$AdminTaskCustomFiledToJson(this);

  @override
  List<Object?> get props => [
        this.id,
        this.name,
        this.type,
        this.available,
        this.target,
        this.extra,
      ];
}
