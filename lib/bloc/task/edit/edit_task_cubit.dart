import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/admin_project.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/app_file.dart';
import 'package:staffmonitor/model/calendar_note.dart';
import 'package:staffmonitor/model/calendar_task.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/project.dart';
import 'package:staffmonitor/model/task_custom_value_filed.dart';
import 'package:staffmonitor/repository/company_repository.dart';
import 'package:staffmonitor/repository/profile_repository.dart';
import 'package:staffmonitor/repository/projects_repository.dart';
import 'package:staffmonitor/service/api/converter/json_bool_converter.dart';
import 'package:staffmonitor/utils/time_utils.dart';

import '../../../model/admin_task_customfiled.dart';
import '../../../model/company_profile.dart';
import '../../../model/task_customfiled.dart';

part 'edit_task_state.dart';

class EditTaskCubit extends Cubit<EditTaskState> {
  EditTaskCubit(this._projectsRepository, this._companyRepository, this.profile, this._admin)
      : super(EditTaskInitial());

  final ProjectsRepository _projectsRepository;
  final CompanyRepository _companyRepository;
  final log = Logger('EditTaskCubit');
  late bool _admin;
  final Profile? profile;
  late CalendarTask _task;
  late CalendarTask _editedTask;

  CalendarNote? _editedNote;
  late String tmpNote;

  List<TaskCustomValueFiled>? customValueFields;

  String get tmpNoteData => this.tmpNote;

  bool _hasChanged = false;

  bool _sendEmail = true;
  bool _sendPush = true;
  bool _sendImmediately = false;
  int _priority = 0;
  int _status = 0;

  Project _selectedProject = Project.noProject;

  bool titleChanged = false, isNoteChanged = false, isAssigneeSelected = false;

  bool get requireSaving =>
      titleChanged && isAssigneeSelected || isNoteChanged || _editedTask != _task;

  List<TaskCustomFiled> customFieldList = [];

  void init(CalendarTask? task, {Project? defaultProject, DateTime? date}) async {
    log.fine('init task: $task, {$defaultProject, $date}');

    if (task == null) {
      await _companyRepository.getProfileCompany().then((value) {
        if (value!.customFields.isNotEmpty) {
          List<AdminTaskCustomFiled> list = value.customFields;
          list.forEach((element) {
            if (element.target == 'task') {
              if (element.type == 'select' || element.type == 'checklist') {
                List<String> result = element.extra!.split(',');
                customFieldList.add(TaskCustomFiled(element.id, element.name, null, element.type,
                    option: result, available: element.available));
              } else {
                customFieldList.add(TaskCustomFiled(element.id, element.name, '', element.type,
                    available: element.available));
              }
            }
          });
        }
      });

      _task = CalendarTask.create(date ?? DateTime.now(), customFieldList);

      _selectedProject = _task.project ?? Project.noProject;
      _status = _task.status ?? 0;
      _priority = _task.priority ?? 0;

      _editedTask = _task.copyWith();

      emit(EditTaskReady(
          _editedTask,
          requireSaving,
          _task.end?.isAfter(DateTime.now()) ?? false,
          _hasChanged,
          _task.project ?? Project.noProject,
          _sendEmail,
          _sendPush,
          _sendImmediately));
    } else {
      isAssigneeSelected = true;
      titleChanged = true;
      if (task.createdAt == null && task.start == null) {
        emit(EditTaskProcessing(task));
        if (_admin) {
          _task = await _projectsRepository.getAdminTaskById(task.id);
        } else {
          _task = await _projectsRepository.getTaskById(task.id);
        }
      } else {
        _task = task.copyWith();
      }

      _selectedProject = _task.project ?? Project.noProject;
      _status = _task.status ?? 0;
      _priority = _task.priority ?? 0;

      _editedTask = _task.copyWith();

      emit(EditTaskReady(
          _editedTask,
          requireSaving,
          _task.end?.isAfter(DateTime.now()) ?? false,
          _hasChanged,
          _task.project ?? Project.noProject,
          _sendEmail,
          _sendPush,
          _sendImmediately));
    }
  }

