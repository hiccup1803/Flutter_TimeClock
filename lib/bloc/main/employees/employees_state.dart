part of 'employees_cubit.dart';

abstract class EmployeesState extends Equatable {
  const EmployeesState();
}

class EmployeesInitial extends EmployeesState {
  @override
  List<Object> get props => [];
}

class EmployeesReady extends EmployeesState {
  final Loadable<List<Invitation>?> invitations;
  final Loadable<Paginated<Profile>> users;

  EmployeesReady(this.invitations, this.users);

  @override
  List<Object> get props => [this.invitations, this.users];
}
