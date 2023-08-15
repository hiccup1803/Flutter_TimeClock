import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/model/task_custom_value_filed.dart';
import 'package:staffmonitor/service/api/converter/json_bool_converter.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

import 'calendar_note.dart';
import 'project.dart';
import 'task_customfiled.dart';

part 'calendar_task.g.dart';

@JsonSerializable()
@JsonBoolConverter()
@JsonDateTimeConverter()
class CalendarTask extends Equatable {
  final int id;
  final DateTime? start;
  final DateTime? end;
  final String? title;
  final bool wholeDay;
  final String? location;
  @JsonKey(defaultValue: 0)
  final int? status; //Status (0 = Open, 1 = Closed)
  final Project? project;
  @JsonKey(defaultValue: const [])
  final List<CalendarNote> notes;
  @JsonKey(defaultValue: const [])
  final List<int> assignees;
  final List<TaskCustomFiled> customFields;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? priority; //Status (0 = Low, 1 = Medium, 2 = High)
  final int? authorId;

  @JsonKey(ignore: true)
  bool get isCreate => id < -1;

  String get pr => priority == 0
      ? 'LOW'
      : priority == 1
          ? 'MEDIUM'
          : 'HIGH';

  @override
  String toString() =>
      'CalendarTask{id: $id, start: $start, end: $end, title: $title, wholeDay: $wholeDay, location: $location, '
      'status: $status, project: $project, note: $notes, createdAt: $createdAt, updateAt: $updatedAt,assignees: $assignees,customFields: $customFields,priority: $priority,authorId: $authorId}';

  factory CalendarTask.create(DateTime startAtDate, List<TaskCustomFiled> customFieldList) =>
      CalendarTask(-2, startAtDate, startAtDate, '', true, '', 0, Project.noProject, [], null, null,
          [], customFieldList, 0, 0);

  factory CalendarTask.withId(int id) => CalendarTask(
      id, null, null, '', true, '', -1, Project.noProject, [], null, null, [], [], 0, 0);

  factory CalendarTask.fromJson(Map<String, dynamic> json) => _$CalendarTaskFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarTaskToJson(this);

  CalendarTask copyWith({
    int? id,
    DateTime? start,
    DateTime? end,
    String? title,
    bool? wholeDay,
    String? location,
    int? status, //Status (0 = Registered, 1 = Active, 9 = Deleted)
    Project? project,
    List<CalendarNote>? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<int>? assignees,
    List<TaskCustomFiled>? customFields,
    int? priority,
    int? authorId,
  }) {
    return CalendarTask(
      id ?? this.id,
      start ?? this.start,
      end ?? this.end,
      title ?? this.title,
      wholeDay ?? this.wholeDay,
      location ?? this.location,
      status ?? this.status,
      project ?? this.project,
      notes ?? this.notes,
      createdAt ?? this.createdAt,
      updatedAt ?? this.updatedAt,
      assignees ?? this.assignees,
      customFields ?? this.customFields,
      priority ?? this.priority,
      authorId ?? this.authorId,
    );
  }

  CalendarTask(
    this.id,
    this.start,
    this.end,
    this.title,
    this.wholeDay,
    this.location,
    this.status,
    this.project,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.assignees,
    this.customFields,
    this.priority,
    this.authorId,
  );

  @override
  List<Object?> get props => [
        this.id,
        this.start,
        this.end,
        this.title,
        this.wholeDay,
        this.location,
        this.status,
        this.project,
        this.notes,
        this.createdAt,
        this.updatedAt,
        this.assignees,
        this.customFields,
        this.priority,
        this.authorId,
      ];
}

@JsonSerializable()
@JsonDateTimeConverter()
@JsonBoolConverter()
class ApiCalendarTask {
  final String? title;
  final DateTime? start;
  @JsonKey(includeIfNull: false)
  final List<int>? assignees;
  @JsonKey(includeIfNull: false)
  final DateTime? end;
  @JsonKey(includeIfNull: false)
  final int? wholeDay;
  @JsonKey(includeIfNull: false)
  final String? location;
  @JsonKey(includeIfNull: false)
  final int? projectId;
  @JsonKey(includeIfNull: false)
  final String? newProject;
  @JsonKey(includeIfNull: false)
  final String? projectColor;
  @JsonKey(includeIfNull: false)
  final int? sendEmail;
  @JsonKey(includeIfNull: false)
  final int? sendPush;
  @JsonKey(includeIfNull: false)
  final int? sendImmediately;
  @JsonKey(includeIfNull: false)
  final int? status;
  @JsonKey(includeIfNull: false)
  final int? priority;
  @JsonKey(includeIfNull: false)
  final List<TaskCustomValueFiled>? customFields;

  ApiCalendarTask(
    this.title,
    this.start,
    this.assignees, {
    this.end,
    this.wholeDay,
    this.location,
    this.projectId,
    this.newProject,
    this.projectColor,
    this.sendEmail,
    this.sendPush,
    this.sendImmediately,
    this.status,
    this.priority,
    this.customFields,
  });

  factory ApiCalendarTask.fromCalendarTask(
          CalendarTask task,
          List<int>? assignee,
          int? sendEmail,
          int? sendImmediately,
          int? sendPush,
          int? status,
          int? priority,
          List<TaskCustomValueFiled>? list) =>
      ApiCalendarTask(task.title, task.start, assignee,
          end: task.end,
          location: task.location,
          newProject: null,
          projectColor: null,
          projectId: task.project?.id == Project.noProject.id ? null : task.project?.id,
          sendEmail: sendEmail,
          sendImmediately: sendImmediately,
          sendPush: sendPush,
          wholeDay: JsonBoolConverter().toJson(task.wholeDay),
          status: status,
          priority: priority,
          customFields: list);

  factory ApiCalendarTask.fromJson(Map<String, dynamic> json) => _$ApiCalendarTaskFromJson(json);

  Map<String, dynamic> toJson() => _$ApiCalendarTaskToJson(this);
}

@JsonSerializable()
@JsonDateTimeConverter()
@JsonBoolConverter()
class ApiUserTask {
  @JsonKey(includeIfNull: false)
  final int? status;
  @JsonKey(includeIfNull: false)
  final int? priority;

  ApiUserTask({
    this.status,
    this.priority,
  });

  factory ApiUserTask.fromCalendarTask(int? status, int? priority) => ApiUserTask(
        status: status,
        priority: priority,
      );

  factory ApiUserTask.fromJson(Map<String, dynamic> json) => _$ApiUserTaskFromJson(json);

  Map<String, dynamic> toJson() => _$ApiUserTaskToJson(this);
}
