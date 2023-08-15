import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/auth_token.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/repository/auth_repository.dart';
import 'package:staffmonitor/repository/profile_repository.dart';
import 'package:staffmonitor/service/geolocation_service.dart';
import 'package:timezone/timezone.dart' as tz;

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  static Locale? locale;
  static tz.Location? location;

  AuthCubit(this._authRepository, this._profileRepository, this._geolocationService)
      : super(AuthInitial());

  final _log = Logger('AuthCubit');
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  final GeolocationService _geolocationService;

  StreamSubscription? _authStreamSubscription;

  @override
  Future<void> close() {
    _authStreamSubscription?.cancel();
    _authStreamSubscription = null;
    return super.close();
  }

  void init({bool? sessionLogin}) {
    _log.fine('init auth cubit');
    _authStreamSubscription?.cancel();
    _authStreamSubscription = _authRepository.authTokenStream.listen(onAuthChange);
    _authRepository.getValidAuthTokenOrRefresh().then(
      (token) {
        _log.fine('getValidAuthTokenOrRefresh: $token');
        onAuthChange(token);
      },
      onError: (e, stack) {
        _log.shout('getValidAuthTokenOrRefresh error', e, stack);
        emit(AuthUnauthorized());
      },
    );
  }

  void onAuthChange(AuthToken? newToken, {bool? sessionLogin}) {
    _log.fine('onAuthChange: $newToken');
    if (newToken == null) {
      _log.fine('onAuthChange: token null');
      emit(AuthUnauthorized());
    } else if (sessionLogin == true) {
      refreshProfile();
    } else if (newToken.isValid || newToken.isRefreshValid) {
      if (state is! AuthAuthorized) {
        _log.fine('onAuthChange: token possibly valid and state isn\'t AuthAuthorized');
        refreshProfile();
      } else {
        _log.fine('onAuthChange: newToken is Valid but we are already authorized');
      }
    } else {
      _log.fine('onAuthChange: token not valid');
      emit(AuthUnauthorized());
    }
  }

  Future<String?> getAccessToken() async {
    await _authRepository.getValidAuthTokenOrRefresh();
    String? token = await _authRepository.getJwtTokenData();
    return token;
  }

  Future<bool> singIn(String user, String password, String? deviceToken) async {
    return _authRepository.signIn(user, password, deviceToken);
  }

  void signOut() async {
    await _geolocationService.stopTracking();
    await _authRepository.signOut();
    emit(AuthUnauthorized());
  }

  void updateProfile(Profile? profile) {
    if (profile != null) {
      final authAuthorized = AuthAuthorized(profile);
      locale = authAuthorized.locale;

      location = profile.timezone != null ? tz.getLocation(profile.timezone!) : null;
      _log.fine('onAuthChange: updateProfile');
      emit(authAuthorized);
    }
  }

  Future<Profile?> updateProjects(int? projectId, List<int>? projects) async {
    return _profileRepository.updateProjects(projectId, projects).then((updated) {
      final authAuthorized = AuthAuthorized(updated);
      locale = authAuthorized.locale;
      location = updated.timezone != null ? tz.getLocation(updated.timezone!) : null;
      _log.fine('onAuthChange: updateProjects');
      emit(authAuthorized);
      return updated;
    }, onError: (e, stack) {
      Logger('Auth').shout('updateProjects', e, stack);
      return null;
    });
  }

  Future updateDefaultProject(int? id) async {
    final AuthState s = state;
    if (s is AuthAuthorized) {
      return await updateProjects(id, s.profile!.preferredProjects);
    }
  }

  Future addProjectToPreferred(int projectId) async {
    final AuthState s = state;
    if (s is AuthAuthorized) {
      final list = List.of(s.profile!.preferredProjects!);
      if (!list.contains(projectId)) {
        list.add(projectId);
        return await updateProjects(s.profile!.defaultProject?.id, list);
      }
    }
    return null;
  }

  Future removeProjectFromPreferred(int projectId) async {
    final AuthState s = state;
    if (s is AuthAuthorized) {
      final list = List.of(s.profile!.preferredProjects!);
      if (list.contains(projectId)) {
        list.remove(projectId);
        return await updateProjects(s.profile!.defaultProject?.id, list);
      }
    }
    return null;
  }

  Future refreshProfile() {
    return _profileRepository.getProfile().then(
      (profile) {
        _log.finest('refreshProfile: $profile');
        final authAuthorized = AuthAuthorized(profile);
        locale = authAuthorized.locale;
        location = profile?.timezone != null ? tz.getLocation(profile!.timezone!) : null;
        emit(authAuthorized);
      },
      onError: (e, stack) {
        _log.shout('refreshProfile', e, stack);
        emit(AuthUnauthorized(AppError.from(e)));
      },
    );
  }
}
