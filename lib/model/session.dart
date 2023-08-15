import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/model/app_file.dart';
import 'package:staffmonitor/service/api/converter/json_bool_converter.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

import 'multiplier.dart';
import 'project.dart';
import 'wage.dart';

part 'session.g.dart';

String fallbackWage(json) {

  return json is! String ? json.toString() : json.toString();
}

@JsonSerializable()
@JsonBoolConverter()
@JsonDateTimeConverter()
@HiveType(typeId: 3)
class Session extends Equatable {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final bool verified;
  @HiveField(2)
  final DateTime? clockIn;
  @HiveField(3)
  final DateTime? clockInProposed;
  @HiveField(4)
  final DateTime? clockOut;
  @HiveField(5)
  final DateTime? clockOutProposed;
  @HiveField(6)
  final String? note;
  @HiveField(7)
  final Project? project;
  @JsonKey(defaultValue: const [], toJson: null, includeIfNull: false)
  @HiveField(8)
  final List<AppFile> files;
  @HiveField(9)
  final String? bonus;
  @HiveField(10)
  final String? bonusProposed;
  @HiveField(11)
  final String? hourRate;
  @HiveField(12)
  final String? rateCurrency;
  @JsonKey(fromJson: fallbackWage)
  @HiveField(13)
  final String? totalWage;

  ///Whether this session is calculated for overtime or scheduled for one (0 = Scheduled, 1 = Already Calculated) (if Overtime available) = ['0', '1'],
  ///
  @HiveField(14)
  final bool? calculated;

  ///Binary Combination of Applied Overtime (0 = None, 2 = Daily, 4 = Weekly, 8 = Sunday, 16 = Monthly, and combination) (if Overtime available)
  @HiveField(15)
  final bool? overtime;
  @HiveField(16)
  final List<Multiplier>? multiplier;
  @HiveField(17)
  final DateTime? createdAt;
  @HiveField(18)
  final DateTime? updatedAt;

  @JsonKey(ignore: true)
  Duration? get duration => clockOut?.difference(clockIn!);

  @JsonKey(ignore: true)
  bool get isCreate => id < -1;

  factory Session.empty() => Session(-1, false, null, null, null, null, null, null, null, null,
      null, null, null, null, null, [], [], null, null);

  factory Session.create({int? id, DateTime? clockIn, Project? project, Wage? wage}) => Session(
        id ?? -2,
        false,
        clockIn ?? DateTime.now(),
        null,
        null,
        null,
        '',
        project,
        null,
        null,
        wage?.wage,
        wage?.currency,
        null,
        null,
        null,
        [],
        [],
        DateTime.now(),
        DateTime.now(),
      );

  @override
  String toString() =>
      'Session{id: $id, verified: $verified, clockIn: $clockIn, clockInProposed: $clockInProposed, clockOut: $clockOut, clockOutProposed: $clockOutProposed, note: $note, project: $project, bonus: $bonus, bonusProposed: $bonusProposed, hourRate: $hourRate, rateCurrency: $rateCurrency, totalWage: $totalWage, overtime: $overtime, multiplier: $multiplier, createdAt: $createdAt, updatedAt: $updatedAt, files: $files}';

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);

  Map<String, dynamic> toJson() => _$SessionToJson(this);

  Session copyWith({
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
    return Session(
      id,
      verified,
      clockIn ?? this.clockIn,
      clockInProposed ?? this.clockInProposed,
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
      updatedAt,
    );
  }

  const Session(
    this.id,
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
  );

  @override
  List<Object?> get props => [
        this.id,
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

@JsonSerializable()
@JsonDateTimeConverter()
class ApiSession {
  final int? defaultProject;
  final int? projectId;
  @JsonKey(includeIfNull: false)
  final DateTime? clockIn;
  @JsonKey(includeIfNull: false)
  final DateTime? clockOut;
  @JsonKey(includeIfNull: false)
  final String? note;
  @JsonKey(includeIfNull: false)
  final String? bonus;
  @JsonKey(includeIfNull: false)
  final String? newProject;
  @JsonKey(includeIfNull: false)
  final String? color;
  @JsonKey(includeIfNull: false)
  final String? hourRate;
  @JsonKey(includeIfNull: false)
  final String? rateCurrency;
  final String source;

  ApiSession(
    this.projectId,
    this.source,
    this.clockIn, {
    this.note,
    this.bonus,
    this.clockOut,
    this.defaultProject = 0,
    this.newProject,
    this.color,
    this.hourRate,
    this.rateCurrency,
  });

  factory ApiSession.fromSession(Session session,
          [Project? ownProject, String? hourRate, String? currency]) =>
      ApiSession(
        ownProject != null ? null : session.project?.id,
        'mobile',
        session.clockIn,
        clockOut: session.clockOut,
        note: session.note,
        bonus: session.bonus,
        newProject: ownProject?.name,
        color: ownProject?.colorHash,
        hourRate: hourRate,
        rateCurrency: currency,
      );

  factory ApiSession.fromJson(Map<String, dynamic> json) => _$ApiSessionFromJson(json);

  Map<String, dynamic> toJson() => _$ApiSessionToJson(this);
}
