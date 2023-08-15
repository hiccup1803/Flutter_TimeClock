import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/calendar_task.dart';

import 'converter/json_date_time_converter.dart';

part 'admin_calendar_task_service.chopper.dart';

@ChopperApi(baseUrl: 'admin-tasks')
abstract class AdminCalendarTaskService extends ChopperService {
  final _jsonDateTimeConverter = JsonDateTimeConverter();

  Future<Response<List<CalendarTask>>> getFilteredTask({
    DateTime? after,
    DateTime? before,
    int? assignee,
    int page = 1,
  }) {
    return getTasks(
      body: {
        'page': page,
        'per-page': 100,
        'sort': '-start',
        'filter': {
          if (assignee != null && assignee > 0) 'assignees': assignee,
          if (after != null || before != null)
            'start': {
              if (after != null) 'gte': _jsonDateTimeConverter.toJson(after),
              if (before != null) 'lt': _jsonDateTimeConverter.toJson(before),
            }
        }
      },
    );
  }

  Future<Response<List<CalendarTask>>> getTaskList({
    DateTime? after,
    DateTime? before,
    int? assignee,
    int page = 1,
    int? status = 0,
  }) {
    return getTasks(
      body: {
        'page': page,
        'per-page': 100,
        'sort': 'start, status',
        'filter': {
          if (assignee != null && assignee > 0) 'assignees': assignee,
          if (after != null || before != null)
            'start': {
              if (after != null) 'gte': _jsonDateTimeConverter.toJson(after),
              if (before != null) 'lt': _jsonDateTimeConverter.toJson(before),
            },
          'status': status,
        }
      },
    );
  }

  @Get()
  Future<Response<List<CalendarTask>>> getTasks({
    @Query('page') int page = 1,
    @Query('per-page') int perPage = 100,
    @Body() body,
  });

  @Get(path: '{id}')
  Future<Response<CalendarTask>> getTaskById(@Path('id') int id);

  @Delete(path: '{id}')
  Future<Response> deleteTask(@Path() int id);

  @Put(path: '{id}')
  Future<Response<CalendarTask>> updateAdminCalendarTask(
    @Path('id') int? id,
    @Body() ApiCalendarTask body, //changes needed
  );

  @Post()
  Future<Response<CalendarTask>> createAdminCalendarTask(@Body() ApiCalendarTask body);

  static AdminCalendarTaskService create([ChopperClient? client]) =>
      _$AdminCalendarTaskService(client);
}
