import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/admin_session.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/app_file.dart';
import 'package:staffmonitor/model/project.dart';
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/repository/sessions_repository.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';
import 'package:staffmonitor/utils/time_utils.dart';

part 'edit_session_state.dart';

class EditSessionCubit extends Cubit<EditSessionState> {
  EditSessionCubit(this._sessionsRepository, this.allowNewRate, this.currency, this._admin)
      : super(EditSessionInitial());

  final log = Logger('EditSessionCubit');
  final SessionsRepository _sessionsRepository;
  final bool? allowNewRate;
  final String? currency;
  final bool _admin;
  late Session _session;
  late Session _editedSession;
  bool _hasChanged = false;
  int _sessionUserId = -1;

  bool get requireSaving => _session.isCreate || _editedSession != _session;

  void init(Session? session, {Project? defaultProject, DateTime? date}) {
    if (session == null) {
      final now = date ?? DateTime.now();
      if (_admin) {
        _session = AdminSession.create(
            clockIn: DateTime(now.year, now.month, now.day, now.hour, now.minute),
            project: defaultProject);

        print(["created session:", _session]);
      } else {
        _session = Session.create(
            clockIn: DateTime(now.year, now.month, now.day, now.hour, now.minute),
            project: defaultProject);
      }
    } else {
      _session = session;
    }
    _editedSession = _session.copyWith();
    emit(EditSessionReady(_editedSession, _session.isCreate, _session.clockOut != null, false));
  }

  void updateProject(Project? project) {
    _editedSession = _editedSession.copyWith(project: project, clearProject: project == null);
    emit(EditSessionReady(_editedSession, requireSaving, _session.clockOut != null, _hasChanged));
  }

  void changeDate(DateTime date) {
    log.fine('changeDate ${date.toIso8601String()}');
    var clockIn = _editedSession.clockIn!;
    var clockOut = _editedSession.clockOut;

    _editedSession = _editedSession.copyWith(
      clockIn: clockIn.copyWithDate(
        date.year,
        date.month,
        date.day,
      ),
      clockOut: clockOut != null
          ? clockOut.copyWithDate(
              date.year,
              date.month,
              date.day,
            )
          : null,
      clearClockOut: clockOut == null,
    );
    emit(EditSessionReady(_editedSession, requireSaving, _session.clockOut != null, _hasChanged));
  }

  void changeClockInTime(TimeOfDay time) {
    _editedSession = _editedSession.copyWith(
      clockIn: _editedSession.clockIn!.copyWithTime(time.hour, time.minute),
    );
    emit(EditSessionReady(_editedSession, requireSaving, _session.clockOut != null, _hasChanged));
  }

  void changeNewClockInTime(TimeOfDay time) {
    _editedSession = _editedSession.copyWith(
      clockInNew: _editedSession.clockInProposed!.copyWithTime(time.hour, time.minute),
    );
    emit(EditSessionReady(_editedSession, requireSaving, _session.clockOut != null, _hasChanged));
  }

  void changeClockOutTime(TimeOfDay? time) {
    _editedSession = _editedSession.copyWith(
      clockOut: time != null ? _editedSession.clockOut!.copyWithTime(time.hour, time.minute) : null,
      clearClockOut: time == null,
    );
    emit(EditSessionReady(_editedSession, requireSaving, _session.clockOut != null, _hasChanged));
  }

  void changeNewClockOutTime(TimeOfDay? time) {
    _editedSession = _editedSession.copyWith(
      clockOutNew: time != null
          ? _editedSession.clockOutProposed!.copyWithTime(time.hour, time.minute)
          : null,
      clearClockOut: time == null,
    );
    emit(EditSessionReady(_editedSession, requireSaving, _session.clockOut != null, _hasChanged));
  }

  void noteChanged(String text) {
    _editedSession = _editedSession.copyWith(note: text);
    emit(EditSessionReady(_editedSession, requireSaving, _session.clockOut != null, _hasChanged));
  }

  void hourRateChanged(String text) {
    _editedSession = _editedSession.copyWith(hourRate: text);
    emit(EditSessionReady(_editedSession, requireSaving, _session.clockOut != null, _hasChanged));
  }

  void rateCurrencyChanged(String text) {
    _editedSession = _editedSession.copyWith(rateCurrency: text);
    emit(EditSessionReady(_editedSession, requireSaving, _session.clockOut != null, _hasChanged));
  }

  void sessionBonusChanged(String text) {
    _editedSession = _editedSession.copyWith(bonus: text);
    emit(EditSessionReady(_editedSession, requireSaving, _session.clockOut != null, _hasChanged));
  }

