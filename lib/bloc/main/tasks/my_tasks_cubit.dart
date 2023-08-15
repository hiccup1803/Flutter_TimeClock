import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import '../../../../model/calendar_task.dart';
import '../../../../repository/projects_repository.dart';

part 'my_tasks_state.dart';

class MyTasksCubit extends Cubit<MyTasksState> {
  MyTasksCubit(this._projectsRepository, DateTime month) : super(MyTasksInitial()) {
    init(DateTime.now());
  }

  final log = Logger('MyTasksCubit');
  final ProjectsRepository _projectsRepository;

  late DateTime _selected;

  late List<CalendarTask> _tasks = List.empty();

  Future<void> init(DateTime initialDay) async {
    _selected = initialDay;

    final first = _selected.firstDayOfMonth;
    final last = _selected.lastDayOfMonth;

    await _projectsRepository.getMyTasksList(first, last, 0).then((value) {
      _tasks = value;
    }, onError: (e, stack) {});
    await _projectsRepository.getMyTasksList(first, last, 1).then((value) {
      _tasks.addAll(value);

      _updateState();
    }, onError: (e, stack) {});
  }

  void _updateState() {
    emit(MyTasksReady(_selected, _tasks));
  }

  void changeMonth(DateTime newDate) {
    if (newDate.firstDayOfMonth != _selected) {
      emit(MyTasksInitial());
      init(newDate.firstDayOfMonth);
    }
  }

  Future<bool> updateFilter(int assignee) async {
    await init(_selected).then((value) {});
    return true;
  }
}
