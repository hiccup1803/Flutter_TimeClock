import 'dart:math' as math;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:staffmonitor/model/admin_project.dart';
import 'package:staffmonitor/model/admin_task_customfiled.dart';
import 'package:staffmonitor/model/loadable.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/model/task_custom_value_filed.dart';
import 'package:staffmonitor/model/task_customfiled.dart';
import 'package:staffmonitor/page/base_page.dart';
import 'package:staffmonitor/page/main/admin/projects/admin_project_bottom_sheet.dart';
import 'package:staffmonitor/repository/company_repository.dart';
import 'package:staffmonitor/repository/projects_repository.dart';
import 'package:staffmonitor/repository/users_repository.dart';
import 'package:staffmonitor/utils/color_utils.dart';

part 'admin_projects_state.dart';

class AdminProjectsCubit extends Cubit<AdminProjectsState> {
  AdminProjectsCubit(this._projectsRepository, this._usersRepository, this._companyRepository)
      : super(AdminProjectsInitial());

  final ProjectsRepository _projectsRepository;
  final UsersRepository _usersRepository;
  final CompanyRepository _companyRepository;

  Loadable<List<Profile>> _users = Loadable.ready([]);
  Loadable<List<AdminProject>> _projects = Loadable.ready([]);

  List<TaskCustomFiled> customFieldList = [];

  void refresh() {
    if (_users.value?.isNotEmpty != true) {
      refreshUsers();
    }

    _companyRepository.getProfileCompany().then((value) {
      if (value!.customFields.isNotEmpty) {
        List<AdminTaskCustomFiled> list = value.customFields;
        list.forEach((element) {
          if (element.target == 'project') {
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

    _projects = Loadable.inProgress();
    _updateState();
    _projectsRepository.getAllAdminProjects().then(
      (value) {
        _projects = Loadable.ready(value);
        _updateState();
      },
      onError: (e, stack) {
        _projects = Loadable.error(e, _projects.value);
        _updateState();
      },
    );
  }

  void refreshUsers() {
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

  void _updateState() {
    emit(AdminProjectsReady(
      _users,
      _projects.transform((value) => value.where((project) => project.isDeleted != true).toList()),
      _projects.transform((value) => value.where((project) => project.isDeleted).toList()),
    ));
  }

  AdminProject _updateProject(AdminProject project, {bool add = false}) {
    final projectsList = _projects.value;
    if (projectsList != null) {
      final index = projectsList.indexWhere((element) => element.id == project.id);
      if (index > -1) {
        projectsList[index] = project;
        _projects = _projects.transform((value) => projectsList);
        _updateState();
      } else if (add) {
        projectsList.add(project);
        _projects = _projects.transform((value) => projectsList);
        _updateState();
      }
    }
    return project;
  }

  Future<AdminProject> updateProject(AdminProject project) {
    return _projectsRepository.updateAdminProject(project).then(_updateProject);
  }

  Future<AdminProject> archiveProject(int projectId) {
    return _projectsRepository.archiveProject(projectId).then(_updateProject);
  }

  Future<AdminProject> bringBackProject(int projectId) {
    return _projectsRepository.bringBackProject(projectId).then(_updateProject);
  }

  Future<bool> deleteProject(int projectId) {
    return _projectsRepository.deleteProject(projectId).then((value) {
      if (value) {
        final projectsList = _projects.value;
        if (projectsList != null) {
          final index = projectsList.indexWhere((element) => element.id == projectId);
          if (index > -1) {
            projectsList.removeAt(index);
            _projects = _projects.transform((value) => projectsList);
            _updateState();
          }
        }
      }
      return value;
    });
  }

  void addNewProject(BuildContext context, String name, Color? color) {
    if (name.isEmpty) {
      return;
    }
    if (color == null || color == Colors.white) {
      color = Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    }
    _projects = Loadable.inProgress(_projects.value);
    _updateState();
    _projectsRepository.createAdminProject(AdminProject.create(name, color.toHexHash())).then(
      (project) {
        _updateProject(project, add: true);
        openAdminProject(context, project);
      },
      onError: (e, stack) {
        _users = Loadable.error(e, _users.value);
        _updateState();
      },
    );
  }

  void openAdminProject(BuildContext context, AdminProject project) {
    Future.delayed(
      Duration(milliseconds: 300),
      () => AdminProjectBottomSheet.show(
        context,
        project,
        customFieldList,
        _users.value ?? [],
        onChange: (project) {
          return updateProject(project);
        },
        delete: (projectId) {
          return deleteProject(projectId);
        },
        archive: (projectId) {
          return archiveProject(projectId);
        },
        bringBack: (projectId) {
          return bringBackProject(projectId);
        },
      ),
    );
  }
}
