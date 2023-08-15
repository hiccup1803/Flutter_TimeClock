import 'package:logging/logging.dart';
import 'package:staffmonitor/model/admin_terminal.dart';
import 'package:staffmonitor/model/project.dart';
import 'package:staffmonitor/model/terminal_session.dart';
import 'package:staffmonitor/model/terminal_session_nfc.dart';
import 'package:staffmonitor/model/user_history.dart';
import 'package:staffmonitor/repository/preferences/terminal_preferences.dart';
import 'package:staffmonitor/service/api/admin_terminals_service.dart';
import 'package:staffmonitor/service/api/terminal_service.dart';

import '../model/paginated_list.dart';

class TerminalRepository {
  TerminalRepository(this._preferences, this._terminalService, this._adminTerminalService);

  final log = Logger('TerminalRepository');
  final TerminalPreferences _preferences;
  final TerminalService _terminalService;
  final AdminTerminalsService _adminTerminalService;

  Future<bool> isActiveTerminal() {
    return _preferences.isActiveTerminal();
  }

  Future<String> getTerminalName() {
    return _preferences.getTerminalName();
  }

  Future<String> getCompanyName() {
    return _preferences.getCompanyName();
  }

  Future<String> getTerminalId() {
    return _preferences.getTerminalId();
  }

  Future<bool> registerTerminal(String code, String terminalId) async {
    final response = await _terminalService.registerTerminal(code, terminalId);
    if (response.isSuccessful) {
      await _preferences.setTerminalId(response.body!.terminalId);
      await _preferences.saveTerminalName(response.body!.name);
      await _preferences.saveCompanyName(response.body!.companyName);
      return true;
    } else {
      throw response.error!;
    }
  }

  Future<bool> logoutTerminal(String code) async {
    final terminalId = await _preferences.getTerminalId();
    final response = await _terminalService.registerTerminal(code, terminalId);
    if (response.isSuccessful) {
      await _preferences.clearTerminal();
      return true;
    } else {
      throw response.error!;
    }
  }

  Future<UserHistory> getUserHistory(String pin) async {
    final id = await _preferences.getTerminalId();
    final response = await _terminalService.getHistory(pin, id);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<List<AdminTerminal>> getAdminTerminals() async {
    late Paginated<AdminTerminal> paginated;

    final response = await _adminTerminalService.getFilteredTerminals();
    if (response.isSuccessful) {
      paginated = Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }

    return paginated.list ?? [];
  }

  Future<TerminalSession> toggleSession(String pin) async {
    final id = await _preferences.getTerminalId();
    final response = await _terminalService.updateSession(pin, id);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  getAdminTerminalById(String id) async {
    final response = await _adminTerminalService.getTerminal(id);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<AdminTerminal> createAdminTerminal(
      AdminTerminal editedTask, int? photoVerfication, Project selectedProject) async {
    final response = await _adminTerminalService
        .postTerminal(ApiTerminal.fromAdminTerminal(editedTask, photoVerfication));
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<AdminTerminal> updateAdminTerminal(
      AdminTerminal editedTask, int? photoVerfication, Project selectedProject) async {
    final response = await _adminTerminalService.putTerminal(
        editedTask.id, ApiTerminal.fromAdminTerminal(editedTask, photoVerfication));
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<bool> deleteAdminTerminal(String id) async {
    final response = await _adminTerminalService.deleteTerminal(id);
    if (response.isSuccessful) {
      return true;
    } else {
      throw false;
    }
  }

  Future<AdminTerminal> generateCode(String id) async {
    final response = await _adminTerminalService.generateCode(id);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<UserHistory> getUserHistoryNfc(String nfcTagId) async {
    final id = await _preferences.getTerminalId();
    final response = await _terminalService.getHistoryNfc(nfcTagId, id);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<TerminalSessionNfc> toggleSessionNfc(String nfcTagId) async {
    final id = await _preferences.getTerminalId();
    final clockId = await _preferences.getClockId();
    final response = await _terminalService.updateSessionNfc(nfcTagId, id, clockId);
    if (response.isSuccessful) {
      var result = response.body!;
      if (!result.hasNfc) {
        _preferences.saveClockId(result.clockId);
      }
      return result;
    } else {
      throw response.error!;
    }
  }
}
