import 'dart:async';
import 'dart:core';

import 'package:logging/logging.dart';
import 'package:pushy_flutter/pushy_flutter.dart';
import 'package:staffmonitor/injector.dart';
import 'package:staffmonitor/model/auth_token.dart';
import 'package:staffmonitor/repository/preferences/app_preferences.dart';
import 'package:staffmonitor/service/api/auth_service.dart';
import 'package:staffmonitor/service/network_status_service.dart';

import 'preferences/auth_preferences.dart';

class AuthRepository {
  AuthRepository(this._authApi, this._authPrefs, this._appPreferences, this._networkStatusService);

  final AuthService _authApi;
  final AuthPreferences _authPrefs;
  final AppPreferences _appPreferences;
  final NetworkStatusService? _networkStatusService;

  final _log = Logger('AuthRepository');

  AuthToken? _token;
  StreamController<AuthToken?> _tokenStream = StreamController<AuthToken?>.broadcast();

  Stream<AuthToken?> get authTokenStream => _tokenStream.stream;

  void _updateCacheAndStream(AuthToken? nextToken) {
    if (_token != nextToken) {
      _token = nextToken;
      _tokenStream.sink.add(nextToken);
    }
  }

  Future<AuthToken?> getValidAuthTokenOrRefresh() async {
    final token = await getJwtToken();
    _log.fine('getValidAuthTokenOrRefresh: $token');
    if (token?.isValid ?? false) {
      _log.fine('getValidAuthTokenOrRefresh: isValid');
      return token;
    }
    if (token?.isRefreshValid ?? false) {
      _log.fine('getValidAuthTokenOrRefresh: isRefreshValid');
      bool netStatus = (_networkStatusService != null)
          ? await _networkStatusService!.isNetworkAvailable()
          : true;
      if (netStatus == true) {
        _log.fine('getValidAuthTokenOrRefresh: netStatus ok');
        try {
          return refreshToken();
        } catch (e, stack) {
          _log.warning('getValidAuthTokenOrRefresh', e, stack);
        }
      } else {
        _log.fine('getValidAuthTokenOrRefresh: netStatus false');
        return null;
      }
    }
    return null;
  }

  Future<JwtToken?> getJwtToken() async {
    if (_token == null) {
      _updateCacheAndStream(await _authPrefs.getJwtToken());
    }
    return _token as FutureOr<JwtToken?>;
  }

  Future<String?> getJwtTokenData() async {
    return await _authPrefs.getTokenData();
  }

  AuthToken? getCachedAuthToken() {
    return _token;
  }

  Future updateToken(JwtToken? token) async {
    _log.fine('updateToken: ${token != null}');
    if (token != null) {
      await _authPrefs.saveAuthToken(token);
    }
    _updateCacheAndStream(token);
  }

  Future<AuthToken?> refreshToken() async {
    var token = await getJwtToken();
    if (token != null) {
      try {
        final response =
            await _authApi.refreshToken(token.refresh, deviceToken: await Pushy.register());
        if (response.isSuccessful) {
          final freshToken = response.body;
          updateToken(freshToken);
          return freshToken;
        } else {
          _log.shout('refreshToken', response.error);
          throw response.error!;
        }
      } catch (e) {
        await _authPrefs.clearAuthToken();
        _updateCacheAndStream(null);
        throw e;
      }
    } else {
      _updateCacheAndStream(null);
      return null;
    }
  }

  Future<bool> signIn(String userName, String password, String? deviceToken) async {
    bool netStatus =
        (_networkStatusService != null) ? await _networkStatusService!.isNetworkAvailable() : true;

    if (netStatus == true) {
      try {
        final response = await _authApi.accessToken(userName, password, deviceToken: deviceToken);

        await _authPrefs.clearAuthToken();
        await injector.offlineStorage.clearAll();

        if (response.isSuccessful) {
          final token = response.body;
          updateToken(token);
          if (token != null) {
            if (await _appPreferences.isFirstOpen()) {
              _appPreferences.setFirstOpen(false);
            }
          }
          return token != null;
        } else {
          _log.warning('signIn:', response.error);
          throw response.error!;
        }
      } catch (e) {
        _updateCacheAndStream(null);
        throw e;
      }
    } else {
      return false;
    }
  }

  Future<void> signOut() async {
    await _authPrefs.clearAuthToken();
    _updateCacheAndStream(null);
  }

  void dispose() {
    _tokenStream.close();
  }
}
