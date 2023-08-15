import 'package:logging/logging.dart';
import 'package:staffmonitor/model/auth_token.dart';

import 'preference_repository.dart';

const String PREFIX = "auth_";
const String ACCESS_KEY = PREFIX + "access_token";
const String REFRESH_KEY = PREFIX + "refresh_token";
const String EXPIRATION_KEY = PREFIX + "expiration";
const String REFRESH_EXPIRATION_KEY = PREFIX + "refresh_expiration";

class AuthPreferences {
  AuthPreferences(this._repository);

  final _log = Logger('AuthPreferences');
  final PreferenceRepository _repository;

  JwtToken? _token;

  Future<void> clearAuthToken() async {
    _log.fine('clearAuthToken');
    await _repository.getPreferences().then((p) {
      p.remove(ACCESS_KEY);
      p.remove(REFRESH_KEY);
      p.remove(EXPIRATION_KEY);
      p.remove(REFRESH_EXPIRATION_KEY);
    });
    _token = null;
    return;
  }

  Future<JwtToken?> getJwtToken() async {
    _log.fine('getJwtToken');
    if (_token == null) {
      final p = await _repository.getPreferences();
      if (p.containsKey(ACCESS_KEY) && p.containsKey(REFRESH_KEY))
        try {
          _token = JwtToken(
            p.getString(ACCESS_KEY)!,
            p.getString(REFRESH_KEY)!,
          );
        } catch (e, stack) {
          _log.warning('getJwtToken', e, stack);
        }
    }
    return _token;
  }

  Future<String?> getTokenData() async {
    final p = await _repository.getPreferences();
    return p.getString(ACCESS_KEY);
  }

  Future<void> saveAuthToken(JwtToken token) async {
    _log.fine('saveAuthToken');
    final p = await _repository.getPreferences();

    await p.setString(ACCESS_KEY, token.access);
    await p.setString(REFRESH_KEY, token.refresh);
    await p.setInt(EXPIRATION_KEY, token.expiration.millisecondsSinceEpoch);
    await p.setInt(REFRESH_EXPIRATION_KEY, token.refreshExpiration.millisecondsSinceEpoch);
    _token = token;
  }
}
