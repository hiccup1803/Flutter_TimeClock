import 'package:equatable/equatable.dart';
import 'package:staffmonitor/model/admin_session.dart';
import 'package:staffmonitor/model/session_wage_duration.dart';

import 'session.dart';

class EmployeeSummary extends Equatable {
  const EmployeeSummary(this.userId, this.sessions, {this.currencyRateWageMap = const {}});

  factory EmployeeSummary.me() => EmployeeSummary(-1, const []);

  final int userId;
  final List<Session> sessions;
  final Map<String, Map<String, WageAndDuration>> currencyRateWageMap;

  WageAndDuration perCurrency(String currency) {
    var map = currencyRateWageMap[currency.toUpperCase()] ?? {};
    if (map.isNotEmpty) {
      return map.values.reduce((value, element) => value + element);
    }
    return WageAndDuration();
  }

  Duration get duration {
    return currencyRateWageMap.values
        .toSet()
        .expand((element) => element.values)
        .reduce((value, element) => value + element)
        .duration;
  }

  EmployeeSummary addSession(AdminSession session) {
    if (session.userId == userId) {
      return addMySession(session);
    }

    return EmployeeSummary(
      userId,
      sessions,
      currencyRateWageMap: currencyRateWageMap,
    );
  }

  EmployeeSummary addMySession(Session session) {
    String sessionCurrency = session.rateCurrency?.toUpperCase() ?? '';
    String sessionHourRate = session.hourRate ?? '0.00';
    var currencyMap = Map.of(currencyRateWageMap);
    Map<String, WageAndDuration> rateMap = Map.of(currencyRateWageMap[sessionCurrency] ?? {});
    WageAndDuration wageDuration = rateMap[sessionHourRate] ?? WageAndDuration();

    rateMap[sessionHourRate] = wageDuration.add(session);
    currencyMap[sessionCurrency] = rateMap;
    return EmployeeSummary(
      userId,
      [
        ...sessions,
        session,
      ],
      currencyRateWageMap: currencyMap,
    );
  }

  @override
  List<Object?> get props => [
        this.userId,
        this.currencyRateWageMap,
      ];

  @override
  String toString() {
    return 'EmployeeSummary{userId: $userId, wage: $currencyRateWageMap}';
  }
}