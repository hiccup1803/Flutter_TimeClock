import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/admin_session_file.dart';
import 'package:staffmonitor/model/admin_task_file.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/loadable.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/repository/files_repository.dart';
import 'package:staffmonitor/utils/time_utils.dart';

part 'admin_files_state.dart';

class AdminFilesCubit extends Cubit<AdminFilesState> {
  AdminFilesCubit(this._filesRepository) : super(AdminFilesInitial());

  final log = Logger('AdminFilesCubit');
  final FilesRepository _filesRepository;

  DateTime _selectedMonth = DateTime.now().firstDayOfMonth;

  late Loadable<Paginated<AdminSessionFile>> _files;
  late Loadable<Paginated<AdminTaskFile>> _taskFiles;
  Map<DateTime, List<AdminSessionFile>> mappedFiles = {};
  Map<DateTime, List<AdminTaskFile>> mappedTaskFiles = {};
  int _currentPage = 1;
  int _currentTaskPage = 1;
  int _currentTabIndex = 0;
  List<dynamic> _filterList = [DateTime.now(), 0, 0];

  void refresh() {
    _currentPage = 1;
    _currentTaskPage = 1;
    _files = Loadable.inProgress();
    _taskFiles = Loadable.inProgress();
    _updateState();
    _loadFiles(1);
    _loadTaskFiles(1);
  }

  void tabChange(int currentTabIndex) {
    _currentTabIndex = currentTabIndex;
    _updateState();
  }

  void loadMoreFiles() {
    _loadFiles(_currentPage);
  }

  List<dynamic> currentFilter() {
    return _filterList;
  }

  void loadMoreTaskFiles() {
    _loadTaskFiles(_currentTaskPage);
  }

  void _loadFiles(int page) {
    _filesRepository
        .getAdminSessionFiles(
            page: page,
            uploaderId: _filterList[2],
            createdAt: _filterList[0],
            sessionProjectId: _filterList[1])
        .then(
      (value) {
        if (page == 1) {
          _files = Loadable.inProgress();
        } else {
          _files = Loadable.inProgress(_files.value!);
        }
        if (_files.value?.page != null && _files.value!.page < value.page) {
          value = _files.value! + value;
        }
        if (value.hasMore) {
          _currentPage = value.page + 1;
        }
        _files = Loadable.ready(value);
        _updateState();
      },
      onError: (e, stack) {
        log.shout('_loadAdminFiles page:$page', e, stack);
        if (e is AppError) {
          _files = Loadable.error(e, _files.value);
        } else {
          _files = Loadable.error(AppError.from(e), _files.value);
        }
        log.shout('_loadAdminFiles _file:$_files');
        _updateState();
      },
    );
  }

  void _loadTaskFiles(int page) {
    _filesRepository
        .getAdminTaskFiles(
            page: page,
            uploaderId: _filterList[2],
            createdAt: _filterList[0],
            taskProjectId: _filterList[1])
        .then(
      (value) {
        if (page == 1) {
          _taskFiles = Loadable.inProgress();
        } else {
          _taskFiles = Loadable.inProgress(_taskFiles.value!);
        }
        if (_taskFiles.value?.page != null && _taskFiles.value!.page < value.page) {
          value = _taskFiles.value! + value;
        }
        if (value.hasMore) {
          _currentTaskPage = value.page + 1;
        }
        _taskFiles = Loadable.ready(value);
        _updateState();
      },
      onError: (e, stack) {
        log.shout('_loadAdminTaskFiles page:$page', e, stack);
        if (e is AppError) {
          _taskFiles = Loadable.error(e, _taskFiles.value);
        } else {
          _taskFiles = Loadable.error(AppError.from(e), _taskFiles.value);
        }
        log.shout('_loadAdminTaskFiles _file:$_files');
        _updateState();
      },
    );
  }

  void _updateState() {
    if (_currentTabIndex == 0 && _files.inProgress != true) {
      if (_files.error != null) {
        log.fine('_updateState: error\n');
        emit(AdminFilesReady(
          _selectedMonth,
          Loadable.error(_files.error),
          Loadable.ready(mappedTaskFiles),
        ));
        return;
      }

      if (_files.value?.list?.isNotEmpty != true) {
        log.fine('_updateState: empty sessionFiles \n');
        emit(AdminFilesReady(
          _selectedMonth,
          Loadable.ready({}),
          Loadable.ready(mappedTaskFiles),
        ));
        return;
      }

      mappedFiles = {};

      _files.value?.list?.forEach((file) {
        DateTime day = file.createdAt!.startOfDay;
        if (mappedFiles[day] == null) {
          mappedFiles[day] = [];
        }
        mappedFiles[day]!.add(file);
      });

      log.fine('_updateState: ready files ${_files.value}');

      emit(AdminFilesReady(
        _selectedMonth,
        Loadable.ready(mappedFiles),
        Loadable.ready(mappedTaskFiles),
      ));
    } else if (_currentTabIndex == 0) {
      emit(AdminFilesReady(
        _selectedMonth,
        Loadable.inProgress(),
        Loadable.ready(mappedTaskFiles),
      ));
    }

    if (_currentTabIndex == 1 && _taskFiles.inProgress != true) {
      if (_taskFiles.error != null) {
        log.fine('_updateState: error\n');
        emit(AdminFilesReady(
          _selectedMonth,
          Loadable.ready(mappedFiles),
          Loadable.error(_taskFiles.error),
        ));
        return;
      }

      if (_taskFiles.value?.list?.isNotEmpty != true) {
        log.fine('_updateState: empty taskFiles\n');
        emit(AdminFilesReady(
          _selectedMonth,
          Loadable.ready(mappedFiles),
          Loadable.ready({}),
        ));
        return;
      }

      mappedTaskFiles = {};

      _taskFiles.value?.list?.forEach((file) {
        DateTime day = file.createdAt!.startOfDay;
        if (mappedTaskFiles[day] == null) {
          mappedTaskFiles[day] = [];
        }
        mappedTaskFiles[day]!.add(file);
      });

      log.fine('_updateState: ready task files ${_taskFiles.value}');

      emit(AdminFilesReady(
        _selectedMonth,
        Loadable.ready(mappedFiles),
        Loadable.ready(mappedTaskFiles),
      ));
    } else if (_currentTabIndex == 1) {
      emit(AdminFilesReady(
        _selectedMonth,
        Loadable.ready(mappedFiles),
        Loadable.inProgress(),
      ));
    }
  }

  void updateFilter(List<dynamic> value) {
    _filterList = value;
    refresh();
  }
}