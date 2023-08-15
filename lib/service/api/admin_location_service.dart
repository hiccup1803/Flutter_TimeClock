import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/user_location.dart';

part 'admin_location_service.chopper.dart';

@ChopperApi(baseUrl: 'admin-locations')
abstract class AdminLocationService extends ChopperService {
  static AdminLocationService create([ChopperClient? client]) => _$AdminLocationService(client);

  @Get(path: '{id}')
  Future<Response<UserLocation>> getLocation(@Path('id') int id);

  @Get()
  Future<Response<List<UserLocation>>> _getLocations({
    @Query('page') int page = 1,
    @Query('per-page') int perPage = 10,
    @Body() body,
  });

  Future<Response<List<UserLocation>>> getLocations(
      {int page = 1, required int sessionId, int perPage = 10}) {
    return _getLocations(page: page, perPage: perPage, body: {
      'page': page,
      'per-page': perPage,
      'sort': 'createdAt',
      'filter': {
        'sessionId': sessionId,
      },
    });
  }
}
