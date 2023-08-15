part of 'admin_tasks_cubit.dart';

abstract class AdminTasksState extends Equatable {
  const AdminTasksState();
}

class AdminTasksInitial extends AdminTasksState {
  @override
  List<Object> get props => [];
}

class AdminTasksReady extends AdminTasksState {
  AdminTasksReady(this.selectedDate, this.tasks);

  final DateTime selectedDate;
  final List<CalendarTask>? tasks;

  @override
  List<Object?> get props => [
        this.selectedDate,
        this.tasks,
      ];
}
