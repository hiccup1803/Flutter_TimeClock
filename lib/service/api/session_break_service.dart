import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/session_break.dart';
import 'package:staffmonitor/service/api/converter/json_date_time_converter.dart';

part 'session_break_service.chopper.dart';

@ChopperApi(baseUrl: 'breaks')
abstract class SessionBreakService extends ChopperService {
  @Delete(path: '{id}')
  Future<Response> deleteBreak(@Path('id') int? id);

  @Get(path: '{id}')
  Future<Response<SessionBreak>> getBreak(@Path('id') int id);

  @Put(path: '{id}')
  Future<Response<SessionBreak>> updateBreak(@Path('id') int id, @Body() body);

  @Get()
  Future<Response<List<SessionBreak>>> _getBreaks(@Body() body);

  @Get()
  Future<Response<List<SessionBreak>>> getBreaks({
    int page = 1,
    int perPage = 20,
    required int sessionId,
  }) {
    return _getBreaks({
      'page': page,
      'per-page': perPage,
      'sort': 'start',
      'filter': {
        'sessionId': sessionId,
      },
    });
  }

  @Post()
  Future<Response<SessionBreak>> _postBreak(@Body() body);

  Future<Response<SessionBreak>> createBreak(int sessionId, DateTime start, {DateTime? end}) {
    return _postBreak({
      'sessionId': sessionId,
      'start': JsonDateTimeConverter().toJson(start),
      if (end != null) 'end': JsonDateTimeConverter().toJson(end),
    });
  }

  static SessionBreakService create([ChopperClient? client]) => _$SessionBreakService(client);
}
