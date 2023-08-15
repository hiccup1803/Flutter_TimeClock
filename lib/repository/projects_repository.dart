import 'package:staffmonitor/model/admin_project.dart';
import 'package:staffmonitor/model/calendar_note.dart';
import 'package:staffmonitor/model/calendar_task.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/model/project.dart';
import 'package:staffmonitor/model/sessions_summary.dart';
import 'package:staffmonitor/model/task_custom_value_filed.dart';
import 'package:staffmonitor/repository/preferences/app_preferences.dart';
import 'package:staffmonitor/service/api/admin_calendar_note_service.dart';
import 'package:staffmonitor/service/api/admin_calendar_task_service.dart';
import 'package:staffmonitor/service/api/admin_projects_service.dart';
import 'package:staffmonitor/service/api/calendar_note_service.dart';
import 'package:staffmonitor/service/api/calendar_task_service.dart';
import 'package:staffmonitor/service/api/project_service.dart';
import 'package:staffmonitor/service/api/sessions_service.dart';
import 'package:staffmonitor/utils/time_utils.dart';

class ProjectsRepository {
  ProjectsRepository(
      this._projectService,
      this._adminProjectsService,
      this._sessionsService,
      this._calendarTaskService,
      this._adminCalendarTaskService,
      this._calendarNoteService,
      this._adminCalendarNoteService,
      this._appPreferences);

  final AppPreferences _appPreferences;
  final ProjectService _projectService;
  final AdminProjectsService _adminProjectsService;
  final SessionsService _sessionsService;
  final CalendarTaskService _calendarTaskService;
  final AdminCalendarTaskService _adminCalendarTaskService;
  final CalendarNoteService _calendarNoteService;
  final AdminCalendarNoteService _adminCalendarNoteService;

  List<Project>? _projectsCache;

  void clearCache() {
    _projectsCache = null;
  }

  void updateLastProjects(Project? project) {
    if (project != null) _appPreferences.updateLastProjects(project.id);
  }

  Future<List<int?>> getLastProjects() => _appPreferences.getLastProjects();

