import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

part 'user_history.g.dart';

@JsonSerializable()
@JsonDateTimeConverter()
class UserHistory extends Equatable {
  const UserHistory(
    this.username,
    this.currentSessionStartedAt,
    this.lastWeek,
    this.currentMonthSeconds,
    this.previousMonthSeconds,
    this.photoVerification,
  );

  final String username;
  @JsonKey(name: 'current')
  final DateTime? currentSessionStartedAt;
  final Map<DateTime, int> lastWeek;
  @JsonKey(name: 'currentMonth')
  final int currentMonthSeconds;
  @JsonKey(name: 'previousMonth')
  final int previousMonthSeconds; //possibly string
  @JsonKey(name: 'photoVerification')
  final int photoVerification;

  factory UserHistory.fromJson(Map<String, dynamic> json) => _$UserHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$UserHistoryToJson(this);

  @override
  String toString() =>
      'UserHistory{username: $username, currentSessionStartedAt: $currentSessionStartedAt, lastWeek: $lastWeek, currentMonthSeconds: $currentMonthSeconds, previousMonthSeconds: $previousMonthSeconds,photoVerification:$photoVerification}';

  @override
  List<Object?> get props => [
        this.username,
        this.currentSessionStartedAt,
        this.lastWeek,
        this.currentMonthSeconds,
        this.previousMonthSeconds,
        this.photoVerification,
      ];
}
