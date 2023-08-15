import 'dart:core';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/session_break.dart';
import 'package:staffmonitor/repository/session_break_repository.dart';

part 'session_break_state.dart';

class SessionBreakCubit extends Cubit<SessionBreakState> {
  SessionBreakCubit(this._sessionBreakRepository) : super(SessionBreakIdle());

  final _log = Logger('myOffTimesCubit');
  final SessionBreakRepository _sessionBreakRepository;

  void clear() {
    emit(SessionBreakIdle(breakList: []));
  }

  void init(int sessionId) {
    _log.fine('init: $sessionId');
    emit(SessionBreakApiProcess(breakList: state.breakList));
    _sessionBreakRepository.getAllSessionBreaks(sessionId: sessionId).then(
      (list) {
        _log.fine('all sessionBreaks: $list');
        if (list.isNotEmpty && list.last.end == null) {
          var current = list.last;
          emit(SessionBreakOpen(list.reversed.toList(), current));
        } else {
          emit(SessionBreakIdle(breakList: list.reversed.toList()));
        }
      },
      onError: (e, stack) {
        emit(SessionBreakError(e));
      },
    );
  }

  void startSessionBreak(int sessionId) {
    emit(SessionBreakApiProcess(breakList: state.breakList));
    _sessionBreakRepository.createSessionBreak(sessionId).then(
      (sessionBreak) {
        _log.fine('new break: $sessionBreak');
        init(sessionId);
      },
      onError: (e, stack) {
        emit(SessionBreakError(e));
      },
    );
  }

  void endSessionBreak(SessionBreak sessionBreak, {bool refresh = true}) {
    emit(SessionBreakApiProcess(breakList: state.breakList));
    _sessionBreakRepository.endSessionBreak(sessionBreak.copyWith(end: DateTime.now())).then(
      (result) {
        _log.fine('ended break: $result');
        if (sessionBreak.sessionId != null) {
          init(sessionBreak.sessionId!);
        }
      },
      onError: (e, stack) {
        emit(SessionBreakError(e));
      },
    );
  }
}
