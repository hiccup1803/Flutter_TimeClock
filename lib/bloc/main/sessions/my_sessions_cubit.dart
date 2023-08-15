import 'dart:core';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/bloc/auth/auth_cubit.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/employee_summary.dart';
import 'package:staffmonitor/model/loadable.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/model/project.dart';
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/model/session_wage_duration.dart';
import 'package:staffmonitor/model/sessions_day_summary.dart';
import 'package:staffmonitor/model/sessions_month_summary.dart';
import 'package:staffmonitor/model/wage.dart';
import 'package:staffmonitor/page/main/my_sessions/my_sessions.i18n.dart';
import 'package:staffmonitor/repository/projects_repository.dart';
import 'package:staffmonitor/repository/sessions_repository.dart';
import 'package:staffmonitor/service/geolocation_service.dart';
import 'package:staffmonitor/utils/time_utils.dart';

part 'my_sessions_state.dart';

class MySessionsCubit extends Cubit<MySessionsState> {
  MySessionsCubit(
    this._sessionsRepository,
    this._projectsRepository,
    this._geolocationService,
    this._authCubit,
  ) : super(SessionsInitial());

  final _log = Logger('MySessionsCubit');
  final SessionsRepository _sessionsRepository;
  final ProjectsRepository _projectsRepository;
  final GeolocationService _geolocationService;
  final AuthCubit _authCubit;

  Loadable<Session?> _currentSession = Loadable.ready(null);
  Loadable<List<SessionsDaySummary>> _monthlySessionsAndLabels = Loadable.ready(null);
  DateTime _selectedMonth = DateTime.now().firstDayOfMonth;
  Loadable<Paginated<Session>> _sessionsByMonth = Loadable.ready(null);
  Project? _selectedProject;
  bool hasPermission = false;

  void init({bool trackGPS = false}) async {
    hasPermission = await _geolocationService.hasPermission();
    _log.fine('hasPermission: $hasPermission');
    refresh(trackGPS: trackGPS);
  }

  void _update({Loadable<Session?>? current}) {
    if (this.isClosed) {
      return;
    }
    if (current != null) {
      _currentSession = current;
      _selectedProject = current.value?.project;
    }
    emit(SessionsReady(
      _selectedMonth,
      _selectedProject,
      _currentSession,
      _monthlySessionsAndLabels,
      Loadable.ready(SessionsMonthSummary(0, 0, Duration(), {})),
      Loadable.ready([]),
      hasPermission,
    ));

    if (_sessionsByMonth.inProgress != true) {
      if (_sessionsByMonth.value?.list?.isNotEmpty != true) {
        log.fine('_updateState: empty sessions\n');
        emit(SessionsReady(
          _selectedMonth,
          _selectedProject,
          _currentSession,
          Loadable.ready([]),
          Loadable.ready(SessionsMonthSummary(0, 0, Duration(), {})),
          Loadable.ready([]),
          hasPermission,
        ));
        return;
      }

      Duration monthDuration = Duration();
      String rateCurrency = '';
      Map<int, EmployeeSummary> mappedSummaries = {};
      Map<String, WageAndDuration> mappedSessionWageCurrency = {};
      Map<DateTime, List<Session>> mappedSessions = {};

      _sessionsByMonth.value?.list?.forEach((session) {
        monthDuration += session.duration ?? Duration();
        DateTime day = session.createdAt!.startOfDay;

        rateCurrency = session.rateCurrency ?? '';

        if (mappedSessions[day] == null) {
          mappedSessions[day] = [];
        }
        mappedSessions[day]!.add(session);

        if (mappedSummaries[0] == null) {
          mappedSummaries[0] = EmployeeSummary.me().addMySession(session);
        } else {
          mappedSummaries[0] = mappedSummaries[0]!.addMySession(session);
        }

        if (mappedSessionWageCurrency[rateCurrency.toUpperCase()] == null) {
          mappedSessionWageCurrency[rateCurrency.toUpperCase()] = WageAndDuration().add(session);
        } else {
          mappedSessionWageCurrency[rateCurrency.toUpperCase()] =
              mappedSessionWageCurrency[rateCurrency.toUpperCase()]!.add(session);
        }

        final listWithHeaders = mapSessionsToSummaries(_sessionsByMonth.value?.list ?? const []);
        _monthlySessionsAndLabels = Loadable.ready(listWithHeaders);
      });

      emit(SessionsReady(
        _selectedMonth,
        _selectedProject,
        _currentSession,
        _monthlySessionsAndLabels,
        Loadable.ready(SessionsMonthSummary(mappedSessions.keys.length,
            _sessionsByMonth.value?.list?.length ?? 0, monthDuration, mappedSessionWageCurrency)),
        Loadable.ready(List.of(mappedSummaries.values)),
        hasPermission,
      ));
    } else {
      emit(SessionsReady(
        _selectedMonth,
        _selectedProject,
        _currentSession,
        Loadable.inProgress(),
        Loadable.inProgress(),
        Loadable.inProgress(),
        hasPermission,
      ));
    }
  }

