part of 'my_sessions_cubit.dart';

abstract class MySessionsState extends Equatable {
  const MySessionsState();
}

class SessionsInitial extends MySessionsState {
  @override
  List<Object> get props => [];
}

class SessionsReady extends MySessionsState {
  final DateTime selectedDate;
  final Project? selectedProject;
  final Loadable<Session?> currentSession;
  final Loadable<List<SessionsDaySummary>> monthSessionDaySummaries;
  final Loadable<SessionsMonthSummary> monthSummary;
  final Loadable<List<EmployeeSummary>> earningSummaries;
  final bool hasLocationPermission;

  SessionsReady(
    this.selectedDate,
    this.selectedProject,
    this.currentSession,
    this.monthSessionDaySummaries,
    this.monthSummary,
    this.earningSummaries,
    this.hasLocationPermission,
  );

  @override
  List<Object?> get props => [
        this.selectedDate,
        this.selectedProject,
        this.currentSession,
        this.monthSessionDaySummaries,
        this.monthSummary,
        this.earningSummaries,
        this.hasLocationPermission,
      ];
}
