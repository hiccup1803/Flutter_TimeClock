import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

import 'wage.dart';

part 'sessions_summary.g.dart';

@JsonSerializable()
@JsonDateTimeConverter()
class SessionsSummary extends Equatable {
  final int? userId;
  final DateTime? from;
  final DateTime? to;
  final int? projectId;
  final int? summary;
  @JsonKey(name: 'sessions')
  final int? sessionsCount;
  final List<Wage> wages;

  Duration get duration => Duration(seconds: summary ?? 0);

  static SessionsSummary get empty => SessionsSummary(-1, null, null, -1, 0, 0, List.empty());

  @override
  String toString() =>
      'SessionsSummary{userId: $userId, from: $from, to: $to, projectId: $projectId, summary: $summary, sessionsCount: $sessionsCount}';

  factory SessionsSummary.fromJson(Map<String, dynamic> json) => _$SessionsSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$SessionsSummaryToJson(this);

  SessionsSummary(
    this.userId,
    this.from,
    this.to,
    this.projectId,
    this.summary,
    this.sessionsCount,
    this.wages,
  );

  @override
  List<Object?> get props => [
        this.userId,
        this.from,
        this.to,
        this.projectId,
        this.summary,
        this.sessionsCount,
        this.wages,
      ];
}
