import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/calendar_task.dart';

import 'converter/json_date_time_converter.dart';

part 'calendar_task_service.chopper.dart';

@ChopperApi(baseUrl: 'tasks')
abstract class CalendarTaskService extends ChopperService {
  final _jsonDateTimeConverter = JsonDateTimeConverter();

  Future<Response<List<CalendarTask>>> getFilteredTask({
    DateTime? after,
    DateTime? before,
    int page = 1,
  }) {
    return getTasks(
      body: {
        'page': page,
        'per-page': 100,
        'sort': '-start',
        'filter': {
          'start': {
            if (after != null) 'gte': _jsonDateTimeConverter.toJson(after),
            if (before != null) 'lt': _jsonDateTimeConverter.toJson(before),
          }
        },
      },
    );
  }

  Future<Response<List<CalendarTask>>> getTaskList({
    DateTime? after,
    DateTime? before,
    int page = 1,
    int? status = 0,
  }) {
    return getTasks(
      body: {
        'page': page,
        'per-page': 100,
        'sort': 'start, status',
        'filter': {
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

  @Put(path: '{id}')
  Future<Response<CalendarTask>> updateMyCalendarTask(
    @Path('id') int? id,
    @Body() ApiUserTask body, //changes needed
  );

  static CalendarTaskService create([ChopperClient? client]) => _$CalendarTaskService(client);
}
