import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/model/app_file.dart';
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/service/api/converter/json_bool_converter.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

import 'multiplier.dart';
import 'project.dart';

part 'admin_session.g.dart';

@JsonSerializable()
@JsonBoolConverter()
@JsonDateTimeConverter()
class AdminSession extends Session {
  final int userId;

  factory AdminSession.empty() => AdminSession(-1, -1, false, null, null, null, null, null, null,
      null, null, null, null, null, null, null, [], [], null, null);

  factory AdminSession.create({DateTime? clockIn, Project? project}) => AdminSession(
      -2,
      -1,
      false,
      clockIn ?? DateTime.now(),
      null,
      null,
      null,
      '',
      project,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      [],
      [],
      null,
      null);

  @override
  String toString() =>
      'Session{id: $id, verified: $verified, clockIn: $clockIn, clockInProposed: $clockInProposed, clockOut: $clockOut, clockOutProposed: $clockOutProposed, note: $note, project: $project, bonus: $bonus, bonusProposed: $bonusProposed, hourRate: $hourRate, rateCurrency: $rateCurrency, totalWage: $totalWage, overtime: $overtime, multiplier: $multiplier, createdAt: $createdAt, updatedAt: $updatedAt, files: $files}';

  factory AdminSession.fromJson(Map<String, dynamic> json) => _$AdminSessionFromJson(json);

  Map<String, dynamic> toJson() => _$AdminSessionToJson(this);

  AdminSession copyWith({
    int? userId,
    DateTime? clockIn,
    DateTime? clockInNew,
    Project? project,
    bool clearProject = false,
    DateTime? clockOut,
    DateTime? clockOutNew,
    bool clearClockOut = false,
    String? note,
    String? hourRate,
    String? rateCurrency,
    String? bonus,
    String? bonusNew,
    List<AppFile>? files,
  }) {
    return AdminSession(
        id,
        userId ?? this.userId,
        verified,
        clockIn ?? this.clockIn,
        clockInNew ?? this.clockInProposed,
        clearClockOut ? null : (clockOut ?? this.clockOut),
        clearClockOut ? null : (clockOutNew ?? this.clockOutProposed),
        note ?? this.note,
        clearProject ? null : (project ?? this.project),
        bonus ?? this.bonus,
        bonusNew ?? this.bonusProposed,
        hourRate ?? this.hourRate,
        rateCurrency ?? this.rateCurrency,
        totalWage,
        calculated,
        overtime,
        multiplier,
        files ?? this.files,
        createdAt,
        updatedAt);
  }

  const AdminSession(
    int id,
    this.userId,
    bool verified,
    DateTime? clockIn,
    DateTime? clockInProposed,
    DateTime? clockOut,
    DateTime? clockOutProposed,
    String? note,
    Project? project,
    String? bonus,
    String? bonusProposed,
    String? hourRate,
    String? rateCurrency,
    String? totalWage,
    bool? calculated,
    bool? overtime,
    List<Multiplier>? multiplier,
    List<AppFile> files,
    DateTime? createdAt,
    DateTime? updatedAt,
  ) : super(
            id,
            verified,
            clockIn,
            clockInProposed,
            clockOut,
            clockOutProposed,
            note,
            project,
            bonus,
            bonusProposed,
            hourRate,
            rateCurrency,
            totalWage,
            calculated,
            overtime,
            multiplier,
            files,
            createdAt,
            updatedAt);

  @override
  List<Object?> get props => [
        this.id,
        this.userId,
        this.verified,
        this.clockIn,
        this.clockInProposed,
        this.clockOut,
        this.clockOutProposed,
        this.note,
        this.project,
        this.bonus,
        this.bonusProposed,
        this.hourRate,
        this.rateCurrency,
        this.totalWage,
        this.calculated,
        this.overtime,
        this.multiplier,
        this.files,
        this.createdAt,
        this.updatedAt,
      ];
}
