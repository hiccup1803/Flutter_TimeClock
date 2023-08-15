import 'dart:core';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/calendar_task.dart';
import 'package:staffmonitor/model/loadable.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/model/sessions_summary.dart';
import 'package:staffmonitor/repository/off_times_repository.dart';
import 'package:staffmonitor/repository/projects_repository.dart';
import 'package:staffmonitor/repository/sessions_repository.dart';
import 'package:staffmonitor/utils/time_utils.dart';

part 'my_calendars_state.dart';

class MyCalendarsCubit extends Cubit<MyCalendarsState> {
  MyCalendarsCubit(this._projectsRepository, this._historyRepository, this._sessionsRepository,
      this._mapListToDates, DateTime month)
      : super(CalendarsInitial()) {
    init(DateTime.now());
  }

  final ProjectsRepository _projectsRepository;
  final OffTimesRepository _historyRepository;
  final SessionsRepository _sessionsRepository;
  final Map<DateTime, List> Function(Paginated? paginated) _mapListToDates;
  List<CalendarTask>? _tasks = List.empty();
  final Map<String, Loadable<Paginated>> _cachedOffTimeMonths = Map();
  final Map<String, Loadable<Paginated>> _cachedSessionMonths = Map();

  final log = Logger('------>> MyCalendarCubit');
  late DateTime _selected;
  List<bool> _filterList = [true, true, true];

  DateTime? _month;

  String get _selectedKey => keyFromDate(_selected);

  List<bool> get filterList => _filterList;

  String keyFromDate(DateTime dateTime) => '${dateTime.year}_${dateTime.month}';

  Future<void> init(DateTime initialDay) async {
    _selected = initialDay;

    final first = _selected.tenDaysBeforeOfMonth;
    final last = _selected.nextMonth.tenDaysAfterOfMonth;

    await _projectsRepository.getTasks(first, last).then((value) {
      _tasks = value;
    }, onError: (e, stack) {});

    await refreshOffTime();
    await refreshSession();
  }

  void changeMonth(DateTime date, {bool force = true}) {
    if (date.month != _selected.month) _selected = date;

    emit(CalendarsInitial());
    init(date);
  }

  void getNextPage(
    String key,
    DateTime after,
    DateTime before,
    Paginated paginated,
  ) {
    _historyRepository.getHistoryItems(after, before, paginated.page + 1).then(
      (result) {
        paginated += result;
        Loadable loadable;
        if (paginated.hasMore) {
          loadable = Loadable.inProgress(paginated);
        } else {
          loadable = Loadable.ready(paginated);
        }
        _cachedOffTimeMonths[key] = loadable as Loadable<Paginated<dynamic>>;
        updateState(key);
        getNextPage(key, after, before, paginated);
      },
      onError: (e, stack) {
        log.shout('next page error', e, stack);
      },
    );
  }

  void updateState(String key) {
    if (_selectedKey == key) {
      if (_cachedOffTimeMonths[key] != null && _cachedSessionMonths[key] != null) {
        final offTimes = _cachedOffTimeMonths[key]!;
        final sessions = _cachedSessionMonths[key]!;
        log.finer('updateState - cached: $offTimes');
        Loadable<Map<DateTime, List>> offTimesValue;
        Loadable<Paginated> sessionsValue;
        if (offTimes.inProgress) {
          log.fine('emit in progress');
          offTimesValue = Loadable.inProgress(_mapListToDates(offTimes.value));
        } else if (offTimes.error != null) {
          log.fine('emit error');
          offTimesValue = Loadable.error(offTimes.error, _mapListToDates(offTimes.value));
        } else {
          log.fine('emit ready');
          offTimesValue = Loadable.ready(_mapListToDates(offTimes.value));
        }
        if (sessions.inProgress) {
          log.fine('emit in progress');
          sessionsValue = Loadable.inProgress(sessions.value);
        } else if (sessions.error != null) {
          log.fine('emit error');
          sessionsValue = Loadable.error(sessions.error, sessions.value);
        } else {
          log.fine('emit ready');
          sessionsValue = Loadable.ready(sessions.value);
        }
        emit(CalendarsReady(
            _month,
            _filterList[2] ? offTimesValue : Loadable(null, true, null),
            _filterList[1] ? sessionsValue : Loadable(null, true, null),
            _filterList[0] ? _tasks : [],
            _filterList));
      }
    } else {
      log.fine('update state key not match selected: $_selectedKey incoming: $key');
    }
  }

  Future<void> refreshSession() async {
    final key = _selectedKey;
    final first = _selected.firstDayOfMonth;
    final last = _selected.nextMonth.firstDayOfMonth;
    final cachedSession = _cachedSessionMonths[key];
    if (cachedSession?.inProgress != true) {
      _cachedSessionMonths[key] = Loadable.inProgress(cachedSession?.value);
      updateState(key);
    }

    _sessionsRepository.getCalendarItems(first, last, 1).then(
      (paginated) {
        Loadable<Paginated> loadable;
        if (paginated.hasMore) {
          loadable = Loadable.inProgress(paginated);
        } else {
          loadable = Loadable.ready(paginated);
        }
        _cachedSessionMonths[key] = loadable;
        updateState(key);
        // if (loadable.inProgress) {
        //   getNextPage(key, first, last, paginated);
        // }
      },
      onError: (e, stack) {
        log.shout('refresh error', e, stack);
      },
    );
  }

  Future<void> refreshOffTime() async {
    final key = _selectedKey;
    final first = _selected.firstDayOfMonth;
    final last = _selected.nextMonth.firstDayOfMonth;
    final cachedOffTime = _cachedOffTimeMonths[key];
    if (cachedOffTime?.inProgress != true) {
      _cachedOffTimeMonths[key] = Loadable.inProgress(cachedOffTime?.value);
      updateState(key);
    }

    _historyRepository.getCalendarItems(first, last, 1).then(
      (paginated) {
        Loadable<Paginated> loadable;
        if (paginated.hasMore) {
          loadable = Loadable.inProgress(paginated);
        } else {
          loadable = Loadable.ready(paginated);
        }
        _cachedOffTimeMonths[key] = loadable;
        updateState(key);
        // if (loadable.inProgress) {
        //   getNextPage(key, first, last, paginated);
        // }
      },
      onError: (e, stack) {
        log.shout('refresh error', e, stack);
      },
    );
  }

  void updateFilter(List<bool> value) {
    _filterList = value;
    init(_selected);
  }
}
