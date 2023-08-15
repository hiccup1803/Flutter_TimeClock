part of 'my_off_times_cubit.dart';

abstract class MyOffTimesState extends Equatable {
  final DateTime selectedDate;

  MyOffTimesState(this.selectedDate);
}

class MyOffTimesInitial extends MyOffTimesState {
  MyOffTimesInitial() : super(DateTime(1999));

  @override
  List<Object> get props => [];
}

class MyOffTimesReady extends MyOffTimesState {
  MyOffTimesReady(DateTime month, this.offTimes) : super(month);

  final Loadable<List<OffTime>> offTimes;

  @override
  List<Object?> get props => [offTimes, selectedDate];
}
