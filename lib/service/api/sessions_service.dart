import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/session.dart';
import 'package:staffmonitor/model/sessions_summary.dart';

part 'sessions_service.chopper.dart';

@ChopperApi(baseUrl: 'sessions')
abstract class SessionsService extends ChopperService {
  @Delete(path: '{id}')
  Future<Response> deleteSession(@Path('id') int? id);

  @Get(path: '{id}')
  Future<Response<Session>> getSession(@Path('id') int id);

  @Put(
    path: '{id}',
  )
  Future<Response<Session>> updateSession(
    @Path('id') int? id,
    @Body() ApiSession body,
  );

  @Post()
  Future<Response<Session>> createSession(@Body() ApiSession body);

  @Get()
  Future<Response<List<Session>>> getSessions({
    @Query('page') int page = 1,
    @Query('per-page') int perPage = 10,
    @Body() body,
  });

  Future<Response<List<Session>>> getSortedSessions({
    int? page,
    int? perPage,
  }) {
    return getSessions(
      perPage: perPage ?? 10,
      page: page ?? 1,
      body: {
        'page': page ?? 1,
        'per-page': perPage ?? 10,
        'sort': '-clockIn',
      },
    );
  }

  Future<Response<List<Session>>> getFilteredSessions({
    int? page,
    int? perPage,
    String sort = '-clockIn',
    DateTime? before,
    DateTime? after,
  }) {
    return getSessions(
      perPage: perPage ?? 10,
      page: page ?? 1,
      body: {
        'page': page ?? 1,
        'per-page': perPage ?? 10,
        if (sort.isNotEmpty == true) 'sort': sort,
        "filter": {
          // if (before != null && after != null)
          "clockIn": {
            if (after != null) "gte": after.millisecondsSinceEpoch ~/ 1000,
            if (before != null) "lt": before.millisecondsSinceEpoch ~/ 1000,
          },
        },
      },
    );
  }

  Future<Response<Session>> getCurrentSession() {
    return getSessions(
      perPage: 1,
      body: {
        'per-page': 1,
        'sort': '-clockIn',
        'filter': {
          'clockOut': null,
        }
      },
    ).then((result) {
      if (result.isSuccessful) {
        if (result.body!.isNotEmpty) {
          return result.copyWith<Session>(body: result.body![0]);
        } else {
          return result.copyWith<Session>(body: Session.empty());
        }
      } else {
        return result.copyWith<Session>(body: Session.empty());
      }
    });
  }

  @Get(path: 'summary')
  Future<Response<SessionsSummary>> getSummary(
    @Query('from') DateTime after,
    @Query('to') DateTime before,
  );

  @Get(path: 'summary')
  Future<Response<SessionsSummary>> getProjectSummary(@Query('from') DateTime after,
      @Query('to') DateTime before, @Query('projectId') int? projectId);

  static SessionsService create([ChopperClient? client]) => _$SessionsService(client);
}
