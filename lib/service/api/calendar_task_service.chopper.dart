// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_task_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$CalendarTaskService extends CalendarTaskService {
  _$CalendarTaskService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = CalendarTaskService;

  @override
  Future<Response<List<CalendarTask>>> getTasks({
    int page = 1,
    int perPage = 100,
    dynamic body,
  }) {
    final Uri $url = Uri.parse('tasks');
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
    final Uri $url = Uri.parse('tasks/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<CalendarTask, CalendarTask>($request);
  }

  @override
  Future<Response<CalendarTask>> updateMyCalendarTask(
    int? id,
    ApiUserTask body,
  ) {
    final Uri $url = Uri.parse('tasks/${id}');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<CalendarTask, CalendarTask>($request);
  }
}
