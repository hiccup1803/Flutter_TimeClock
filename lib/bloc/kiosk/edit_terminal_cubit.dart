import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/admin_project.dart';
import 'package:staffmonitor/model/admin_terminal.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/app_file.dart';
import 'package:staffmonitor/model/calendar_note.dart';
import 'package:staffmonitor/model/calendar_task.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/project.dart';
import 'package:staffmonitor/repository/projects_repository.dart';
import 'package:staffmonitor/repository/terminal_repository.dart';
import 'package:staffmonitor/service/api/converter/json_bool_converter.dart';
import 'package:staffmonitor/utils/time_utils.dart';

part 'edit_terminal_state.dart';

class EditTerminalCubit extends Cubit<EditTerminalState> {
  EditTerminalCubit(this._terminalRepository, this._projectRepository, this.profile, this._admin)
      : super(EditTerminalInitial());

  final TerminalRepository _terminalRepository;
  final ProjectsRepository _projectRepository;
  final log = Logger('EditTerminalCubit');
  late bool _admin;
  final Profile? profile;
  late AdminTerminal _task;
  late AdminTerminal _editedTask;

  bool _hasChanged = false;

  bool _photoVerification = false;

  Project _selectedProject = Project.noProject;

  bool titleChanged = false;

  bool get requireSaving => titleChanged || _editedTask != _task;

  void init(AdminTerminal? task, {Project? defaultProject, DateTime? date}) async {
    log.fine('init task: $task, {$defaultProject, $date}');

    if (task == null) {
      _task = AdminTerminal.create();
    } else {
      if (task.name.isEmpty) {
        emit(EditTerminalProcessing(task));
        if (_admin) {
          _task = await _terminalRepository.getAdminTerminalById(task.id);
        }
      } else {
        _task = task.copyWith();
      }
    }

    _selectedProject = _task.project ?? Project.noProject;

    _photoVerification = _task.photoVerification == 0 ? false : true;

    _editedTask = _task.copyWith();

    emit(EditTerminalReady(_editedTask, requireSaving, _hasChanged,
        _task.project ?? Project.noProject, _photoVerification));
  }

  void changeTitle(String title) {
    if (title.isEmpty) {
      titleChanged = false;
      emit(EditTerminalValidator(_editedTask, _selectedProject, titleError: 'Wymagane'));
    } else if (title == _editedTask.name) {
      titleChanged = false;
      emit(EditTerminalReady(
          _editedTask, requireSaving, _hasChanged, _selectedProject, _photoVerification));
    } else {
      titleChanged = true;
      _editedTask = _editedTask.copyWith(name: title);
      emit(EditTerminalReady(
          _editedTask, requireSaving, _hasChanged, _selectedProject, _photoVerification));
    }
  }

  void photoVerificationChanged(bool b) {
    if (b != _photoVerification) {
      _photoVerification = b;
      _editedTask = _editedTask.copyWith(photoVerification: _photoVerification ? 1 : 0);
      emit(EditTerminalReady(
          _editedTask, requireSaving, _hasChanged, _selectedProject, _photoVerification));
    }
  }

  void selectProject(Project project, int profileId) {

    if (project != _selectedProject) {
      _selectedProject = project;

      if (project.id == Project.noProject.id) {
        _editedTask =
            _editedTask.copyWith(project: AdminProject.create(project.name, project.colorHash));

        emit(EditTerminalReady(
            _editedTask, requireSaving, _hasChanged, _selectedProject, _photoVerification));
      } else {
        _projectRepository.getAdminProjectByID(project).then((value) {
          _editedTask = _editedTask.copyWith(project: value);
          emit(EditTerminalReady(
              _editedTask, requireSaving, _hasChanged, _selectedProject, _photoVerification));
        });
      }
    }
  }

  void errorConsumed() => stateConsumed();

  void stateConsumed() {
    emit(EditTerminalReady(
        _editedTask, requireSaving, _hasChanged, _selectedProject, _photoVerification));
  }

  void refresh() {
    init(_task);
  }

  Future<bool> save() async {
    emit(EditTerminalProcessing(_editedTask));
    return await apiTaskRequest().then(
      (task) {
        _task = task;
        _editedTask = task;
        _hasChanged = true;

        emit(EditTerminalSaved(_editedTask, closePage: true));

        return true;
      },
      onError: (e, stack) {
        log.shout('save', e, stack);

        emit(
            EditTerminalError(_editedTask, e is AppError ? e : AppError.fromMessage(e.toString())));
        return false;
      },
    );
  }

  void deleteTask() {
    _terminalRepository.deleteAdminTerminal(_task.id).then(
      (result) {
        emit(EditTerminalDeleted(_editedTask));
      },
      onError: (e, stack) {
        emit(EditTerminalError(_editedTask, AppError.from(e)));
      },
    );
  }

  void generateCode() {
    _terminalRepository.generateCode(_task.id).then(
      (result) {
        _task = result;
        _editedTask = result;
        _hasChanged = true;

        emit(EditTerminalCodeSaved(_editedTask));
      },
      onError: (e, stack) {
        emit(EditTerminalError(_editedTask, AppError.from(e)));
      },
    );
  }

  Future<AdminTerminal> apiTaskRequest() {
    if (_editedTask.isCreate) {
      return _terminalRepository.createAdminTerminal(
          _editedTask, JsonBoolConverter().toJson(_photoVerification), _selectedProject);
    } else if (profile!.isAdmin || profile!.isSupervisor) {
      return _terminalRepository.updateAdminTerminal(
          _editedTask, JsonBoolConverter().toJson(_photoVerification), _selectedProject);
    } else {
      return Future.value(_editedTask);
    }
  }
}
