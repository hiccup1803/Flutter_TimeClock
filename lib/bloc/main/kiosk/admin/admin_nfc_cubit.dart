import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:staffmonitor/model/admin_nfc.dart';
import 'package:staffmonitor/model/admin_project.dart';
import 'package:staffmonitor/model/loadable.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/repository/nfc_repository.dart';
import 'package:staffmonitor/repository/projects_repository.dart';
import 'package:staffmonitor/repository/users_repository.dart';
import 'package:staffmonitor/utils/color_utils.dart';

import '../../../../model/admin_terminal.dart';
import '../../../../repository/terminal_repository.dart';

part 'admin_nfc_state.dart';

class AdminNfcCubit extends Cubit<AdminNfcState> {
  AdminNfcCubit(this._nfcRepository, this._usersRepository) : super(AdminNfcInitial());

  final NfcRepository _nfcRepository;
  final UsersRepository _usersRepository;

  Loadable<List<Profile>> _users = Loadable.ready([]);
  Loadable<List<AdminNfc>> _nfcList = Loadable.ready([]);

  void refresh() {
    if (_users.value?.isNotEmpty != true) {
      refreshUsers();
    }
    _nfcList = Loadable.inProgress();
    _updateState();
    _nfcRepository.getAdminNfcs().then(
      (value) {
        _nfcList = Loadable.ready(value);
        _updateState();
      },
      onError: (e, stack) {
        _nfcList = Loadable.error(e, _nfcList.value);
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
    emit(AdminNfcReady(
      _users,
      _nfcList.transform((value) => value),
    ));
  }

  void deleteTask(int id) {
    _nfcRepository.deleteAdminNfc(id).then(
      (result) {
        emit(AdminNfcDeleted(_nfcList.transform((value) => value)));
      },
    );
  }
}
