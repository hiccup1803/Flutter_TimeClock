import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/loadable.dart';
import 'package:staffmonitor/model/off_time.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/repository/off_times_repository.dart';

part 'my_off_times_state.dart';

class MyOffTimesCubit extends Cubit<MyOffTimesState> {
  MyOffTimesCubit(this._offTimesRepository) : super(MyOffTimesInitial());

  final log = Logger('myOffTimesCubit');
  final OffTimesRepository _offTimesRepository;

  int _selectedYear = DateTime.now().year;

  Loadable<Paginated<OffTime>> _offTimes = Loadable.inProgress();

  void init(int initialYear) {
    _selectedYear = initialYear;
    refresh();
  }

  void changeYear(int year) {
    if (year != _selectedYear) {
      log.fine('changeYear: $year');
      _selectedYear = year;
      refresh();
    }
  }

  void refresh() {
    _offTimes = Loadable.inProgress();
    _updateState();
    _loadOffTimes(1, _selectedYear);
  }

  void _loadOffTimes(int page, int year) {
    log.fine('_in loadOffTimes($page, $year)');

    DateTime _selectedYearFromDate = new DateTime(year, 1, 1);
    DateTime _selectedYearToDate = new DateTime(year, 12, 31);

    _offTimesRepository.getMyOffTimes(_selectedYearFromDate, _selectedYearToDate, page).then(
      (value) {
        if (year != _selectedYear) {
          log.fine('_in if ($_selectedYear, $year)');
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
    emit(
      MyOffTimesReady(DateTime(_selectedYear), _offTimes.transform((value) => value.list ?? [])),
    );
  }
}
