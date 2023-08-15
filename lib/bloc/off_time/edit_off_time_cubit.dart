import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/admin_off_time.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/off_time.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/repository/off_times_repository.dart';
import 'package:staffmonitor/repository/users_repository.dart';
import 'package:staffmonitor/utils/time_utils.dart';

part 'edit_off_time_state.dart';

class EditOffTimeCubit extends Cubit<EditOffTimeState> {
  EditOffTimeCubit(this._offTimesRepository, this._usersRepository, this._admin)
      : super(EditOffTimeInitial());

  final OffTimesRepository _offTimesRepository;
  final UsersRepository _usersRepository;
  final bool _admin;
  final log = Logger('EditOffTimeCubit');

  late OffTime _offTime;
  late OffTime _editedOffTime;
  List<Profile>? _users;
  bool _hasChanged = false;

  bool get requireSaving => _offTime.isCreate || _editedOffTime != _offTime;

  void init(OffTime? offTime, {DateTime? startDay}) {
    if (offTime == null) {
      final date = startDay ?? DateTime.now();
      if (_admin) {
        _offTime = AdminOffTime.create(-1, date);
      } else {
        _offTime = OffTime.create(date);
      }
    } else {
      _offTime = offTime;
    }
    _editedOffTime = _offTime.copyWith();
    emit(EditOffTimeReady(_offTime, _editedOffTime, _offTime.isCreate, false, _admin ? [] : null));
    if (_admin) {
      _loadUsers();
    }
  }

  void _updateState() {
    emit(EditOffTimeReady(_offTime, _editedOffTime, requireSaving, _hasChanged, _users));
  }

  void _loadUsers() {
    _usersRepository.getAllUser().then((value) {
      log.fine('value $value');
      _users = value.list?.where((element) => element.isActive).toList();
      log.fine('_loadUsers $_users');
      _updateState();
    });
  }

  void changeStartDate(DateTime date) {
    _editedOffTime = _editedOffTime.copyWith(
      startAt: date.format('yyyy-MM-dd'),
      endAt: date.add(Duration(days: _editedOffTime.days)).format('yyyy-MM-dd'),
    );
    _updateState();
  }

  void changeEndDate(DateTime date) {
    final difference = date.noon.difference(_editedOffTime.startDate!.noon);
    _editedOffTime =
        _editedOffTime.copyWith(endAt: date.format('yyyy-MM-dd'), days: 1 + difference.inDays);
    _updateState();
  }

  void noteChanged(String text) {
    _editedOffTime = _editedOffTime.copyWith(note: text);
    _updateState();
  }

  void changeType(int type) {
    _editedOffTime = _editedOffTime.copyWith(type: type);
    _updateState();
  }

  void changeUser(int id) {
    _editedOffTime = (_editedOffTime as AdminOffTime).copyWith(userId: id);
    _updateState();
  }

  void changeStatus(int status) {
    _editedOffTime = (_editedOffTime as AdminOffTime).copyWith(status: status);
    _updateState();
  }

  void deleteSession() {
    Future<bool> deleteRequest;
    if (_admin) {
      deleteRequest = _offTimesRepository.deleteAdminOffTime(_offTime.id);
    } else {
      deleteRequest = _offTimesRepository.deleteOffTime(_offTime);
    }
    deleteRequest.then(
      (result) {
        emit(EditOffTimeDeleted(_editedOffTime));
      },
      onError: (e, stack) {
        emit(EditOffTimeError(_editedOffTime, AppError.from(e)));
      },
    );
  }

  void save() {
    emit(EditOffTimeProcessing(_editedOffTime));
    _apiRequest().then(
      (offTime) {
        log.fine('save result: $offTime');
        _offTime = offTime;
        _editedOffTime = offTime;
        _hasChanged = true;
        emit(EditOffTimeSaved(_editedOffTime, closePage: true));
      },
      onError: (e, stack) {
        log.shout('save', e, stack);
        emit(EditOffTimeError(_editedOffTime, AppError.from(e)));
      },
    );
  }

  Future<OffTime> _apiRequest() {
    final offTime = _editedOffTime;
    log.fine('apiRequest: $offTime');
    if (offTime.isCreate) {
      log.fine('apiRequest: create');
      if (_admin) {
        return _offTimesRepository.createAdminOffTime(offTime as AdminOffTime);
      }
      return _offTimesRepository.createOffTime(offTime);
    } else {
      log.fine('apiRequest: update');
      if (_admin) {
        return _offTimesRepository.updateAdminOffTime(offTime as AdminOffTime);
      }
      return _offTimesRepository.updateOffTime(offTime);
    }
  }

  void errorConsumed() => stateConsumed();

  void stateConsumed() {
    _updateState();
  }
}