  void changeStartDate(DateTime date) {
    var copyWithDate = _editedTask.start?.copyWithDate(date.year, date.month, date.day);
    _editedTask = _editedTask.copyWith(start: copyWithDate, end: copyWithDate);

    emit(EditTaskReady(_editedTask, requireSaving, _task.end?.isAfter(DateTime.now()) ?? false,
        _hasChanged, _selectedProject, _sendEmail, _sendPush, _sendImmediately));
  }

  void changeEndDate(DateTime date) {
    _editedTask = _editedTask.copyWith(
        end: (_editedTask.end ?? _editedTask.start!).copyWithDate(date.year, date.month, date.day));
    emit(EditTaskReady(_editedTask, requireSaving, _task.end?.isAfter(DateTime.now()) ?? false,
        _hasChanged, _selectedProject, _sendEmail, _sendPush, _sendImmediately));
  }

  void changeStartTime(TimeOfDay time) {
    _editedTask =
        _editedTask.copyWith(start: _editedTask.start!.copyWithTime(time.hour, time.minute));
    emit(EditTaskReady(_editedTask, requireSaving, _task.end?.isAfter(DateTime.now()) ?? false,
        _hasChanged, _selectedProject, _sendEmail, _sendPush, _sendImmediately));
  }

  void changeEndTime(TimeOfDay time) {
    _editedTask =
        _editedTask.copyWith(end: _editedTask.start!.copyWithTime(time.hour, time.minute));
    emit(EditTaskReady(_editedTask, requireSaving, _task.end?.isAfter(DateTime.now()) ?? false,
        _hasChanged, _selectedProject, _sendEmail, _sendPush, _sendImmediately));
  }

  void changeTitle(String title) {
    if (title.isEmpty) {
      titleChanged = false;
      emit(EditTaskValidator(_editedTask, titleError: 'Wymagane'));
    } else if (title == _editedTask.title) {
      titleChanged = false;
      emit(EditTaskReady(_editedTask, requireSaving, _task.end?.isAfter(DateTime.now()) ?? false,
          _hasChanged, _selectedProject, _sendEmail, _sendPush, _sendImmediately));
    } else {
      titleChanged = true;
      _editedTask = _editedTask.copyWith(title: title);
      emit(EditTaskReady(_editedTask, requireSaving, _task.end?.isAfter(DateTime.now()) ?? false,
          _hasChanged, _selectedProject, _sendEmail, _sendPush, _sendImmediately));
    }
  }

  void changeLocation(String location) {
    _editedTask = _editedTask.copyWith(location: location);
    emit(EditTaskReady(_editedTask, requireSaving, _task.end?.isAfter(DateTime.now()) ?? false,
        _hasChanged, _selectedProject, _sendEmail, _sendPush, _sendImmediately));
  }

  void updateAssignee(List<int> list) {
    isAssigneeSelected = list.length > 0;
    _editedTask = _editedTask.copyWith(assignees: list);
    emit(EditTaskReady(_editedTask, requireSaving, _task.end?.isAfter(DateTime.now()) ?? false,
        _hasChanged, _selectedProject, _sendEmail, _sendPush, _sendImmediately));
  }

  void updateCustomField(TaskCustomFiled customFiled) {
    customValueFields = [];
    customValueFields?.clear();
    List<TaskCustomFiled> list = _editedTask.customFields;

    int index = list.indexWhere((element) => element.fieldId == customFiled.fieldId);

    list[index] = customFiled;

    _editedTask = _editedTask.copyWith(customFields: list);

    list.forEach((element) {
      if (element.available == true) {
        customValueFields?.add(TaskCustomValueFiled(element.fieldId, element.value ?? ''));
      }
    });

    emit(EditTaskReady(_editedTask, requireSaving, _task.end?.isAfter(DateTime.now()) ?? false,
        _hasChanged, _selectedProject, _sendEmail, _sendPush, _sendImmediately));
  }

