import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/device_token.dart';

part 'devices_service.chopper.dart';

@ChopperApi(baseUrl: 'devices')
abstract class DeviceService extends ChopperService {
  static DeviceService create([ChopperClient? client]) => _$DeviceService(client);

  @Delete(path: '{id}')
  Future<Response> deleteDeviceToken(@Path('id') int id);

  @Get(path: 'id')
  Future<Response<DeviceToken>> getDeviceToken(@Path('id') int id);

  @Get()
  Future<Response<List<DeviceToken>>> getDeviceTokens();

  @Post()
  Future<Response<DeviceToken>> _postDeviceToken(@Body() body);

  Future<Response<DeviceToken>> postDeviceToken(String token) => _postDeviceToken({
        'device': token,
      });
}
