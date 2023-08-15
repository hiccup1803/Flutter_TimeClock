import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/admin_off_time.dart';
import 'package:staffmonitor/utils/time_utils.dart';

part 'admin_off_times_service.chopper.dart';

@ChopperApi(baseUrl: 'admin-off-times')
abstract class AdminOffTimesService extends ChopperService {
  static AdminOffTimesService create([ChopperClient? client]) => _$AdminOffTimesService(client);

  @Delete(path: '{id}')
  Future<Response> deleteOffTime(@Path() int id);

  @Get(path: '{id}')
  Future<Response<AdminOffTime>> getOffTime(@Path() int id);

  @Put(path: '{id}')
  Future<Response<AdminOffTime>> putOffTime(@Path() int id, @Body() body);

  @Post()
  Future<Response<AdminOffTime>> postOffTime(@Body() body);

  @Put(path: 'approve/{id}', optionalBody: true)
  Future<Response<AdminOffTime>> approveOffTime(@Path() int id);

  @Put(path: 'deny/{id}', optionalBody: true)
  Future<Response<AdminOffTime>> denyOffTime(@Path() int id);

  @Get()
  Future<Response<List<AdminOffTime>>> getOffTimes({
    @Query('page') int page = 1,
    @Query('per-page') int perPage = 10,
    @Body() body,
  });

  Future<Response<List<AdminOffTime>>> getFilteredOffTimes({
    int page = 1,
    int perPage = 10,
    DateTime? after,
    DateTime? before,
    int? assignee,
  }) {
    return getOffTimes(
      page: page,
      perPage: perPage,
      body: {
        'page': page,
        'per-page': perPage,
        'sort': '-startAt',
        'filter': {
          if (assignee != null && assignee > 0) 'userId': assignee,
          if (after != null || before != null)
            'startAt': {
              if (after != null) 'gte': after.format('yyyy-MM-dd'),
              if (before != null) 'lt': before.format('yyyy-MM-dd'),
            }
        },
      },
    );
  }

  Future<Response<AdminOffTime>> createOffTime(AdminOffTime offTime) {
    return postOffTime({
      'userId': offTime.userId,
      'approved': offTime.status,
      'note': offTime.note,
      'year': offTime.year,
      'startAt': offTime.startAt,
      'endAt': offTime.endAt,
      'days': offTime.days,
      'type': offTime.type,
      if (offTime.note?.isNotEmpty == true) 'note': offTime.note,
    });
  }

  Future<Response<AdminOffTime>> updateOffTime(AdminOffTime offTime) {
    return putOffTime(offTime.id, {
      'id': offTime.id,
      'userId': offTime.userId,
      'approved': offTime.status,
      'startAt': offTime.startAt,
      'endAt': offTime.endAt,
      'days': offTime.days,
      'type': offTime.type,
      'note': offTime.note,
    });
  }
}
