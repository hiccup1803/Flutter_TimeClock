import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/admin_nfc.dart';
import 'package:staffmonitor/model/admin_project.dart';
import 'package:staffmonitor/model/admin_terminal.dart';

part 'admin_nfc_service.chopper.dart';

@ChopperApi(baseUrl: 'admin-nfc')
abstract class AdminNfcService extends ChopperService {
  static AdminNfcService create([ChopperClient? client]) => _$AdminNfcService(client);

  @Delete(path: '{id}')
  Future<Response> deleteNfc(@Path() int id);

  @Get(path: '{id}')
  Future<Response<AdminNfc>> getNfcById(@Path() int id);

  @Put(path: '{id}')
  Future<Response<AdminNfc>> putNfc(@Path() int id, @Body() body);

  @Post()
  Future<Response<AdminNfc>> postNfc(@Body() body);

  @Get()
  Future<Response<List<AdminNfc>>> getNfc({
    @Query('page') int page = 1,
    @Query('per-page') int perPage = 50,
    @Body() body,
  });

  Future<Response<List<AdminNfc>>> getFilteredNfc(
    String type, {
    int page = 1,
  }) {
    return getNfc(
      body: {
        'page': page,
        'per-page': 100,
        'sort': '-type',
        'filter': {
        },
      },
    );
  }
}