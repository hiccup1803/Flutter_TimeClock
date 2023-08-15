part of 'admin_terminals_cubit.dart';

abstract class AdminTerminalsState extends Equatable {
  const AdminTerminalsState();
}

class AdminTerminalsInitial extends AdminTerminalsState {
  @override
  List<Object> get props => [];
}

class AdminTerminalsReady extends AdminTerminalsState {
  final Loadable<List<Profile>> users;
  final Loadable<List<AdminTerminal>> terminals;
  final Loadable<List<AdminTerminal>> terminalsList;

  const AdminTerminalsReady(this.users, this.terminals, this.terminalsList);

  @override
  List<Object?> get props => [this.terminals, this.terminalsList, this.users];
}