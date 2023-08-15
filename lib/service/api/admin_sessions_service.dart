import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/admin_session.dart';
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

part 'admin_sessions_service.chopper.dart';

@ChopperApi(baseUrl: 'admin-sessions')
abstract class AdminSessionsService extends ChopperService {
  static AdminSessionsService create([ChopperClient? client]) => _$AdminSessionsService(client);

  final _jsonDateTimeConverter = JsonDateTimeConverter();

  @Delete(path: '{id}')
  Future<Response> deleteSession(@Path() int id);

  @Get(path: '{id}')
  Future<Response<AdminSession>> getSession(@Path() int id);

  @Put(path: '{id}')
  Future<Response<AdminSession>> updateSession(
    @Path() int id,
    @Body() ApiSession body,
  );

  @Post()
  Future<Response<AdminSession>> postSessions(@Body() body);

  @Get()
  Future<Response<List<AdminSession>>> getSessions({
    @Query('page') int page = 1,
    @Query('per-page') int perPage = 10,
    @Body() body,
  });

  Future<Response<List<AdminSession>>> getFilteredSessions({
    int? page,
    int? perPage,
    DateTime? after,
    DateTime? before,
    int? assignee,
  }) =>
      getSessions(
        page: page ?? 1,
        perPage: perPage ?? 10,
        body: {
          'page': page ?? 1,
          'per-page': perPage ?? 10,
          'sort': '-clockIn',
          'filter': {
            if (assignee != null && assignee > 0) 'userId': assignee,
            if (after != null || before != null)
              'clockIn': {
                if (after != null) 'gte': _jsonDateTimeConverter.toJson(after),
                if (before != null) 'lt': _jsonDateTimeConverter.toJson(before),
              }
          },
        },
      );

  @Put(path: 'approve/{id}', optionalBody: true)
  Future<Response<AdminSession>> approveSession(@Path() int id);
}
