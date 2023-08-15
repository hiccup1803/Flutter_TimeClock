import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/model/off_time.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';
import 'package:staffmonitor/utils/time_utils.dart';

part 'admin_off_time.g.dart';

@JsonSerializable()
@JsonDateTimeConverter()
class AdminOffTime extends OffTime {
  AdminOffTime(
    int id,
    this.userId,
    String? startAt,
    String? endAt,
    String? note,
    int type,
    int days,
    int year,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  ) : super(
          id,
          startAt,
          endAt,
          note,
          type,
          days,
          year,
          status,
          createdAt,
          updatedAt,
        );

  final int userId;

  factory AdminOffTime.create(int userId, DateTime startAtDate) => AdminOffTime(
      -1,
      userId,
      startAtDate.format('yyyy-MM-dd'),
      startAtDate.format('yyyy-MM-dd'),
      null,
      0,
      1,
      startAtDate.year,
      0,
      null,
      null);

  AdminOffTime copyWith(
          {int? userId,
          String? startAt,
          String? endAt,
          int? days,
          int? status,
          String? note,
          int? year,
          int? type}) =>
      AdminOffTime(
        this.id,
        userId ?? this.userId,
        startAt ?? this.startAt,
        endAt ?? this.endAt,
        note ?? this.note,
        type ?? this.type,
        days ?? this.days,
        year ?? this.year,
        status ?? this.status,
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'OffTime{id: $id, startAt: $startAt, endAt: $endAt, note: $note, type: $type, days: $days, createdAt: $createdAt, updatedAt: $updatedAt}';

  factory AdminOffTime.fromJson(Map<String, dynamic> json) => _$AdminOffTimeFromJson(json);

  Map<String, dynamic> toJson() => _$AdminOffTimeToJson(this);

  @override
  List<Object?> get props => [
        this.id,
        this.userId,
        this.startAt,
        this.endAt,
        this.note,
        this.type,
        this.days,
        this.status,
        this.createdAt,
        this.updatedAt,
      ];
}
