import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:staffmonitor/model/company_profile.dart';
import 'package:staffmonitor/repository/preferences/preference_repository.dart';
import 'package:staffmonitor/service/api/admin_company_service.dart';
import 'package:staffmonitor/service/network_status_service.dart';

class CompanyRepository {
  CompanyRepository(
    this._profileCompanyService,
    this._preferenceRepository,
    this._networkStatusService,
  );

  final log = Logger('ProfileRepository');
  final AdminCompanyService _profileCompanyService;
  final PreferenceRepository _preferenceRepository;
  final NetworkStatusService _networkStatusService;
  static const String _PROFILE_COMPANY_DATA = 'profile_company_data';

  Future<CompanyProfile?> getProfileCompany() async {
    var prefs = await _preferenceRepository.getPreferences();

    bool netStatus = await _networkStatusService.isNetworkAvailable();
    if (netStatus) {
      final response = await _profileCompanyService.getProfileCompany();
      if (response.isSuccessful) {
        prefs.setString(_PROFILE_COMPANY_DATA, json.encode(response.body?.toJson()));
        return response.body!;
      } else {
        throw response.error!;
      }
    } else {
      var savedProfile = prefs.getString(_PROFILE_COMPANY_DATA);

      if (savedProfile != null) {
        return CompanyProfile.fromJson(json.decode(savedProfile));
      }
      return null;
    }
  }

  Future<CompanyProfile> updateProfileCompany(
      {required int id,
      String? name,
      String? contact,
      int? filesLimit,
      int? spaceLimit,
      int? fileSizeLimit,
      String? spaceLimitUnit,
      String? timezone,
      int? status,
      int? employeeLimit,
      int? autoClose,
      int? autoCloseMidnight}) async {
    final response = await _profileCompanyService.updateProfileCompany(
      id: id,
      name: name,
      contact: contact,
      filesLimit: filesLimit,
      spaceLimit: spaceLimit,
      fileSizeLimit: fileSizeLimit,
      spaceLimitUnit: spaceLimitUnit,
      timezone: timezone,
      status: status,
      employeeLimit: employeeLimit,
      autoClose: autoClose,
      autoCloseMidnight: autoCloseMidnight,
    );
    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }
}