  void sessionNewBonusChanged(String text) {
    _editedSession = _editedSession.copyWith(bonusNew: text);
    emit(EditSessionReady(_editedSession, requireSaving, _session.clockOut != null, _hasChanged));
  }

  void sessionUserSet(int value) {
    _sessionUserId = value;
    _editedSession = (_editedSession as AdminSession).copyWith(userId: value);
    emit(EditSessionReady(_editedSession, requireSaving, _session.clockOut != null, _hasChanged));
  }

  void deleteSession() {
    if (_admin) {
      _sessionsRepository.deleteAdminSession(_session.id).then(
        (result) {
          emit(EditSessionDeleted(_editedSession));
        },
        onError: (e, stack) {
          emit(EditSessionError(_editedSession, AppError.from(e)));
        },
      );
    } else {
      _sessionsRepository.deleteSession(session: _session).then(
        (result) {
          emit(EditSessionDeleted(_editedSession));
        },
        onError: (e, stack) {
          emit(EditSessionError(_editedSession, AppError.from(e)));
        },
      );
    }
  }

  void save() {
    emit(EditSessionProcessing(_editedSession));
    _apiRequest().then(
      (session) {
        log.fine('save session: $session');
        log.fine('save session wage: ${session.totalWage}');
        _session = session;
        _editedSession = session.copyWith();
        _hasChanged = true;
        emit(EditSessionSaved(_editedSession, closePage: false));
      },
      onError: (e, stack) {
        log.shout('save', e, stack);
        emit(EditSessionError(_editedSession, AppError.from(e)));
      },
    );
  }

  Future<Session> _apiRequest() {
    Session s = _editedSession;
    log.fine('_apiRequest for session: ${s.toJson()}');

    if ((_editedSession.project?.id ?? -1) < 0 &&
        _editedSession.project?.id != Project.ownProject.id) {
      s = _editedSession.copyWith(clearProject: true);
    }
    if (s.isCreate) {
      if (_admin) {
        var clockIn = _editedSession.clockIn ?? DateTime.now();
        int userId = _sessionUserId;
        String hourRate = _editedSession.hourRate ?? "";
        String rateCurrency = _editedSession.rateCurrency ?? "";
        String bonus = _editedSession.bonus ?? "";
        DateTime clockOut = _editedSession.clockOut ?? DateTime.now();
        String _note = _editedSession.note ?? "";
        int _projectId = _editedSession.project?.id ?? -1;
        return _sessionsRepository.createAdminSession(
            clockIn: const JsonDateTimeConverter().toJson(clockIn)!,
            userId: userId,
            hourRate: hourRate,
            rateCurrency: rateCurrency,
            clockOut: const JsonDateTimeConverter().toJson(clockOut)!,
            bonus: bonus,
            note: _note,
            projectId: _projectId);
      }
      return _sessionsRepository.createSession(
        s,
        hourRate: allowNewRate == true ? s.hourRate : null,
        currency: allowNewRate == true ? currency : null,
      );
    } else {
      if (_admin) {
        return _sessionsRepository.updateAdminSession(s);
      }
      return _sessionsRepository.updateSession(s);
    }
  }

  void errorConsumed() => stateConsumed();

  void stateConsumed() {
    emit(EditSessionReady(_editedSession, requireSaving, _session.clockOut != null, _hasChanged));
  }

  Session fileDeleted(AppFile deleted) {
    final List<AppFile> list = List.from(_editedSession.files);
    log.finest('fileDeleted: old list - $list');
    list.remove(deleted);
    log.finest('fileDeleted: new list - $list');
    _editedSession = _editedSession.copyWith(files: list);
    _session = _session.copyWith(files: list);
    _hasChanged = true;
    emit(EditSessionReady(_editedSession, requireSaving, _session.clockOut != null, _hasChanged));
    return _session;
  }

  Session fileChanged(AppFile uploadResult) {
    final List<AppFile> list = List.from([uploadResult]);
    list.addAll(_editedSession.files);
    log.finest('fileChanged: new list - $list');

    _editedSession = _editedSession.copyWith(files: list);
    _session = _session.copyWith(files: list);
    _hasChanged = true;
    emit(EditSessionReady(_editedSession, requireSaving, _session.clockOut != null, _hasChanged));
    return _session;
  }

  void accept() {
    emit(EditSessionProcessing(_editedSession));
    _sessionsRepository.acceptAdminSession(_session.id).then(
      (session) {
        log.fine('accept session: $session');
        _session = session;
        _editedSession = session.copyWith();
        _hasChanged = true;
        emit(EditSessionSaved(_editedSession, closePage: false));
      },
      onError: (e, stack) {
        log.shout('save', e, stack);
        emit(EditSessionError(_editedSession, AppError.from(e)));
      },
    );
  }
}
