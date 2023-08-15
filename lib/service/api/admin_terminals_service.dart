import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/admin_project.dart';
import 'package:staffmonitor/model/admin_terminal.dart';

part 'admin_terminals_service.chopper.dart';

@ChopperApi(baseUrl: 'admin-terminals')
abstract class AdminTerminalsService extends ChopperService {
  static AdminTerminalsService create([ChopperClient? client]) => _$AdminTerminalsService(client);

  @Delete(path: '{id}')
  Future<Response> deleteTerminal(@Path() String id);

  @Get(path: '{id}')
  Future<Response<AdminTerminal>> getTerminal(@Path() String id);

  @Put(path: '{id}')
  Future<Response<AdminTerminal>> putTerminal(@Path() String id, @Body() body);

  @Post()
  Future<Response<AdminTerminal>> postTerminal(@Body() body);

  @Get()
  Future<Response<List<AdminTerminal>>> getTerminals({
    @Query() int page = 1,
    @Query('per-page') int perPage = 50,
    @Body() body,
  });

  Future<Response<List<AdminTerminal>>> getFilteredTerminals({
    int page = 1,
  }) {
    return getTerminals(
      body: {
        'page': page,
        'per-page': 100,
        'sort': 'createdAt',
        'filter': {},
      },
    );
  }

  @Get()
  Future<Response<List<AdminTerminal>>> getAllTerminals();

  @Put(path: 'code/{id}', optionalBody: true)
  Future<Response<AdminTerminal>> generateCode(@Path() String id);
}
