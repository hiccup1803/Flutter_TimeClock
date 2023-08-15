import 'package:equatable/equatable.dart';
import 'package:staffmonitor/model/session.dart';

class WageAndDuration extends Equatable {
  final String wage;
  final String bonus;
  final String rateHour;
  final Duration duration;

  const WageAndDuration({
    this.wage = '0',
    this.bonus = '0',
    this.rateHour = '0',
    this.duration = const Duration(),
  });

  double get wageDouble => double.tryParse(wage) ?? 0;

  double get bonusDouble => double.tryParse(bonus) ?? 0;

  @override
  List<Object?> get props => [wage, bonus, rateHour, duration];

  WageAndDuration add(Session session) {
    return WageAndDuration(
        wage: (wageDouble + (double.tryParse(session.totalWage ?? '0') ?? 0)).toStringAsFixed(2),
        bonus: (bonusDouble + (double.tryParse(session.bonus ?? '0') ?? 0)).toStringAsFixed(2),
        rateHour: session.hourRate ?? '0',
        duration: duration + (session.duration ?? Duration()),
    );
  }

  operator +(WageAndDuration other) {
    return WageAndDuration(
      wage: (wageDouble + other.wageDouble).toStringAsFixed(2),
      bonus: (bonusDouble + other.bonusDouble).toStringAsFixed(2),
      duration: duration + other.duration,
    );
  }
}