  void refresh({bool force = false, bool trackGPS = false}) async {
    if (_sessionsByMonth.inProgress != true) {
      _sessionsByMonth = Loadable.inProgress();
      _loadSessions(1, _selectedMonth);
    }
    if (force || _currentSession.inProgress != true) {
      refreshCurrent(trackGPS: trackGPS);
    }
  }

  void changeMonth(DateTime newDate) {
    if (newDate.firstDayOfMonth != _selectedMonth) {
      _selectedMonth = newDate.firstDayOfMonth;
      refresh();
    }
  }

  void refreshCurrent({bool trackGPS = false}) {
    _log.finer(
        'refreshCurrent (trackGPS: $trackGPS) - in progress: ${_currentSession.inProgress == true}');
    if (_currentSession.inProgress == true) {
      return;
    }
    _update(current: Loadable.inProgress(_currentSession.value ?? null));
    _sessionsRepository.currentSession().then(
      (session) async {
        bool hasPermission = await _geolocationService.hasPermission();
        _log.finer('refreshCurrent (trackGPS: $trackGPS) - result: $session');
        if (session != null && session.clockOut == null && trackGPS && hasPermission) {
          _geolocationService.startTracking();
        } else if (session == null || session.clockOut != null) {
          _geolocationService.stopTracking();
        }
        _update(current: Loadable.ready(session));
      },
      onError: (e, stack) async {
        _log.finer('refreshCurrent - error: $e');
        _update(
          current: Loadable.error(
            (e is AppError) ? e : AppError.fromMessage('An error occurred'.i18n),
            _currentSession.value,
          ),
        );
      },
    );
  }

  static List<SessionsDaySummary> mapSessionsToSummaries(List<Session> sessions) {
    SessionsDaySummary? header;
    List<SessionsDaySummary> result = sessions.map((e) {
      return SessionsDaySummary(
        day: e.clockIn,
        count: 1,
        time: e.duration ?? const Duration(),
        sessions: [e],
      );
    }).fold<List<SessionsDaySummary>>(
      [],
      (List<SessionsDaySummary> list, summary) {
        if (header?.day?.day == summary.day?.day) {
          header = SessionsDaySummary(
            day: header!.day,
            count: header!.count + 1,
            time: header!.time + summary.time,
            sessions: [...header!.sessions, summary.sessions[0]],
          );
          list.removeLast();
          list.add(header!);
        } else {
          header = summary;
          list.add(summary);
        }

        return list;
      },
    );
    return result;
  }

  void _loadSessions(int page, DateTime month) {
    _sessionsRepository.getMySessions(page: page, month: month).then(
      (value) {
        if (month != _selectedMonth) {
          //selected month changed
          return;
        }
        if (_sessionsByMonth.value?.page != null && _sessionsByMonth.value!.page < value.page) {
          value = _sessionsByMonth.value! + value;
        }
        if (value.hasMore) {
          _sessionsByMonth = Loadable.inProgress(value);
          _loadSessions(value.page + 1, month);
        } else {
          _sessionsByMonth = Loadable.ready(value);
        }
        _update();
      },
      onError: (e, stack) {
        if (month != _selectedMonth) {
          return;
        }
        log.shout('_loadSession page:$page', e, stack);
        if (e is AppError) {
          _sessionsByMonth = Loadable.error(e, _sessionsByMonth.value);
        } else {
          _sessionsByMonth = Loadable.error(AppError.from(e), _sessionsByMonth.value);
        }
        log.shout('_loadSession _sessions:$_sessionsByMonth');
        _update();
      },
    );
  }

