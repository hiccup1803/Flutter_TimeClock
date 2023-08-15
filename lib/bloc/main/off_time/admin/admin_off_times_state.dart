part of 'admin_off_times_cubit.dart';

abstract class AdminOffTimesState extends Equatable {
  final DateTime selectedDate;

  AdminOffTimesState(this.selectedDate);
}

class AdminOffTimesInitial extends AdminOffTimesState {
  AdminOffTimesInitial() : super(DateTime(1999));

  @override
  List<Object> get props => [];
}

class AdminOffTimesReady extends AdminOffTimesState {
  AdminOffTimesReady(DateTime month, this.offTimes, this.users) : super(month);

  final Loadable<List<AdminOffTime>> offTimes;
  final Loadable<List<Profile>> users;

  @override
  List<Object?> get props => [offTimes, users, selectedDate];
}
