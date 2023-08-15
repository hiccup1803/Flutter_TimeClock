import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_customfiled.g.dart';

@JsonSerializable()
class TaskCustomFiled extends Equatable {
  TaskCustomFiled(this.fieldId, this.name, this.value, this.type,
      {this.option, this.available = true});

  final int fieldId;
  final String name;
  final dynamic value;
  final String type;
  List<String>? option;
  bool? available;

  factory TaskCustomFiled.create(String value) => TaskCustomFiled(-1, '', '', '');

  bool get isCreate => fieldId < 0;

  TaskCustomFiled copyWith({int? taskId, String? name, String? value, String? type}) =>
      TaskCustomFiled(
        fieldId,
        name ?? this.name,
        value ?? this.value,
        type ?? this.type,
      );

  @override
  String toString() =>
      'TaskCustomFiled{fieldId: $fieldId, name: $name, value: $value, type: $type}';

  factory TaskCustomFiled.fromJson(Map<String, dynamic> json) => _$TaskCustomFiledFromJson(json);

  Map<String, dynamic> toJson() => _$TaskCustomFiledToJson(this);

  @override
  List<Object?> get props => [
        this.fieldId,
        this.name,
        this.value,
        this.type,
        this.option,
        this.available,
      ];
}