  void noteChanged(String text) {
    if (text.isEmpty) {
      isNoteChanged = false;
      emit(EditTaskValidator(_editedTask, titleError: 'Wymagane'));
    } else {
      isNoteChanged = true;
      _editedNote = CalendarNote.create(text);
      emit(EditTaskReady(_editedTask, requireSaving, _task.end?.isAfter(DateTime.now()) ?? false,
          _hasChanged, _selectedProject, _sendEmail, _sendPush, _sendImmediately));
    }
  }

  void changeWholeDay(bool b) {
    _editedTask = _editedTask.copyWith(wholeDay: b);
    emit(EditTaskReady(_editedTask, requireSaving, _task.end?.isAfter(DateTime.now()) ?? false,
        _hasChanged, _selectedProject, _sendEmail, _sendPush, _sendImmediately));
  }

  void sendEmailChanged(bool b) {
    if (b != _sendEmail) {
      _sendEmail = b;
      emit(EditTaskReady(_editedTask, requireSaving, _task.end?.isAfter(DateTime.now()) ?? false,
          _hasChanged, _selectedProject, _sendEmail, _sendPush, _sendImmediately));
    }
  }

  void sendPushChanged(bool b) {
    if (b != _sendPush) {
      _sendPush = b;
      emit(EditTaskReady(_editedTask, requireSaving, _task.end?.isAfter(DateTime.now()) ?? false,
          _hasChanged, _selectedProject, _sendEmail, _sendPush, _sendImmediately));
    }
  }

  void sendImmediatelyChanged(bool b) {
    if (b != _sendImmediately) {
      _sendImmediately = b;
      emit(EditTaskReady(_editedTask, requireSaving, _task.end?.isAfter(DateTime.now()) ?? false,
          _hasChanged, _selectedProject, _sendEmail, _sendPush, _sendImmediately));
    }
  }

  void changePriority(int p) {
    if (p != _priority) {
      _priority = p;
      _editedTask = _editedTask.copyWith(priority: p);
      emit(EditTaskReady(_editedTask, requireSaving, _task.end?.isAfter(DateTime.now()) ?? false,
          _hasChanged, _selectedProject, _sendEmail, _sendPush, _sendImmediately));
    }
  }

  void changeStatus(int status) {
    if (status != _status) {
      _status = status;
      _editedTask = _editedTask.copyWith(status: status);
      emit(EditTaskReady(_editedTask, requireSaving, _task.end?.isAfter(DateTime.now()) ?? false,
          _hasChanged, _selectedProject, _sendEmail, _sendPush, _sendImmediately));
    }
  }

  void selectProject(Project project, int profileId) {
    if (project.id == Project.ownProject.id) {
      _projectsRepository
          .createAdminProject(AdminProject.create(project.name, project.colorHash))
          .then(
        (project) {
          List<int>? list = [];
          list.add(profileId);
          _projectsRepository.updateAdminProject(project.copyWith(assignees: list)).then((value) {
            _selectedProject = project;
            _editedTask = _editedTask.copyWith(project: project);
            _projectsRepository.clearCache();
            emit(EditTaskReady(
                _editedTask,
                _task.isCreate,
                _task.end?.isAfter(DateTime.now()) ?? false,
                true,
                _selectedProject,
                _sendEmail,
                _sendPush,
                _sendImmediately));
          });
        },
        onError: (e, stack) {},
      );
    } else if (project != _selectedProject) {
      _selectedProject = project;
      _editedTask = _editedTask.copyWith(project: project);
      emit(EditTaskReady(_editedTask, _task.isCreate, _task.end?.isAfter(DateTime.now()) ?? false,
          true, _selectedProject, _sendEmail, _sendPush, _sendImmediately));
    }
  }

  void errorConsumed() => stateConsumed();

  void stateConsumed() {
    _editedNote = CalendarNote.create("");
    emit(EditTaskReady(_editedTask, requireSaving, false, _hasChanged, _selectedProject, _sendEmail,
        _sendPush, _sendImmediately));
  }

  void fileDeleted(AppFile deleted) {
    _hasChanged = true;
  }

  void fileChanged(AppFile uploadResult) {
    _editedTask.notes.last.copyWith(file: uploadResult);
    _hasChanged = true;
    init(_editedTask);
  }

