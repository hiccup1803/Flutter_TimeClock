import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/admin_session.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/employee_summary.dart';
import 'package:staffmonitor/model/loadable.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/session_wage_duration.dart';
import 'package:staffmonitor/model/sessions_day_summary.dart';
import 'package:staffmonitor/model/sessions_month_summary.dart';
import 'package:staffmonitor/repository/sessions_repository.dart';
import 'package:staffmonitor/repository/users_repository.dart';
import 'package:staffmonitor/utils/time_utils.dart';

part 'admin_sessions_state.dart';

class AdminSessionsCubit extends Cubit<AdminSessionsState> {
  AdminSessionsCubit(this._sessionsRepository, this._usersRepository)
      : super(AdminSessionsInitial());

  final log = Logger('AdminSessionsCubit');
  final SessionsRepository _sessionsRepository;
  final UsersRepository _usersRepository;

  DateTime _selectedMonth = DateTime.now().firstDayOfMonth;

  Loadable<List<Profile>?> _users = Loadable.ready(null);
  late Loadable<Paginated<AdminSession>> _sessions;

  void refresh({bool? force}) {
    if (_users.value?.isNotEmpty != true) {
      log.finest('init users in cubit');
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
    _sessions = Loadable.inProgress();
    _updateState();
    _loadSessions(1, _selectedMonth);
  }

  void _loadSessions(int page, DateTime month) {
    _sessionsRepository.getAdminSessions(page: page, perPage: 25, month: month).then(
      (value) {
        if (month != _selectedMonth) {
          //selected month changed
          return;
        }
        if (_sessions.value?.page != null && _sessions.value!.page < value.page) {
          value = _sessions.value! + value;
        }
        if (value.hasMore) {
          _sessions = Loadable.inProgress(value);
          _loadSessions(value.page + 1, month);
        } else {
          _sessions = Loadable.ready(value);
        }
        _updateState();
      },
      onError: (e, stack) {
        if (month != _selectedMonth) {
          return;
        }
        log.shout('_loadSession page:$page', e, stack);
        if (e is AppError) {
          _sessions = Loadable.error(e, _sessions.value);
        } else {
          _sessions = Loadable.error(AppError.from(e), _sessions.value);
        }
        log.shout('_loadSession _sessions:$_sessions');
        _updateState();
      },
    );
  }

  void _updateState() {
    if (_sessions.inProgress != true) {
      if (_sessions.error != null) {
        log.fine('_updateState: empty sessions\n');
        emit(AdminSessionsReady(
          _selectedMonth,
          Loadable.error(_sessions.error),
          Loadable.error(_sessions.error),
          Loadable.error(_sessions.error),
          _users,
        ));
        return;
      }

      if (_sessions.value?.list?.isNotEmpty != true) {
        log.fine('_updateState: empty sessions\n');
        emit(AdminSessionsReady(
          _selectedMonth,
          Loadable.ready(SessionsMonthSummary(0, 0, Duration(), {})),
          Loadable.ready([]),
          Loadable.ready([]),
          _users,
        ));
        return;
      }

      Duration monthDuration = Duration();

      String rateCurrency = '';
      Map<String, WageAndDuration> mappedSessionWageCurrency = {};
      Map<int, EmployeeSummary> mappedSummaries = {};
      SessionsDaySummary<AdminSession>? header;
      List<SessionsDaySummary<AdminSession>>? daySummaries = _sessions.value?.list?.map((session) {
        monthDuration += session.duration ?? Duration();

        rateCurrency = session.rateCurrency ?? '';

        if (mappedSummaries[session.userId] == null) {
          mappedSummaries[session.userId] = EmployeeSummary(session.userId, []).addSession(session);
        } else {
          mappedSummaries[session.userId] = mappedSummaries[session.userId]!.addSession(session);
        }

        if (mappedSessionWageCurrency[rateCurrency.toUpperCase()] == null) {
          mappedSessionWageCurrency[rateCurrency.toUpperCase()] = WageAndDuration().add(session);
        } else {
          mappedSessionWageCurrency[rateCurrency.toUpperCase()] =
              mappedSessionWageCurrency[rateCurrency.toUpperCase()]!.add(session);
        }

        return SessionsDaySummary<AdminSession>(
          day: session.clockIn,
          count: 1,
          time: session.duration ?? const Duration(),
          sessions: [session],
        );
      }).fold<List<SessionsDaySummary<AdminSession>>>(
        <SessionsDaySummary<AdminSession>>[],
        (List<SessionsDaySummary<AdminSession>> list, summary) {
          if (header?.day?.day == summary.day?.day) {
            header = SessionsDaySummary<AdminSession>(
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
      log.fine('_updateState: ready sessions ${_sessions.value}');

      emit(AdminSessionsReady(
        _selectedMonth,
        Loadable.ready(SessionsMonthSummary(daySummaries?.length ?? 0,
            _sessions.value?.list?.length ?? 0, monthDuration, mappedSessionWageCurrency)),
        Loadable.ready(List.of(mappedSummaries.values)),
        Loadable.ready(daySummaries),
        _users,
      ));
    } else {
      log.fine('_updateState: in progress all');
      emit(AdminSessionsReady(
        _selectedMonth,
        Loadable.inProgress(),
        Loadable.inProgress(),
        Loadable.inProgress(),
        _users,
      ));
    }
  }

  void changeMonth(DateTime newDate) {
    if (newDate.firstDayOfMonth != _selectedMonth) {
      _selectedMonth = newDate.firstDayOfMonth;
      refresh();
    }
  }

  Future<AdminSession> acceptSession(AdminSession session) {
    return _sessionsRepository.acceptAdminSession(session.id).then((value) {
      _updateSession(value);
      return value;
    });
  }

  Future<bool> deleteSession(AdminSession session) async {
    return _sessionsRepository.deleteAdminSession(session.id).then((value) {
      if (value == true) {
        removeSession(session);
      }
      return value;
    });
  }

  void _updateSession(AdminSession session) {
    final sessions = _sessions;
    if (sessions.inProgress != true && sessions.hasError == false && sessions.value != null) {
      final Paginated<AdminSession> paginated = sessions.value!;
      final List<AdminSession> list = List.from(paginated.list ?? []);
      final index = list.indexWhere((element) => element.id == session.id);
      if (index > -1) {
        list[index] = session;
        _sessions = Loadable.ready(
            Paginated(list, paginated.page, paginated.totalPageCount, paginated.totalCount));
        _updateState();
      }
    }
  }

  void removeSession(AdminSession session) {
    final sessions = _sessions;
    if (sessions.inProgress != true && sessions.hasError == false && sessions.value != null) {
      final Paginated<AdminSession> paginated = sessions.value!;
      final List<AdminSession> list = List.from(paginated.list ?? []);
      final index = list.indexWhere((element) => element.id == session.id);
      if (index > -1) {
        list.removeAt(index);
        _sessions = Loadable.ready(
            Paginated(list, paginated.page, paginated.totalPageCount, paginated.totalCount));
        _updateState();
      }
    }
  }
}
