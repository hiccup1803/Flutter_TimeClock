import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/off_time.dart';
import 'package:staffmonitor/utils/time_utils.dart';

part 'off_time_service.chopper.dart';

@ChopperApi(baseUrl: 'off-times')
abstract class OffTimeService extends ChopperService {
  static OffTimeService create([ChopperClient? client]) => _$OffTimeService(client);

  @Delete(path: '{id}')
  Future<Response> deleteOffTime(@Path('id') int id);

  @Get(path: '{id}')
  Future<Response<OffTime>> getOffTime(@Path('id') int id);

  @Put(path: '{id}')
  Future<Response<OffTime>> putOffTime(
    @Path('id') int id,
    @Body() body,
  );

  @Get()
  Future<Response<List<OffTime>>> getOffTimes({
    @Query('page') int page = 1,
    @Query('per-page') int perPage = 10,
    @Body() body,
  });

  @Post()
  Future<Response<OffTime>> postOffTime(@Body() body);

  Future<Response<OffTime>> updateOffTime(OffTime offTime) {
    return putOffTime(offTime.id, {
      'id': offTime.id,
      'startAt': offTime.startAt,
      'endAt': offTime.endAt,
      'days': offTime.days,
      'type': offTime.type,
      'note': offTime.note,
    });
  }

  Future<Response<OffTime>> createOffTime(OffTime offTime) {
    return postOffTime({
      'year': offTime.year,
      'startAt': offTime.startAt,
      'endAt': offTime.endAt,
      'days': offTime.days,
      'type': offTime.type,
      if (offTime.note?.isNotEmpty == true) 'note': offTime.note,
    });
  }

  Future<Response<List<OffTime>>> getFilteredOffTimes({
    int? page,
    int? perPage,
    String sort = '-startAt',
    DateTime? before,
    DateTime? after,
  }) {
    var formattedAfter = after?.format('yyyy-MM-dd');
    var formattedBefore = before?.format('yyyy-MM-dd');
    return getOffTimes(
      perPage: perPage ?? 10,
      page: page ?? 1,
      body: {
        if (sort.isNotEmpty == true) 'sort': sort,
        'filter': {
          'or': [
            {
              'startAt': {
                if (after != null) 'gte': formattedAfter,
                if (before != null) 'lt': formattedBefore
              }
            },
            {
              'endAt': {
                if (after != null) 'gte': formattedAfter,
                if (before != null) 'lt': formattedBefore
              }
            },
          ],
        },
      },
    );
  }
}
