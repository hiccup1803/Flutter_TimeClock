import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:staffmonitor/model/admin_project.dart';
import 'package:staffmonitor/model/loadable.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/repository/projects_repository.dart';
import 'package:staffmonitor/repository/users_repository.dart';
import 'package:staffmonitor/utils/color_utils.dart';

import '../../../../model/admin_terminal.dart';
import '../../../../repository/terminal_repository.dart';

part 'admin_terminals_state.dart';

class AdminTerminalsCubit extends Cubit<AdminTerminalsState> {
  AdminTerminalsCubit(this._terminalsRepository, this._usersRepository)
      : super(AdminTerminalsInitial());

  final TerminalRepository _terminalsRepository;
  final UsersRepository _usersRepository;

  Loadable<List<Profile>> _users = Loadable.ready([]);
  Loadable<List<AdminTerminal>> _terminals = Loadable.ready([]);

  void refresh() {
    if (_users.value?.isNotEmpty != true) {
      refreshUsers();
    }
    _terminals = Loadable.inProgress();
    _updateState();
    _terminalsRepository.getAdminTerminals().then(
      (value) {
        _terminals = Loadable.ready(value);
        _updateState();
      },
      onError: (e, stack) {
        _terminals = Loadable.error(e, _terminals.value);
        _updateState();
      },
    );
  }

  void refreshUsers() {
    _users = Loadable.inProgress();
    _usersRepository.getAllUser().then(
      (value) {
        _users = Loadable.ready(value.list);
        _updateState();
      },
      onError: (e, stack) {
        _users = Loadable.error(e);
        _updateState();
      },
    );
  }

  void _updateState() {
    emit(AdminTerminalsReady(
      _users,
      _terminals.transform((value) => value),
      _terminals.transform((value) => value),
    ));
  }

  void addNewProject(String name, Color? color) {
    if (name.isEmpty) {
      return;
    }
    if (color == null || color == Colors.white) {
      color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    }
    _terminals = Loadable.inProgress(_terminals.value);
    _updateState();
    // _terminalsRepository.createAdminProject(AdminProject.create(name, color.toHexHash())).then(
    //   (project) {
    //     _updateProject(project, add: true);
    //   },
    //   onError: (e, stack) {
    //     _users = Loadable.error(e, _users.value);
    //     _updateState();
    //   },
    // );
  }

  void terminalDeleted(AdminTerminal? task) {}
}
