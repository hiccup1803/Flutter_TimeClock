import 'dart:core';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/loadable.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/repository/history_repository.dart';
import 'package:staffmonitor/service/network_status_service.dart';
import 'package:staffmonitor/utils/time_utils.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._repository, this._networkStatusService, this._mapListToDates)
      : super(HistoryInitial());

  final HistoryRepository _repository;
  final NetworkStatusService _networkStatusService;
  final Map<DateTime, List> Function(Paginated? paginated) _mapListToDates;
  final Map<String, Loadable<Paginated>> _cachedMonths = Map();
  final log = Logger('HistoryCubit');
  late DateTime _selected;

  String get _selectedKey => keyFromDate(_selected);

  String keyFromDate(DateTime dateTime) => '${dateTime.year}_${dateTime.month}';

  void init(DateTime initialDay) {
    _selected = initialDay;
    refresh();
  }

  void changeMonth(DateTime day) {
    _selected = day;
    refresh();
  }

  void clearCache() {
    _cachedMonths.clear();
  }

  void refresh() async {
    final key = _selectedKey;
    final first = _selected.firstDayOfMonth;
    final last = _selected.nextMonth.firstDayOfMonth;
    final cached = _cachedMonths[key];
    if (cached?.inProgress != true) {
      _cachedMonths[key] = Loadable.inProgress(cached?.value);
      updateState(key);
    }
    bool netStatus = await _networkStatusService.isNetworkAvailable();

    if (netStatus)
      _repository.getHistoryItems(first, last, 1).then(
        (paginated) {
          Loadable<Paginated> loadable;
          if (paginated.hasMore) {
            loadable = Loadable.inProgress(paginated);
          } else {
            loadable = Loadable.ready(paginated);
          }
          _cachedMonths[key] = loadable;
          updateState(key);
          if (loadable.inProgress) {
            getNextPage(key, first, last, paginated);
          }
        },
        onError: (e, stack) {
          log.shout('refresh error', e, stack);
        },
      );
  }

  void getNextPage(
    String key,
    DateTime after,
    DateTime before,
    Paginated paginated,
  ) {
    _repository.getHistoryItems(after, before, paginated.page + 1).then(
      (result) {
        paginated += result;
        Loadable loadable;
        if (paginated.hasMore) {
          loadable = Loadable.inProgress(paginated);
        } else {
          loadable = Loadable.ready(paginated);
        }
        _cachedMonths[key] = loadable as Loadable<Paginated<dynamic>>;
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
      final month = _cachedMonths[key]!;
      log.finer('updateState - cached: $month');
      if (month.inProgress) {
        log.fine('emit in progress');
        emit(HistoryReady(Loadable.inProgress(_mapListToDates(month.value))));
      } else if (month.error != null) {
        log.fine('emit error');
        emit(HistoryReady(Loadable.error(month.error, _mapListToDates(month.value))));
      } else {
        log.fine('emit ready');
        emit(HistoryReady(Loadable.ready(_mapListToDates(month.value))));
      }
    } else {
      log.fine('update state key not match selected: $_selectedKey incoming: $key');
    }
  }

  void onItemChanged(dynamic item, {DateTime? month}) {
    refresh();
    // if (month != null) {
    //   final cachedMonth = _cachedMonths[keyFromDate(month)];
    //   if (cachedMonth?.inProgress != true && cachedMonth.value != null){
    //
    //   }
    // }else{
    //   refresh();
    // }
    log.fine('onItemChanged: $item');
  }

  void onItemDeleted(dynamic item) {
    refresh();
    log.fine('onItemDeleted: $item');
  }
}
