import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/invitation_details.dart';

part 'registration_service.chopper.dart';

@ChopperApi(baseUrl: '')
abstract class RegisterService extends ChopperService {
  @Get(path: 'profile/invite/{code}')
  Future<Response<InvitationDetails>> check(@Path('code') String? code);

  @Post(path: 'profile', headers: {'Content-Type': 'application/json'})
  Future<Response> _register(@Body() body);

  Future<Response> register(
    String? code,
    String name,
    String email,
    String password,
  ) =>
      _register({
        'code': code,
        'name': name,
        'email': email,
        'password': password,
      });

  @Post(path: 'profile/reset', headers: {'Content-Type': 'application/json'})
  Future<Response> _resetPassword(@Body() body);

  Future<Response> resetPassword(String email) => _resetPassword({'email': email});

  @Put(path: 'profile/password', headers: {'Content-Type': 'application/json'})
  Future<Response> _putPassword(@Body() body);

  Future<Response> setNewPassword(String token, String password) => _putPassword({
        'token': token,
        'password': password,
      });

  @Post(path: 'register')
  Future<Response> postRegister(@Body() body);

  Future<Response> registerAccount(
    String email,
    String name,
    String? lang,
    String password,
    String rateCurrency,
    String companyName,
    String timeZone,
  ) {
    return postRegister({
      'adminEmail': email,
      'adminName': name,
      'adminLang': lang,
      'adminPassword': password,
      'adminRateCurrency': rateCurrency,
      'companyName': companyName,
      'companyTimezone': timeZone,
    });
  }

  static RegisterService create([ChopperClient? client]) => _$RegisterService(client);
}
