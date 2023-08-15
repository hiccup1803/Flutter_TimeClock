import 'dart:core';

import 'package:chopper/chopper.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/admin_session.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/model/project.dart';
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/model/wage.dart';
import 'package:staffmonitor/repository/history_repository.dart';
import 'package:staffmonitor/repository/session_break_repository.dart';
import 'package:staffmonitor/service/api/admin_sessions_service.dart';
import 'package:staffmonitor/service/api/sessions_service.dart';
import 'package:staffmonitor/service/network_status_service.dart';
import 'package:staffmonitor/storage/offline_storage.dart';
import 'package:staffmonitor/utils/time_utils.dart';

import '../model/profile.dart';

class SessionsRepository implements HistoryRepository {
  SessionsRepository(
    this._sessionsService,
    this._adminSessionsService,
    this._sessionBreakRepository,
    this._offlineStorage,
    this._networkStatusService,
  );

  final _log = Logger('SessionsRepository');
  final SessionsService _sessionsService;
  final AdminSessionsService _adminSessionsService;
  final SessionBreakRepository _sessionBreakRepository;
  final OfflineStorage _offlineStorage;
  final NetworkStatusService _networkStatusService;

  Future<Paginated<AdminSession>> getAdminSessions(
      {int page = 1, int perPage = 10, required DateTime month}) async {
    _log.fine('getAdminSessions net: null');
    final response = await _adminSessionsService.getFilteredSessions(
        page: page, perPage: perPage, after: month.firstDayOfMonth, before: month.lastDayOfMonth);
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<AdminSession> acceptAdminSession(int sessionId) async {
    _log.fine('acceptAdminSession net: null');
    final response = await _adminSessionsService.approveSession(sessionId);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<bool> deleteAdminSession(int sessionId) async {
    _log.fine('deleteAdminSession net: null');
    final response = await _adminSessionsService.deleteSession(sessionId);
    if (response.isSuccessful) {
      return true;
    } else {
      throw response.error!;
    }
  }

  Future<Paginated<Session>> getMySessions({required int page, required DateTime month}) async {
    bool netStatus = await _networkStatusService.isNetworkAvailable();
    _log.fine('getMySessions net: $netStatus');
    if (netStatus) {
      final response = await _sessionsService.getFilteredSessions(
        page: page,
        perPage: 25,
        before: month.lastDayOfMonth,
        after: month.firstDayOfMonth,
      );
      if (response.isSuccessful) {
        return Paginated.fromResponse(response);
      } else {
        throw response.error!;
      }
    } else {
      var where = _offlineStorage.sessionsList().where((element) =>
          element.clockIn?.isBefore(month.lastDayOfMonth) == true &&
          element.clockIn?.isAfter(month.firstDayOfMonth) == true);
      var currentSession = _offlineStorage.getCurrentSession();
      var includeCurrent = currentSession?.clockIn?.isBefore(month.lastDayOfMonth) == true &&
          currentSession?.clockIn?.isAfter(month.firstDayOfMonth) == true;
      return Paginated<Session>(
        [
          if (includeCurrent) currentSession!,
          ...where,
        ],
        1,
        1,
        where.length + (includeCurrent ? 1 : 0),
      );
    }
  }

  @override
  Future<Paginated<dynamic>> getHistoryItems(
    DateTime from,
    DateTime to,
    int page,
  ) async {
    _log.fine('getHistoryItems net: null');
    final response = await _sessionsService.getFilteredSessions(
        page: page, perPage: 20, before: to, after: from);
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<Paginated<Session>> getCalendarItems(DateTime from, DateTime to, int page) async {
    _log.fine('getCalendarItems net: null');
    final response = await _sessionsService.getFilteredSessions(
        page: page, perPage: 200, before: to, after: from);
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<Paginated<AdminSession>> getAdminCalendarItems(
      DateTime from, DateTime to, int page, int assignee) async {
    _log.fine('getAdminCalendarItems net: null');
    final response = await _adminSessionsService.getFilteredSessions(
      page: page,
      perPage: 200,
      before: to,
      after: from,
      assignee: assignee,
    );
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<Session?> currentSession() async {
    bool netStatus = await _networkStatusService.isNetworkAvailable();
    _log.fine('currentSession net: $netStatus');
    if (netStatus) {
      final response = await _sessionsService.getCurrentSession();
      if (response.isSuccessful) {
        if (response.body == Session.empty() || response.body == null) {
          return null;
        } else {
          await _offlineStorage.saveCurrentSession(response.body!);
          return response.body;
        }
      } else {
        throw response.error!;
      }
    } else {
      var currentSession = _offlineStorage.getCurrentSession();
      _log.fine('currentSession: $currentSession');
      return currentSession;
    }
  }

  Future<Session> startSession(int? projectId, {String? projectName, Wage? hourWage}) async {
    bool netStatus = await _networkStatusService.isNetworkAvailable();
    _log.fine('startSession net: $netStatus');

    var dateTimeNow = DateTime.now();
    if (netStatus) {
      final response = await _sessionsService.createSession(
        ApiSession(
          projectId,
          'mobile',
          dateTimeNow,
          rateCurrency: hourWage?.currency,
          hourRate: hourWage?.wage,
        ),
      );

      if (response.isSuccessful) {
        await _offlineStorage.saveCurrentSession(response.body!);
        return response.body!;
      } else {
        throw response.error!;
      }
    } else {
      var localId = dateTimeNow.millisecondsSinceEpoch;
      Profile? profile = _offlineStorage.getProfile();
      Session session = Session.create(
        id: -localId,
        clockIn: dateTimeNow,
        wage: hourWage ?? profile?.defaultWage,
        project: profile?.availableProjects?.firstWhereOrNull((element) => element.id == projectId),
      );
      _log.fine('offline save current: $session');
      _offlineStorage.saveCurrentSession(session);
      return session;
    }
  }

  Future finishSession(Session session, DateTime clockOut) async {
    bool netStatus = await _networkStatusService.isNetworkAvailable();
    _log.fine('finishSession net: $netStatus');

    _offlineStorage.deleteCurrentSession();
    if (netStatus) {
      if (session.id < 0) {
        _sessionsService.createSession(ApiSession.fromSession(session));
      } else {
        final response = await _sessionsService.updateSession(
            session.id,
            ApiSession(
              session.project?.id,
              'mobile',
              null,
              clockOut: clockOut,
              note: session.note,
              bonus: session.bonus,
            ));

        if (response.isSuccessful) {
          return response.body;
        } else {
          throw response.error!;
        }
      }
    } else {
      _offlineStorage.addSession(session.copyWith(clockOut: clockOut));
      return;
    }
  }

  Future<Session> updateAdminSession(Session session) async {
    _log.fine('updateAdminSession net: null');
    final response = await _adminSessionsService.updateSession(
      session.id,
      ApiSession.fromSession(
          session,
          session.project?.id == Project.ownProject.id ? session.project : null,
          session.hourRate,
          session.rateCurrency),
    );

    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<Session> createAdminSession({
    required int clockIn,
    required int userId,
    String hourRate = "5.0",
    String rateCurrency = "5.0",
    String bonus = "0.5",
    int clockOut = 160000000,
    String note = "",
    int projectId = 1,
  }) async {
    _log.fine('createAdminSession');
    final response = await _adminSessionsService.postSessions({
      "clockIn": clockIn,
      "userId": userId,
      "hourRate": hourRate,
      "rateCurrency": rateCurrency,
      "bonus": bonus,
      "clockOut": clockOut,
      "note": note,
      "projectId": projectId
    });
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<Session> updateSession(Session session) async {
    bool netStatus = await _networkStatusService.isNetworkAvailable();
    _log.fine('updateSession net: $netStatus');

    if (netStatus) {
      final response = await _createOrUpdateRequest(session);

      if (response.isSuccessful) {
        return response.body!;
      } else {
        throw response.error!;
      }
    } else {
      if (_offlineStorage.getCurrentSession()?.id == session.id) {
        if (session.clockOut == null) {
          _offlineStorage.saveCurrentSession(session);
        } else {
          _offlineStorage.deleteCurrentSession();
          _offlineStorage.updateSession(session);
        }
      }
      return session;
    }
  }

  Future<Session> createSession(Session session, {String? hourRate, String? currency}) async {
    _log.fine('createSession net: null');
    var response = await _sessionsService.createSession(
      ApiSession.fromSession(
        session,
        session.project?.id == Project.ownProject.id ? session.project : null,
        hourRate,
        currency,
      ),
    );

    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<bool> deleteSession({Session? session, int? id}) async {
    _log.fine('deleteSession net: null');
    if (session == null && id == null) return false;
    final response = await _sessionsService.deleteSession(session?.id ?? id);

    if (response.isSuccessful) {
      return true;
    } else {
      throw response.error!;
    }
  }

  Future<Response<Session>> _createOrUpdateRequest(Session session) {
    _log.fine('_createOrUpdate $session');
    if (session.id < 0) {
      return _sessionsService.createSession(ApiSession.fromSession(
        session,
        session.project?.id == Project.ownProject.id ? session.project : null,
        session.hourRate,
        session.rateCurrency,
      ));
    } else {
      return _sessionsService.updateSession(
          session.id,
          ApiSession(
            session.project?.id,
            'mobile',
            null,
            clockOut: session.clockOut,
            note: session.note,
            bonus: session.bonus,
          ));
    }
  }

  Future<void> uploadOfflineSessionsAndBreaks() async {
    _log.fine('uploadOfflineSessions start ${DateTime.now().toIso8601String()}');
    List<Session> sessionsList = _offlineStorage.sessionsList();

    await Future.forEach(sessionsList, (Session element) async {
      bool success = await _createOrUpdateRequest(element).then((value) async {
        await _sessionBreakRepository.uploadOfflineBreaks(value.body!.id, offlineId: element.id);
        return true;
      }, onError: (e, stack) => false);
      if (success) {
        await _offlineStorage.deleteSession(element.id);
      }
    });
    Session? currentSession = _offlineStorage.getCurrentSession();
    if (currentSession != null) {
      bool success = await _createOrUpdateRequest(currentSession).then((value) async {
        await _sessionBreakRepository.uploadOfflineBreaks(
          value.body!.id,
          offlineId: currentSession.id,
        );
        return true;
      }, onError: (e, stack) => false);
      if (success) {
        await _offlineStorage.deleteCurrentSession();
      }
    }
    _log.fine('uploadOfflineSessions end ${DateTime.now().toIso8601String()}');
  }

  Future<Session> getSession(int id) async {
    _log.fine('getSession net: null');
    final response = await _sessionsService.getSession(id);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<AdminSession> getAdminSession(int id) async {
    _log.fine('getAdminSession net: null');
    final response = await _adminSessionsService.getSession(id);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }
}