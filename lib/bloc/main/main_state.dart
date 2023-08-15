part of 'main_cubit.dart';

abstract class MainState extends Equatable {
  final int selected;
  final bool adminContext;
  final bool isAnyMessageUnread;
  final String title;

  const MainState(this.selected, this.title, this.adminContext, this.isAnyMessageUnread);

  @override
  List<Object> get props => [selected, title, adminContext, isAnyMessageUnread];
}

class MainInitial extends MainState {
  const MainInitial() : super(-1, '', false, false);
}

class MainMyStartStop extends MainState {
  final bool isAnyMessageUnread;

  MainMyStartStop(this.isAnyMessageUnread) : super(0, 'Start', false, isAnyMessageUnread);
}

class MainMyTasks extends MainState {
  final bool isAnyMessageUnread;

  const MainMyTasks(this.isAnyMessageUnread) : super(1, 'Tasks', false, isAnyMessageUnread);
}

class MainMySessions extends MainState {
  final bool isAnyMessageUnread;

  const MainMySessions(this.isAnyMessageUnread) : super(2, 'Sessions', false, isAnyMessageUnread);
}

class MainMyOffTimes extends MainState {
  final bool isAnyMessageUnread;

  const MainMyOffTimes(this.isAnyMessageUnread) : super(4, 'Off-times', false, isAnyMessageUnread);
}

class MainMyProjects extends MainState {
  final bool isAnyMessageUnread;

  const MainMyProjects(this.isAnyMessageUnread) : super(2, 'Projects', false, isAnyMessageUnread);
}

class MainMyCalendars extends MainState {
  final bool isAnyMessageUnread;

  const MainMyCalendars(this.isAnyMessageUnread) : super(3, 'Calendar', false, isAnyMessageUnread);
}

class MainCalendars extends MainState {
  final bool isSupervisor;
  final bool isSupervisorCalanderAccess;

  const MainCalendars({this.isSupervisor = false, this.isSupervisorCalanderAccess = false})
      : super(isSupervisor && isSupervisorCalanderAccess ? 1 : 3, 'Calendar', true, false);
}

class MainSettings extends MainState {
  const MainSettings() : super(3, 'Settings', false, false);
}

class MainTasks extends MainState {
  const MainTasks(this.isAnyMessageUnread) : super(0, 'Tasks', true, isAnyMessageUnread);

  final bool isAnyMessageUnread;

  @override
  List<Object> get props => super.props + [isAnyMessageUnread];
}

class MainEmployees extends MainState {
  const MainEmployees(this.isAnyMessageUnread, {this.users = false, this.invites = true})
      : super(4, 'Employees', true, isAnyMessageUnread);

  final bool users;
  final bool invites;
  final bool isAnyMessageUnread;

  @override
  List<Object> get props => super.props + [this.users, this.invites, isAnyMessageUnread];
}

class MainSessions extends MainState {
  const MainSessions(this.isAnyMessageUnread, {this.isSupervisor = false})
      : super(isSupervisor ? 0 : 1, 'Sessions', true, isAnyMessageUnread);
  final bool isSupervisor;
  final bool isAnyMessageUnread;
}

class MainOffTimes extends MainState {
  final bool isAnyMessageUnread;

  const MainOffTimes(this.isAnyMessageUnread) : super(4, 'Off-times', true, isAnyMessageUnread);
}

class MainFiles extends MainState {
  const MainFiles(
      {this.sessionFiles = false,
      this.taskFiles = false,
      this.isSupervisor = false,
      this.isSupervisorCalanderAccess = false})
      : super(
            isSupervisor && isSupervisorCalanderAccess
                ? 2
                : isSupervisor && isSupervisorCalanderAccess
                    ? 1
                    : 2,
            'Files',
            true,
            false);

  final bool sessionFiles;
  final bool taskFiles;
  final bool isSupervisor;
  final bool isSupervisorCalanderAccess;
}

class MainProjects extends MainState {
  const MainProjects(this.isAnyMessageUnread, {this.active = false, this.archived = false})
      : super(4, 'Projects Manager', true, isAnyMessageUnread);

  final bool active;
  final bool archived;
  final bool isAnyMessageUnread;

  @override
  List<Object> get props => super.props + [this.active, this.archived, isAnyMessageUnread];
}

class MainKiosk extends MainState {
  const MainKiosk(this.isAnyMessageUnread, {this.terminals = true, this.nfc = false})
      : super(4, 'KIOSK Mode', true, isAnyMessageUnread);

  final bool terminals;
  final bool nfc;
  final bool isAnyMessageUnread;

  @override
  List<Object> get props => super.props + [this.terminals, this.nfc, isAnyMessageUnread];
}
