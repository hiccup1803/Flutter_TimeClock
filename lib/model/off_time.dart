import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';
import 'package:staffmonitor/utils/time_utils.dart';

part 'off_time.g.dart';

@JsonSerializable()
@JsonDateTimeConverter()
class OffTime extends Equatable {
  const OffTime(
    this.id,
    this.startAt,
    this.endAt,
    this.note,
    this.type,
    this.days,
    this.year,
    this.status,
    this.createdAt,
    this.updatedAt,
  );

  final int id;
  final String? startAt;
  final String? endAt;
  final String? note;
  final int type; //Type (0 = Short, 1 = Vacation) = ['0', '1'],
  final int days;
  @JsonKey(defaultValue: 2021)
  final int year;
  @JsonKey(name: 'approved')
  final int? status; //0 = czeka/waiting, 1 = ok, 2 = odrzucone/denied
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory OffTime.create(DateTime startAtDate) => OffTime(
        -1,
        startAtDate.format('yyyy-MM-dd'),
        startAtDate.format('yyyy-MM-dd'),
        null,
        0,
        1,
        startAtDate.year,
        0,
        null,
        null,
      );

  bool get isCreate => id < 0;

  DateTime? get startDate => DateTime.tryParse(startAt!);

  DateTime? get endDate => DateTime.tryParse(endAt!);

  bool get isApproved => status == 1;

  bool get isDenied => status == 2;

  bool get isWaiting => status == 0;

  bool get isVacation => type == 1;

  bool get isShort => type == 0;

  OffTime copyWith({
    String? startAt,
    String? endAt,
    int? days,
    int? status,
    String? note,
    int? year,
    int? type,
  }) =>
      OffTime(
        id,
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
      'OffTime{id: $id, startAt: $startAt, endAt: $endAt, note: $note, type: $type, days: $days, year:$year, createdAt: $createdAt, updatedAt: $updatedAt}';

  factory OffTime.fromJson(Map<String, dynamic> json) => _$OffTimeFromJson(json);

  Map<String, dynamic> toJson() => _$OffTimeToJson(this);

  @override
  List<Object?> get props => [
        this.id,
        this.startAt,
        this.endAt,
        this.note,
        this.type,
        this.days,
        this.year,
        this.status,
        this.createdAt,
        this.updatedAt,
      ];
}
