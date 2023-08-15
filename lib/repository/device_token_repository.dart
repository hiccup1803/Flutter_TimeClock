import 'package:staffmonitor/model/device_token.dart';
import 'package:staffmonitor/service/api/devices_service.dart';

class DeviceTokenRepository {
  final DeviceService _deviceService;

  DeviceTokenRepository(this._deviceService);

  Future<DeviceToken> register(String token) async {
    final response = await _deviceService.postDeviceToken(token);

    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }
}
