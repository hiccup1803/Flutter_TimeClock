import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/project.dart';
import 'package:staffmonitor/model/sessions_summary.dart';
import 'package:staffmonitor/repository/projects_repository.dart';

part 'my_projects_state.dart';

class MyProjectsCubit extends Cubit<MyProjectsState> {
  MyProjectsCubit(this._projectsRepository, DateTime month) : super(ProjectsInitial()) {
    init(month);
  }

  Map<int?, SessionsSummary> _summaries = Map();
  List<Project>? _projects = List.empty();
  DateTime? _month;
  bool? _initiated;

  final ProjectsRepository _projectsRepository;
  final log = Logger('ProjectsCubit');

  void init(DateTime month) {
    emit(ProjectsLoading(_month, _projects, _summaries));
    _projectsRepository.getProjects(force: true).then((value) {
      _projects = value;
      _initiated = true;
      changeMonth(month);
    }, onError: (e, stack) {
      log.shout('getProjects', e, stack);
      emit(ProjectsReady(_month, _projects, _summaries));
      _initiated = true;
    });
  }

  void changeMonth(DateTime date, {bool force = true}) {
    log.fine('changeMonth $date');
    if (_initiated != true) {
      return;
    }
    if (force || date.month != _month?.month) {
      _month = date;
      emit(ProjectsLoading(_month, _projects, _summaries));

      final List<Future<SessionsSummary?>> futures = <Future<SessionsSummary>>[];
      _projects!.forEach((pro) {
        futures.add(_projectsRepository.getSessionsSummary(pro.id, _month!));
      });

      Future.wait(futures).then((results) {
        _summaries = Map.fromIterable(results, key: (element) => element.projectId);
        emit(ProjectsReady(_month, _projects, _summaries));
      }, onError: (e, stack) {
        log.shout('getSummaries', e, stack);
        emit(ProjectsReady(_month, _projects, _summaries));
      });
    }
  }

  refresh() {
    changeMonth(_month ?? DateTime.now(), force: true);
  }
}
