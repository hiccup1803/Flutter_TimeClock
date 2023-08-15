part of 'calendars_cubit.dart';

abstract class CalendarsState extends Equatable {
  const CalendarsState();
}

class CalendarsInitial extends CalendarsState {
  @override
  List<Object> get props => [];
}

class CalendarsReady extends CalendarsState {
  CalendarsReady(this.month, this.offTimes, this.sessions, this.tasks, this.filter);

  final DateTime? month;
  final Loadable<Map<DateTime, List>> offTimes;
  final Loadable<Paginated> sessions;
  final List<CalendarTask>? tasks;
  final List<bool>? filter;

  @override
  List<Object?> get props => [this.month, this.offTimes, this.sessions, this.tasks, this.filter];

  @override
  String toString() {
    return 'ProjectsReady{month: $month}';
  }
}

class CalendarsLoading extends CalendarsReady {
  CalendarsLoading(
      DateTime? month,
      Loadable<Map<DateTime, List>> list,
      Loadable<Paginated> sessions,
      Map<int?, SessionsSummary> summaries,
      List<CalendarTask>? tasks,
      List<bool>? filter)
      : super(month, list, sessions, tasks, filter);

  @override
  String toString() {
    return 'ProjectsReady{month: $month}';
  }
}
