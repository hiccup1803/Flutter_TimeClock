import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/admin_off_time.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/loadable.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/repository/off_times_repository.dart';
import 'package:staffmonitor/repository/users_repository.dart';

part 'admin_off_times_state.dart';

class AdminOffTimesCubit extends Cubit<AdminOffTimesState> {
  AdminOffTimesCubit(this._offTimesRepository, this._usersRepository)
      : super(AdminOffTimesInitial());

  final log = Logger('AdminOffTimesCubit');
  final OffTimesRepository _offTimesRepository;
  final UsersRepository _usersRepository;

  int _selectedYear = DateTime.now().year;

  Loadable<List<Profile>> _users = Loadable.ready([]);
  Loadable<Paginated<AdminOffTime>> _offTimes = Loadable.inProgress();

  void changeYear(int year) {
    if (year != _selectedYear) {
      log.fine('changeYear: $year');
      _selectedYear = year;
      refresh();
    }
  }

  void refresh() {
    if (_users.value?.isNotEmpty != true) {
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
    _offTimes = Loadable.inProgress();
    _updateState();
    _loadOffTimes(1, _selectedYear);
  }

  void onOffTimeChanged(AdminOffTime offTime) {
    _updateOffTime(offTime);
  }

  Future<AdminOffTime> acceptOffTime(AdminOffTime offTime) {
    return _offTimesRepository.acceptOffTime(offTime.id).then((value) {
      _updateOffTime(value);
      return value;
    });
  }

  Future<AdminOffTime> denyOffTime(AdminOffTime offTime) {
    return _offTimesRepository.denyOffTime(offTime.id).then((value) {
      _updateOffTime(value);
      return value;
    });
  }

  Future<bool> deleteOffTime(AdminOffTime offTime) {
    return _offTimesRepository.deleteAdminOffTime(offTime.id).then((value) {
      if (value == true) {
        _removeOffTime(offTime);
      }
      return value;
    });
  }

  void _updateOffTime(AdminOffTime adminOffTime) {
    final offTimes = _offTimes;
    if (offTimes.value != null && offTimes.hasError == false && offTimes.inProgress != true) {
      Paginated<AdminOffTime> paginated = offTimes.value!;
      List<AdminOffTime> list = List.from(paginated.list ?? []);
      int? index = paginated.list?.indexWhere((element) => element.id == adminOffTime.id);
      if (index != null && index > -1) {
        list[index] = adminOffTime;
        _offTimes = Loadable.ready(
            Paginated(list, paginated.page, paginated.totalPageCount, paginated.totalCount));
      }
      _updateState();
    }
  }

  void _removeOffTime(AdminOffTime adminOffTime) {
    final offTimes = _offTimes;
    if (offTimes.value != null && offTimes.hasError == false && offTimes.inProgress != true) {
      Paginated<AdminOffTime> paginated = offTimes.value!;
      List<AdminOffTime> list = List.from(paginated.list ?? []);
      int? index = paginated.list?.indexWhere((element) => element.id == adminOffTime.id);
      if (index != null && index > -1) {
        list.removeAt(index);
        _offTimes = Loadable.ready(
            Paginated(list, paginated.page, paginated.totalPageCount, paginated.totalCount));
      }
      _updateState();
    }
  }

  void _loadOffTimes(int page, int year) {
    log.fine('_loadOffTimes($page, $year)');

    DateTime yearStart = DateTime(year, 1, 1);
    DateTime yearEnd = DateTime(year, 12, 31);

    _offTimesRepository
        .getAdminOffTimes(page: page, perPage: 25, after: yearStart, before: yearEnd)
        .then(
      (value) {
        if (year != _selectedYear) {
          return;
        }
        if (_offTimes.value?.page != null && _offTimes.value!.page < value.page) {
          value = _offTimes.value! + value;
        }
        if (value.hasMore) {
          _offTimes = Loadable.inProgress(value);
          _loadOffTimes(value.page + 1, year);
        } else {
          _offTimes = Loadable.ready(value);
        }
        log.fine('_in list ($value)');
        _updateState();
      },
      onError: (e, stack) {
        log.shout('_loadOffTimes', e, stack);
        if (year != _selectedYear) {
          return;
        }
        if (e is AppError) {
          _offTimes = Loadable.error(e, _offTimes.value);
        } else {
          _offTimes = Loadable.error(AppError.from(e), _offTimes.value);
        }
        _updateState();
      },
    );
  }

  void _updateState() {
    emit(AdminOffTimesReady(DateTime(_selectedYear), _list, _users));
  }

  Loadable<List<AdminOffTime>> get _list {
    if (_offTimes.inProgress) {
      return Loadable.inProgress(_offTimes.value?.list ?? []);
    }
    if (_offTimes.error != null) {
      return Loadable.error(_offTimes.error, _offTimes.value?.list ?? []);
    }
    return Loadable.ready(_offTimes.value?.list ?? []);
  }
}
