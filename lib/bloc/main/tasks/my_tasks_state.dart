part of 'my_tasks_cubit.dart';

abstract class MyTasksState extends Equatable {
  const MyTasksState();
}

class MyTasksInitial extends MyTasksState {
  @override
  List<Object> get props => [];
}

class MyTasksReady extends MyTasksState {
  MyTasksReady(this.selectedDate, this.tasks);

  final DateTime selectedDate;
  final List<CalendarTask>? tasks;

  @override
  List<Object?> get props => [
        this.selectedDate,
        this.tasks,
      ];
}