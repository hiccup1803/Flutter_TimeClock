import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/project.dart';
import 'package:staffmonitor/repository/nfc_repository.dart';
import 'package:staffmonitor/repository/users_repository.dart';

import '../../model/admin_nfc.dart';

part 'edit_nfc_state.dart';

class EditNfcCubit extends Cubit<EditNfcState> {
  EditNfcCubit(this._terminalRepository, this._usersRepository, this.profile, this._admin)
      : super(EditNfcInitial());

  final NfcRepository _terminalRepository;
  final UsersRepository _usersRepository;
  final log = Logger('EditNfcCubit');
  late bool _admin;
  final Profile? profile;
  late AdminNfc _task;
  late AdminNfc _editedTask;

  bool _hasChanged = false;
  List<Profile>? _users = [];
  String _employeeName = 'Select employee';
  int _employeeId = 0;

  String _description = '';
  String _nfcType = 'checkpoint';

  bool titleChanged = false;

  bool get requireSaving => titleChanged || _editedTask != _task;

  void init(AdminNfc? task, String type, {Project? defaultProject, DateTime? date}) async {
    log.fine('init task: $task, {$defaultProject, $date}');
    _nfcType = type;
    if (_users?.isNotEmpty != true) {
      log.finest('init users in cubit');

      _usersRepository.getAllEmployee().then(
        (value) {
          _users = value;
        },
      );
    }

    if (task == null) {
      _task = AdminNfc.create();
    } else {
      titleChanged = true;
      if (task.serialNumber.isEmpty) {
        emit(EditNfcProcessing(task));
        if (_admin) {
          _task = await _terminalRepository.getAdminNfcById(task.id);
        }
      } else {
        _task = task.copyWith();
      }
    }
    _editedTask = _task.copyWith();
    if (_users?.isNotEmpty == true) {
      Profile? p = _users?.firstWhere((element) => element.id == _editedTask.userId);
      _employeeName = p == null ? '' : p.name!;
      _employeeId = p == null ? 0 : p.id;
    }

    emit(EditNfcReady(_editedTask, requireSaving, _hasChanged, _users, _employeeName));
  }

  void changeTitle(String title) {
    if (title.isEmpty) {
      titleChanged = false;
      emit(EditNfcValidator(_editedTask, _employeeName, titleError: 'Wymagane'));
    } else if (title == _editedTask.serialNumber) {
      titleChanged = false;
      emit(EditNfcReady(_editedTask, requireSaving, _hasChanged, _users, _employeeName));
    } else {
      titleChanged = true;
      _editedTask = _editedTask.copyWith(serialNumber: title);
      emit(EditNfcReady(_editedTask, requireSaving, _hasChanged, _users, _employeeName));
    }
  }

  void changeDescription(String title) {
    if (title.isEmpty) {
      emit(EditNfcValidator(_editedTask, _employeeName, titleError: 'Wymagane'));
    } else if (title == _editedTask.serialNumber) {
      emit(EditNfcReady(_editedTask, requireSaving, _hasChanged, _users, _employeeName));
    } else {
      _editedTask = _editedTask.copyWith(description: title);
      emit(EditNfcReady(_editedTask, requireSaving, _hasChanged, _users, _employeeName));
    }
  }

  void selectUser(int profileId) {
    _employeeId = profileId;
    _editedTask = _editedTask.copyWith(userId: profileId);
  }

  void errorConsumed() => stateConsumed();

  void stateConsumed() {
    emit(EditNfcReady(_editedTask, requireSaving, _hasChanged, _users, _employeeName));
  }

  void refresh() {
    init(_editedTask, _nfcType);
  }

  Future<bool> save() async {
    emit(EditNfcProcessing(_editedTask));
    return await apiTaskRequest().then(
      (task) {
        _task = task;
        _editedTask = task;
        _hasChanged = true;

        emit(EditNfcSaved(_editedTask, closePage: true));

        return true;
      },
      onError: (e, stack) {
        log.shout('save', e, stack);

        emit(EditNfcError(_editedTask, e is AppError ? e : AppError.fromMessage(e.toString())));
        return false;
      },
    );
  }

  Future<AdminNfc> apiTaskRequest() {
    if (_editedTask.isCreate) {
      return _terminalRepository.createAdminNfc(_editedTask, _nfcType,
          userId: _nfcType == 'access_card' ? _employeeId : null);
    } else {
      return Future.value(_editedTask);
    }
  }
}
