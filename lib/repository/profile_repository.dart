import 'dart:async';

import 'package:logging/logging.dart';
import 'package:staffmonitor/model/profile.dart';
import 'package:staffmonitor/service/api/profile_service.dart';
import 'package:staffmonitor/service/network_status_service.dart';
import 'package:staffmonitor/storage/offline_storage.dart';

class ProfileRepository {
  ProfileRepository(this._profileService, this._offlineStorage, this._networkStatusService);

  final log = Logger('ProfileRepository');
  final ProfileService _profileService;
  final OfflineStorage _offlineStorage;
  final NetworkStatusService _networkStatusService;

  Future<Profile?> getProfile() async {
    bool netStatus = await _networkStatusService.isNetworkAvailable();
    if (netStatus) {
      final response = await _profileService.getProfile();
      if (response.isSuccessful) {
        Profile profile = response.body!;
        _offlineStorage.updateProfile(profile);
        return profile;
      } else {
        throw response.error!;
      }
    } else {
      return _offlineStorage.getProfile();
    }
  }

  Future<Profile> updateProjects(int? defaultProjectId, List<int>? preferred) async {
    final response = await _profileService.updateProjects(defaultProjectId, preferred);
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<Profile> updateProfile(
    String name,
    String? lang,
    int? phone,
    String hourRate,
    String? rateCurrency,
    int? lastProjectsLimit,
    int? projectId,
  ) async {
    final response = await _profileService.updateProfile(
      name: name,
      lang: lang,
      phone: phone,
      hourRate: hourRate,
      rateCurrency: rateCurrency,
      lastProjectLimit: lastProjectsLimit ?? 0,
      projectId: projectId,
    );

    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }
}
