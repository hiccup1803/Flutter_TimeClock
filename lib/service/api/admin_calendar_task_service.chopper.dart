// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_calendar_task_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$AdminCalendarTaskService extends AdminCalendarTaskService {
  _$AdminCalendarTaskService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = AdminCalendarTaskService;

  @override
  Future<Response<List<CalendarTask>>> getTasks({
    int page = 1,
    int perPage = 100,
    dynamic body,
  }) {
    final Uri $url = Uri.parse('admin-tasks');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'per-page': perPage,
    };
    final $body = body;
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      body: $body,
      parameters: $params,
    );
    return client.send<List<CalendarTask>, CalendarTask>($request);
  }

  @override
  Future<Response<CalendarTask>> getTaskById(int id) {
    final Uri $url = Uri.parse('admin-tasks/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<CalendarTask, CalendarTask>($request);
  }

  @override
  Future<Response<dynamic>> deleteTask(int id) {
    final Uri $url = Uri.parse('admin-tasks/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<CalendarTask>> updateAdminCalendarTask(
    int? id,
    ApiCalendarTask body,
  ) {
    final Uri $url = Uri.parse('admin-tasks/${id}');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<CalendarTask, CalendarTask>($request);
  }

  @override
  Future<Response<CalendarTask>> createAdminCalendarTask(ApiCalendarTask body) {
    final Uri $url = Uri.parse('admin-tasks');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<CalendarTask, CalendarTask>($request);
  }
}
