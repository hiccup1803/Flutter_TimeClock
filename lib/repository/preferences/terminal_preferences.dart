import 'package:staffmonitor/repository/preferences/preference_repository.dart';

class TerminalPreferences {
  static const String _TERMINAL_ID = 'terminal_id';
  static const String _TERMINAL_NAME = 'terminal_name';
  static const String _TERMINAL_COMPANY_NAME = 'terminal_company_name';
  static const String _TERMINAL_CLOCK_ID = 'terminal_clock_id';

  const TerminalPreferences(this._repository);

  final PreferenceRepository _repository;

  Future<bool> isActiveTerminal() async {
    return _repository.getPreferences().then((value) {
      return value.getString(_TERMINAL_ID)?.isNotEmpty == true;
    });
  }

  Future<String> getTerminalId() async {
    final prefs = await _repository.getPreferences();
    return prefs.getString(_TERMINAL_ID) ?? '';
  }

  Future setTerminalId(String id) async {
    final prefs = await _repository.getPreferences();
    return await prefs.setString(_TERMINAL_ID, id);
  }

  Future disableTerminal() async {
    final prefs = await _repository.getPreferences();
    return await prefs.remove(_TERMINAL_ID);
  }

  Future<String> getTerminalName() async {
    final prefs = await _repository.getPreferences();
    return prefs.getString(_TERMINAL_NAME) ?? '';
  }

  Future saveTerminalName(String name) async {
    final prefs = await _repository.getPreferences();
    return await prefs.setString(_TERMINAL_NAME, name);
  }

  Future<String> getCompanyName() async {
    final prefs = await _repository.getPreferences();
    return prefs.getString(_TERMINAL_COMPANY_NAME) ?? '';
  }

  Future saveCompanyName(String name) async {
    final prefs = await _repository.getPreferences();
    return await prefs.setString(_TERMINAL_COMPANY_NAME, name);
  }

  Future<int?> getClockId() async {
    final prefs = await _repository.getPreferences();
    return prefs.getInt(_TERMINAL_CLOCK_ID);
  }

  Future saveClockId(int? id) async {
    final prefs = await _repository.getPreferences();
    return id == null
        ? await prefs.remove(_TERMINAL_CLOCK_ID)
        : await prefs.setInt(_TERMINAL_CLOCK_ID, id);
  }

  Future clearTerminal() async {
    final prefs = await _repository.getPreferences();
    await prefs.remove(_TERMINAL_ID);
    await prefs.remove(_TERMINAL_COMPANY_NAME);
    await prefs.remove(_TERMINAL_NAME);
  }
}