  void selectProject(Project? project) {
    if (project != _selectedProject) {
      _selectedProject = project;
      _update();
    }
  }

  Future<Project> createProject(Project project) {
    return _projectsRepository.createProject(project);
  }

  void quickStartSession(Project? project, {Wage? hourWage, bool trackGPS = false}) {
    log.fine('quickStartSession $project');
    Future<Session> getSessionFuture() async {
      if (project == null) {
        return _sessionsRepository.startSession(
          null,
          projectName: null,
          hourWage: hourWage,
        );
      } else {
        return _sessionsRepository.startSession(
          project.id,
          projectName: project.name,
          hourWage: hourWage,
        );
      }
    }

    _log.fine('quickStartSession: $project');
    _update(current: Loadable.inProgress(_currentSession.value));

    getSessionFuture().then(
      (session) {
        if (project?.id == Project.ownProject.id) {
          _projectsRepository.clearCache();
          _authCubit.refreshProfile();
        }
        _projectsRepository.updateLastProjects(session.project);
        _log.finer('quickStartSession - result:  $session');
        _update(current: Loadable.ready(session));
        if (trackGPS && hasPermission) {
          _geolocationService.startTracking(resetOdometer: true);
        }
      },
      onError: (e, stack) {
        _log.finer('quickStartSession - error: $e');
        _update(
          current: Loadable.error(
              (e is AppError) ? e : AppError.fromMessage('An error occurred'.i18n),
              _currentSession.value),
        );
      },
    );
  }

  Future finishSession(Session session) async {
    _log.fine('finishSession: $session');
    _update(current: Loadable.inProgress(_currentSession.value));
    if (await _geolocationService.isTracking()) {
      log.fine('was tracking location');
      await _geolocationService.updateLocationNow().then((value) {
        log.fine('last location: $value');
      }, onError: (e, stack) {
        log.shout('update last location error', e, stack);
      });
      await _geolocationService.stopTracking();
    }
    return _sessionsRepository.finishSession(session, DateTime.now()).then(
      (s) {
        _log.finer('finishSession - result:  $s');
        _selectedProject = null;
        _update(current: Loadable.ready(null));
        _loadSessions(1, _selectedMonth);
      },
      onError: (e, stack) {
        _update(
            current: Loadable.error(
                (e is AppError) ? e : AppError.fromMessage('An error occurred'.i18n),
                _currentSession.value));
        _log.finer('finishSession - error: $e');
      },
    );
  }

  void currentSessionErrorConsumed() {
    _update(current: Loadable.ready(_currentSession.value));
  }

  void sessionChanged(Session session) {
    log.fine('sessionChanged $session');
    if (_currentSession.value?.id == session.id) {
      log.fine('sessionChanged update current');
      _update(current: Loadable.ready(session));
    }
    var paginated = _sessionsByMonth.value;
    if (paginated?.list?.isNotEmpty == true) {
      final index = paginated!.list!.indexWhere((element) => element.id == session.id);
      if (index > -1) {
        List<Session> list = List.from(paginated.list!);
        list[index] = session;
        _sessionsByMonth = Loadable.ready(Paginated(
          list,
          _sessionsByMonth.value?.page ?? 0,
          _sessionsByMonth.value?.totalPageCount ?? 0,
          _sessionsByMonth.value?.totalCount ?? 0,
        ));
        _update();
      } else {
        _loadSessions(1, _selectedMonth);
      }
    }

    // var list = _monthlySessionsAndLabels.value;
    // if (list?.isNotEmpty == true) {
    //   int sessionIndex = -1;
    //   final index = list!.indexWhere((e) {
    //     sessionIndex = e.sessions.indexWhere((element) => element.id == session.id);
    //     return sessionIndex > -1;
    //   });
    //   log.fine('sessionChanged update index: $index, sessionIndex: $sessionIndex');
    //   if (index > -1) {
    //     list = List.from(list);
    //     var summary = list[index];
    //     var daySessions = List<Session>.from(summary.sessions);
    //     daySessions[sessionIndex] = session;
    //     list[index] = SessionsDaySummary(
    //       day: summary.day,
    //       time: summary.time,
    //       count: summary.count,
    //       sessions: daySessions,
    //     );
    //     _monthlySessionsAndLabels = Loadable.ready(list);
    //     _update();
    //   } else {
    //     _loadSessions(1, _selectedMonth);
    //   }
    // }
  }

