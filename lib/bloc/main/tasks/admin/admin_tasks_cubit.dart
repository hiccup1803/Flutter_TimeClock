import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/utils/time_utils.dart';
import '../../../../model/calendar_task.dart';
import '../../../../repository/projects_repository.dart';

part 'admin_tasks_state.dart';

class AdminTasksCubit extends Cubit<AdminTasksState> {
  AdminTasksCubit(this._projectsRepository, DateTime month) : super(AdminTasksInitial()) {
    init(DateTime.now());
  }

  final log = Logger('AdminTasksCubit');
  final ProjectsRepository _projectsRepository;

  late DateTime _selected;

  late List<CalendarTask> _tasks = List.empty();
  int assignee = 0;

  Future<void> init(DateTime initialDay) async {
    _selected = initialDay;

    final first = _selected.firstDayOfMonth;
    final last = _selected.lastDayOfMonth;

    await _projectsRepository.getAdminTasksList(first, last, assignee, 0).then((value) {
      _tasks = value;
    }, onError: (e, stack) {});
    await _projectsRepository.getAdminTasksList(first, last, assignee, 1).then((value) {
      _tasks.addAll(value);

      _updateState();
    }, onError: (e, stack) {});
  }

  void _updateState() {
    emit(AdminTasksReady(_selected, _tasks));
  }

  void changeMonth(DateTime newDate) {
    if (newDate.firstDayOfMonth != _selected) {
      emit(AdminTasksInitial());
      init(newDate.firstDayOfMonth);
    }
  }

  void taskDeleted(CalendarTask? task) {
    if (task == null) return;
    if (_tasks.isNotEmpty == true) {
      final index = _tasks.indexWhere((element) => element.id == task.id);
      if (index > -1) {
        _tasks.removeAt(index);
        _updateState();
      } else {
        _updateState();
      }
    }
  }

  Future<bool> updateFilter(int assignee) async {
    this.assignee = assignee;
    await init(_selected).then((value) {});
    return true;
  }
}
