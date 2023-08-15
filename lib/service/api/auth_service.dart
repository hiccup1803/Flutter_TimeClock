import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/auth_token.dart';

part 'auth_service.chopper.dart';

@ChopperApi(baseUrl: 'token')
abstract class AuthService extends ChopperService {
  static AuthService create([ChopperClient? client]) => _$AuthService(client);

  @Post(path: 'refresh', headers: {'Content-Type': 'application/json'})
  Future<Response<JwtToken>> _refreshToken(@Body() body);

  @Post(path: 'access', headers: {'Content-Type': 'application/json'})
  Future<Response<JwtToken>> _accessToken(@Body() body);

  Future<Response<JwtToken>> refreshToken(String refresh, {String? deviceToken}) => _refreshToken({
        'token': refresh,
        if (deviceToken != null) 'device': deviceToken,
      });

  Future<Response<JwtToken>> accessToken(String userName, String password, {String? deviceToken}) =>
      _accessToken({
        'email': userName,
        'password': password,
        if (deviceToken != null) 'device': deviceToken,
      });
}
