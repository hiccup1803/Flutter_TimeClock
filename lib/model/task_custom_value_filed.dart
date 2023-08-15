import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'task_custom_value_filed.g.dart';

@JsonSerializable()
class TaskCustomValueFiled extends Equatable {
  const TaskCustomValueFiled(
    this.fieldId,
    this.value,
  );

  final int fieldId;
  final dynamic value;

  factory TaskCustomValueFiled.create(String value) => TaskCustomValueFiled(-1, '');

  bool get isCreate => fieldId < 0;

  TaskCustomValueFiled copyWith({int? taskId, String? name, String? value, String? type}) =>
      TaskCustomValueFiled(
        fieldId,
        value ?? this.value,
      );

  @override
  String toString() =>
      'TaskCustomValueFiled{fieldId: $fieldId, value: $value, }';

  factory TaskCustomValueFiled.fromJson(Map<String, dynamic> json) => _$TaskCustomValueFiledFromJson(json);

  Map<String, dynamic> toJson() => _$TaskCustomValueFiledToJson(this);

  @override
  List<Object?> get props => [
        this.fieldId,
        this.value,
      ];
}