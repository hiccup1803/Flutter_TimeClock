import 'package:equatable/equatable.dart';
import 'package:staffmonitor/model/session.dart';


class SessionsDaySummary<T extends Session> extends Equatable {
  SessionsDaySummary({this.day, required this.count, required this.time, required this.sessions});

  final DateTime? day;
  final int count;
  final Duration time;
  final List<T> sessions;

  @override
  List<Object?> get props => [this.day, this.count, this.time, this.sessions];
}
