import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/terminal_access.dart';
import 'package:staffmonitor/model/terminal_session.dart';
import 'package:staffmonitor/model/terminal_session_nfc.dart';
import 'package:staffmonitor/model/user_history.dart';

part 'terminal_service.chopper.dart';

@ChopperApi(baseUrl: 'terminal')
abstract class TerminalService extends ChopperService {
  static TerminalService create([ChopperClient? client]) => _$TerminalService(client);

  @Get(path: 'history')
  Future<Response<UserHistory>> _getHistory(@Body() body, @Header('X-Api-Key') String terminalId);

  Future<Response<UserHistory>> getHistory(String pin, String terminalId) =>
      _getHistory({'pin': pin}, terminalId);

  @Put(path: 'access')
  Future<Response<TerminalAccess>> _putAccess(@Body() body, @Header('X-Api-Key') String terminalId);

  Future<Response<TerminalAccess>> registerTerminal(String code, String terminalId) =>
      _putAccess({'code': int.tryParse(code) ?? 0}, terminalId);

  @Put(path: 'session')
  Future<Response<TerminalSession>> _putSession(
      @Body() body, @Header('X-Api-Key') String terminalId);

  Future<Response<TerminalSession>> updateSession(String pin, String terminalId) =>
      _putSession({'pin': pin}, terminalId);

  @Put(path: 'session-nfc')
  Future<Response<TerminalSessionNfc>> _putSessionNfc(
      @Body() body, @Header('X-Api-Key') String terminalId);

  Future<Response<TerminalSessionNfc>> updateSessionNfc(String nfc, String terminalId, int? clockId) {
    var map = <String, dynamic>{'nfc': nfc};
    if (clockId != null) {
      map['clockId'] = clockId;
    }
    return _putSessionNfc(map, terminalId);
  }

  @Get(path: 'history-nfc')
  Future<Response<UserHistory>> _getHistoryNfc(
      @Body() body, @Header('X-Api-Key') String terminalId);

  Future<Response<UserHistory>> getHistoryNfc(String nfc, String terminalId) =>
      _getHistoryNfc({'nfc': nfc}, terminalId);
}
