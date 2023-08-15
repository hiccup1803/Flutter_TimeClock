import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/service/api/converter/json_bool_converter.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

part 'session_break.g.dart';

@JsonSerializable()
@JsonBoolConverter()
@JsonDateTimeConverter()
@HiveType(typeId: 4)
class SessionBreak extends Equatable {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int? sessionId;
  @HiveField(2)
  final DateTime? start;
  @HiveField(3)
  final DateTime? end;
  @HiveField(4)
  final bool paid;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SessionBreak(
    this.id,
    this.sessionId,
    this.start, {
    this.end,
    this.paid = false,
    this.createdAt,
    this.updatedAt,
  });


  Duration get duration =>  end?.difference(start!) ?? Duration();

  @override
  List<Object?> get props => [
        id,
        sessionId,
        start,
        end,
        paid,
        createdAt,
        updatedAt,
      ];

  factory SessionBreak.fromJson(Map<String, dynamic> json) => _$SessionBreakFromJson(json);

  Map<String, dynamic> toJson() => _$SessionBreakToJson(this);

  SessionBreak copyWith({DateTime? end, bool? paid}) {
    return SessionBreak(
      id,
      sessionId,
      start,
      end: end ?? this.end,
      paid: paid ?? this.paid,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    );
  }
}