  final log = Logger('SessionSCubit');

  void sessionDeleted(Session? session) {
    log.fine('sessionDeleted $session');
    if (session == null) return;
    if (_currentSession.value?.id == session.id) {
      refreshCurrent();
    }
    var paginated = _sessionsByMonth.value;
    if (paginated?.list?.isNotEmpty == true) {
      final index = paginated!.list!.indexWhere((element) => element.id == session.id);
      if (index > -1) {
        List<Session> list = List.from(paginated.list!);
        list.removeAt(index);
        _sessionsByMonth = Loadable.ready(Paginated(
          list,
          _sessionsByMonth.value?.page ?? 0,
          _sessionsByMonth.value?.totalPageCount ?? 0,
          (_sessionsByMonth.value?.totalCount ?? 0) - 1,
        ));
        _update();
      } else {
        _loadSessions(1, _selectedMonth);
      }
    }
    // var list = _monthlySessionsAndLabels.value;
    // if (list?.isNotEmpty == true) {
    //   int sessionIndex = -1;
    //   final index = list!.indexWhere((e) {
    //     sessionIndex = e.sessions.indexWhere((element) => element.id == session.id);
    //     return sessionIndex > -1;
    //   });
    //   if (index > -1) {
    //     list = List.from(list);
    //     var summary = list[index];
    //     var daySessions = List<Session>.from(summary.sessions);
    //     daySessions.removeAt(sessionIndex);
    //     if (daySessions.isEmpty) {
    //       list.removeAt(index);
    //     } else {
    //       list[index] = SessionsDaySummary(
    //         day: summary.day,
    //         time: summary.time - (session.duration ?? Duration()),
    //         count: summary.count - 1,
    //         sessions: daySessions,
    //       );
    //     }
    //     _monthlySessionsAndLabels = Loadable.ready(list);
    //     _update();
    //   }
    // }
  }

  Future uploadSaveData() async {
    _log.fine('uploadSaveData');
    if (!_currentSession.inProgress && _currentSession.value == null) {
      await _sessionsRepository.uploadOfflineSessionsAndBreaks();
    }
  }

  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      // Show tracking authorization dialog and ask for permission
      await Future.delayed(const Duration(milliseconds: 200));

      final status = await AppTrackingTransparency.requestTrackingAuthorization();

      if (status == TrackingStatus.authorized) {
        await _geolocationService.requestPermission().then(
          (value) {
            hasPermission = value;
            _update();
          },
          onError: (e, stack) {
            _log.shout('requestPermission', e, stack);
          },
        );
      }
    } else {
      await _geolocationService.requestPermission().then(
        (value) {
          hasPermission = value;
          _update();
        },
        onError: (e, stack) {
          _log.shout('requestPermission', e, stack);
        },
      );
    }
    return hasPermission;
  }

  Future updateSessionNote(String text) async {
    if (_currentSession.value != null && _currentSession.inProgress != true) {
      Session session = _currentSession.value!;
      _log.fine('updateSessionNote $session');
      return _sessionsRepository.updateSession(session.copyWith(note: text)).then((value) {
        _update(current: Loadable.ready(value));
      });
    }
    return null;
  }
}