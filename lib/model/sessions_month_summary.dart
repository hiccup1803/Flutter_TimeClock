import 'package:equatable/equatable.dart';
import 'package:staffmonitor/model/session_wage_duration.dart';

class SessionsMonthSummary extends Equatable {
  const SessionsMonthSummary(this.days, this.sessions, this.duration, this.currencyRateWageMap);

  factory SessionsMonthSummary.me() => SessionsMonthSummary(-1, 0, Duration.zero, {});

  final int days;
  final int sessions;
  final Duration duration;
  final Map<String, WageAndDuration> currencyRateWageMap;

  @override
  List<Object> get props => [
        this.days,
        this.sessions,
        this.duration,
        this.currencyRateWageMap,
      ];
}