  void refresh() {
    init(_task);
  }

  Future<bool> saveNote() async {
    _hasChanged = true;
    emit(EditTaskProcessing(_editedTask));
    await apiRequestCreateNote().then(
      (taskNote) {
        List<CalendarNote> updatedNote = _editedTask.notes;
        updatedNote.add(taskNote);
        _editedTask = _editedTask.copyWith(notes: updatedNote);
        emit(EditTaskSaved(_editedTask, closePage: false));
        return true;
      },
      onError: (e, stack) {
        log.shout('save', e, stack);
        return false;
      },
    );
    return true;
  }

  Future<bool> save() async {
    if (isAssigneeSelected) {
      emit(EditTaskProcessing(_editedTask));
      return await apiTaskRequest().then(
        (task) {
          _task = task;
          _editedTask = task;
          _hasChanged = true;

          if (isNoteChanged) {
            apiRequestCreateNote().then((value) {
              updateTaskNote(value);
              emit(EditTaskSaved(_editedTask, closePage: true));
              Future.delayed(Duration(milliseconds: 200)).then((value) => emit(EditTaskReady(
                  _editedTask,
                  false,
                  _task.end?.isAfter(DateTime.now()) ?? false,
                  _hasChanged,
                  _selectedProject,
                  _sendEmail,
                  _sendPush,
                  _sendImmediately)));
            });
          } else {
            emit(EditTaskSaved(_editedTask, closePage: false));
          }
          return true;
        },
        onError: (e, stack) {
          log.shout('save', e, stack);

          emit(EditTaskError(_editedTask, e is AppError ? e : AppError.fromMessage(e.toString())));
          return false;
        },
      );
    } else {
      return false;
    }
  }

  Future<CalendarNote> apiRequestCreateNote() {
    if (_admin) return _projectsRepository.createAdminNote(_editedTask.id, _editedNote!.note ?? '');
    return _projectsRepository.createNote(_editedTask.id, _editedNote!.note);
  }

  Future<CalendarNote> createNote(String note) {
    Future<CalendarNote> future;
    if (_editedNote == null) {
      future = _projectsRepository.createAdminNote(_editedTask.id, note);
    } else {
      future = _projectsRepository.createAdminNote(_editedTask.id, _editedNote!.note);
    }
    return future.then((value) {
      updateTaskNote(value);
      return value;
    });
  }

  void updateTaskNote(CalendarNote note) {
    List<CalendarNote> list = List.from(_editedTask.notes);
    list.add(note);
    log.finest('update: new task list - $list');
    _editedTask = _editedTask.copyWith(notes: list);
    _task = _task.copyWith(notes: list);
  }

  void deleteTask() {
    _projectsRepository.deleteAdminTask(_task.id).then(
      (result) {
        emit(EditTaskDeleted(_editedTask));
      },
      onError: (e, stack) {
        emit(EditTaskError(_editedTask, AppError.from(e)));
      },
    );
  }

  Future<CalendarTask> apiTaskRequest() {
    if (_editedTask.isCreate) {
      return _projectsRepository.createAdminCalendarTask(
          _editedTask,
          JsonBoolConverter().toJson(_sendEmail),
          JsonBoolConverter().toJson(_sendImmediately),
          JsonBoolConverter().toJson(_sendPush),
          _status,
          _priority,
          customValueFields ?? null);
    } else if (profile!.isEmployee) {
      return _projectsRepository.updateMyCalendarTask(
          _editedTask,
          JsonBoolConverter().toJson(_sendEmail),
          JsonBoolConverter().toJson(_sendImmediately),
          JsonBoolConverter().toJson(_sendPush),
          _status,
          _priority);
    } else {
      return _projectsRepository.updateAdminCalendarTask(
          _editedTask,
          JsonBoolConverter().toJson(_sendEmail),
          JsonBoolConverter().toJson(_sendImmediately),
          JsonBoolConverter().toJson(_sendPush),
          _status,
          _priority,
          customValueFields ?? null);
    }
  }
}
