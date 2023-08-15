import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

// import 'package:staffmonitor/model/task_file.dart';
import 'package:staffmonitor/model/app_file.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

part 'calendar_note.g.dart';

@JsonSerializable()
@JsonDateTimeConverter()
class CalendarNote extends Equatable {
  const CalendarNote(
    this.id,
    this.taskId,
    this.author,
    this.editor,
    this.note,
    this.file,
    this.createdAt,
    this.updatedAt,
  );

  final int id;
  final int? taskId;
  final String? author;
  final String? editor;
  final String? note; //Type (0 = Short, 1 = Vacation) = ['0', '1'],
  final AppFile? file;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CalendarNote.create(String value) =>
      CalendarNote(-1, -1, '', '', value, null, null, null);

  bool get isCreate => id < 0;

  CalendarNote copyWith(
          {int? taskId, String? author, String? editor, String? note, AppFile? file}) =>
      CalendarNote(
        id,
        taskId ?? this.taskId,
        author ?? this.author,
        editor ?? this.editor,
        note ?? this.note,
        file ?? this.file,
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'CalendarNote{id: $id, taskId: $taskId, author: $author, editor: $editor, note: $note, file: $file, createdAt: $createdAt, updatedAt: $updatedAt}';

  factory CalendarNote.fromJson(Map<String, dynamic> json) => _$CalendarNoteFromJson(json);

  Map<String, dynamic> toJson() => _$CalendarNoteToJson(this);

  @override
  List<Object?> get props => [
        this.id,
        this.taskId,
        this.author,
        this.editor,
        this.note,
        this.file,
        this.createdAt,
        this.updatedAt,
      ];
}
