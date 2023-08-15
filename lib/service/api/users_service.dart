import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/pin.dart';
import 'package:staffmonitor/model/profile.dart';

part 'users_service.chopper.dart';

@ChopperApi(baseUrl: 'admin-users')
abstract class UsersService extends ChopperService {
  static UsersService create([ChopperClient? client]) => _$UsersService(client);

  @Get(path: '/{id}')
  Future<Response<Profile>> getUser(@Path('id') int id);

  @Put(path: '/{id}')
  Future<Response<Profile>> putUser(@Path('id') int? id, @Body() body);

  @Post()
  Future<Response<Profile>> postUser(@Body() body);

  @Get()
  Future<Response<List<Profile>>> getUsers({
    @Query('page') int page = 1,
    @Query('per-page') int perPage = 10,
    @Body() body,
  });

  Future<Response<List<Profile>>> getActiveEmployee({
    int? page,
    int? perPage,
  }) {
    return getUsers(
      perPage: perPage ?? 25,
      page: page ?? 1,
      body: {
        'page': page ?? 1,
        'per-page': perPage ?? 100,
        'filter': {
          'status': 1,
        }
      },
    );
  }

  @Put(path: 'promote/{id}/{to}', optionalBody: true)
  Future<Response<Profile>> promoteUser(@Path('id') int? id, @Path('to') int? to);

  @Put(path: 'demote/{id}/{to}', optionalBody: true)
  Future<Response<Profile>> demoteUser(@Path('id') int? id, @Path('to') int? to);

  @Put(path: 'deactivate/{id}', optionalBody: true)
  Future<Response<Profile>> deactivateUser(@Path('id') int? id);

  @Put(path: 'reactivate/{id}', optionalBody: true)
  Future<Response<Profile>> activateUser(@Path('id') int? id);

  @Put(path: 'reset/{id}', optionalBody: true)
  Future<Response> resetUserPassword(@Path('id') int? id);

  @Put(path: 'pin/{id}', optionalBody: true)
  Future<Response<Pin>> generateUserPin(@Path('id') int? id);

  @Put(path: 'remove-pin/{id}', optionalBody: true)
  Future<Response> removeUserPin(@Path('id') int? id);
}