  Future<List<Project>> getProjects({bool force = false}) async {
    if (force != true && _projectsCache?.isNotEmpty == true) {
      return _projectsCache!;
    }

    final response = await _projectService.getProjects(perPage: 100);

    if (response.isSuccessful) {
      _projectsCache = response.body;
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<SessionsSummary> getSessionsSummary(int? projectId, DateTime month) async {
    final response = await _sessionsService.getProjectSummary(
        month.firstDayOfMonth, month.lastDayOfMonth, projectId);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<Paginated<AdminProject>> getAdminProjects({int page = 1}) async {
    final response;
    if (page == 1000)
      response = await _adminProjectsService.getProjects(perPage: 100000);
    else
      response = await _adminProjectsService.getProjects(page: page);
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<List<AdminProject>> getAllAdminProjects() async {
    late Paginated<AdminProject> paginated;
    int page = 0;
    do {
      final result = await getAdminProjects(page: ++page);
      if (page == 1) {
        paginated = result;
      } else {
        paginated = paginated + result;
      }
    } while (paginated.hasMore);

    return paginated.list ?? [];
  }

  Future<AdminProject> createAdminProject(AdminProject project) async {
    final response = await _adminProjectsService.postProject(project);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<Project> createProject(Project project) async {
    final response = await _projectService.postProject(project);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<AdminProject> updateAdminProject(AdminProject project) async {
    final response = await _adminProjectsService.putProject(project.id, project);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<AdminProject> getAdminProjectByID(Project project) async {
    final response = await _adminProjectsService.getProject(project.id);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<bool> deleteProject(int projectId) async {
    final response = await _adminProjectsService.deleteProject(projectId);
    if (response.isSuccessful) {
      return true;
    } else {
      throw response.error!;
    }
  }

  Future<AdminProject> archiveProject(int projectId) async {
    final response = await _adminProjectsService.archiveProject(projectId);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<AdminProject> bringBackProject(int projectId) async {
    final response = await _adminProjectsService.bringBackProject(projectId);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<Paginated<CalendarTask>> getCalendarTask(DateTime from, DateTime to,
      {int page = 1}) async {
    final response =
        await _calendarTaskService.getFilteredTask(before: to, after: from, page: page);
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<List<CalendarTask>> getTasks(
    DateTime from,
    DateTime to,
  ) async {
    late Paginated<CalendarTask> paginated;
    int page = 0;
    do {
      final result = await getCalendarTask(from, to, page: ++page);

      if (page == 1) {
        paginated = result;
      } else {
        paginated = paginated + result;
      }
    } while (paginated.hasMore);

    return paginated.list ?? [];
  }

  Future<Paginated<CalendarTask>> getAdminCalendarTask(DateTime from, DateTime to,
      {int page = 1, int? assignee}) async {
    final response = await _adminCalendarTaskService.getFilteredTask(
        before: to, after: from, assignee: assignee, page: page);
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<Paginated<CalendarTask>> getAdminTask(DateTime from, DateTime to,
      {int page = 1, int? assignee, int? status}) async {
    final response = await _adminCalendarTaskService.getTaskList(
        before: to, after: from, assignee: assignee, page: page, status: status);
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<Paginated<CalendarTask>> getMyTask(DateTime from, DateTime to,
      {int page = 1, int? status}) async {
    final response =
        await _calendarTaskService.getTaskList(before: to, after: from, page: page, status: status);
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<List<CalendarTask>> getAdminTasks(DateTime from, DateTime to, int assignee) async {
    late Paginated<CalendarTask> paginated;
    int page = 0;
    do {
      final result = await getAdminCalendarTask(from, to, assignee: assignee, page: ++page);

      if (page == 1) {
        paginated = result;
      } else {
        paginated = paginated + result;
      }
    } while (paginated.hasMore);

    return paginated.list ?? [];
  }

  Future<List<CalendarTask>> getAdminTasksList(
      DateTime from, DateTime to, int assignee, int status) async {
    late Paginated<CalendarTask> paginated;
    int page = 0;
    do {
      final result = await getAdminTask(from, to, assignee: assignee, page: ++page, status: status);

      if (page == 1) {
        paginated = result;
      } else {
        paginated = paginated + result;
      }
    } while (paginated.hasMore);

    return paginated.list ?? [];
  }

  Future<List<CalendarTask>> getMyTasksList(DateTime from, DateTime to, int status) async {
    late Paginated<CalendarTask> paginated;
    int page = 0;
    do {
      final result = await getMyTask(from, to, page: ++page, status: status);

      if (page == 1) {
        paginated = result;
      } else {
        paginated = paginated + result;
      }
    } while (paginated.hasMore);

    return paginated.list ?? [];
  }

  Future<CalendarTask> createAdminCalendarTask(
      CalendarTask task,
      int? sendEmail,
      int? sendImmediately,
      int? sendPush,
      int? status,
      int? priority,
      List<TaskCustomValueFiled>? customValueFields) async {
    var response = await _adminCalendarTaskService.createAdminCalendarTask(
      ApiCalendarTask.fromCalendarTask(task, task.assignees, sendEmail, sendImmediately, sendPush,
          status, priority, customValueFields),
    );

    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<CalendarTask> updateMyCalendarTask(CalendarTask task, int? sendEmail, int? sendImmediately,
      int? sendPush, int? status, int? priority) async {
    final response = await _calendarTaskService.updateMyCalendarTask(
      task.id,
      ApiUserTask.fromCalendarTask(status, priority),
    );

    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<CalendarTask> updateAdminCalendarTask(
      CalendarTask task,
      int? sendEmail,
      int? sendImmediately,
      int? sendPush,
      int? status,
      int? priority,
      List<TaskCustomValueFiled>? customValueFields) async {
    final response = await _adminCalendarTaskService.updateAdminCalendarTask(
      task.id,
      ApiCalendarTask.fromCalendarTask(task, task.assignees, sendEmail, sendImmediately, sendPush,
          status, priority, customValueFields),
    );

    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<bool> deleteAdminTask(int taskId) async {
    final response = await _adminCalendarTaskService.deleteTask(taskId);
    if (response.isSuccessful) {
      return true;
    } else {
      throw response.error!;
    }
  }

  Future<CalendarNote> createNote(int? taskId, String? note) async {
    final response = await _calendarNoteService.saveNotes(taskId ?? 0, note ?? "");
    if (response.isSuccessful) {
      return response.body ?? CalendarNote.create("note");
    } else {
      throw response.error!;
    }
  }

  Future<CalendarNote> createAdminNote(int? taskId, String? note) async {
    final response = await _adminCalendarNoteService.saveNotes(taskId ?? 0, note ?? "");
    if (response.isSuccessful) {
      return response.body ?? CalendarNote.create("note");
    } else {
      throw response.error!;
    }
  }

  Future<CalendarTask> getTaskById(int id) async {
    final response = await _calendarTaskService.getTaskById(id);
    if (response.isSuccessful) {
      return response.body ?? CalendarTask.create(DateTime.now(),[]);
    } else {
      throw response.error!;
    }
  }

  Future<CalendarTask> getAdminTaskById(int id) async {
    final response = await _adminCalendarTaskService.getTaskById(id);
    if (response.isSuccessful) {
      return response.body ?? CalendarTask.create(DateTime.now(),[]);
    } else {
      throw response.error!;
    }
  }
}
