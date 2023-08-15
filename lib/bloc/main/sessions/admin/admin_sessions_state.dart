part of 'admin_sessions_cubit.dart';

abstract class AdminSessionsState extends Equatable {
  const AdminSessionsState();
}

class AdminSessionsInitial extends AdminSessionsState {
  @override
  List<Object> get props => [];
}

class AdminSessionsReady extends AdminSessionsState {
  AdminSessionsReady(this.selectedDate, this.monthSummary, this.userSummaries,
      this.monthSessionDaySummaries, this.users);

  final DateTime selectedDate;
  final Loadable<List<Profile>?> users;
  final Loadable<SessionsMonthSummary> monthSummary;
  final Loadable<List<EmployeeSummary>> userSummaries;
  final Loadable<List<SessionsDaySummary<AdminSession>>> monthSessionDaySummaries;

  @override
  List<Object?> get props => [
        this.selectedDate,
        this.monthSummary,
        this.userSummaries,
        this.monthSessionDaySummaries,
        this.users,
      ];
}
