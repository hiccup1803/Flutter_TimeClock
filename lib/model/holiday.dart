import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'holiday.g.dart';

@JsonSerializable()
class Holiday extends Equatable {
  Holiday(this.year, this.month, this.day);

  final int? year;
  final int? month;
  final int? day;

  @override
  String toString() => 'Holiday{year: $year, month: $month, day: $day}';

  factory Holiday.fromJson(Map<String, dynamic> json) => _$HolidayFromJson(json);

  Map<String, dynamic> toJson() => _$HolidayToJson(this);

  @override
  List<Object?> get props => [this.year, this.month, this.day];
}
