import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/profile.dart';

part 'profile_service.chopper.dart';

@ChopperApi(baseUrl: 'profile')
abstract class ProfileService extends ChopperService {

  static ProfileService create([ChopperClient? client]) =>
      _$ProfileService(client);

  @Get()
  Future<Response<Profile>> getProfile();

  @Put()
  Future<Response<Profile>> _putProfile(@Body() profileForm);

  Future<Response<Profile>> updateProjects(
      int? projectId, List<int>? preferredProjects) {
    return _putProfile(
        {'projectId': projectId, 'preferredProjects': preferredProjects});
  }

  Future<Response<Profile>> updateProfile({
    String? name,
    String? lang,
    required int? phone,
    String? hourRate,
    String? rateCurrency,
    int? lastProjectLimit,
    int? projectId,
  }) {
    var map = Map<String, dynamic>();
    if (name != null) map['name'] = name;
    //telefon moze być null bo nie ma jak inczej to wyzerowac
    map['phone'] = phone;
    //tu tez mozna wyslac nic
    map['projectId'] = projectId;
    if (lang != null) map['lang'] = lang;
    if (hourRate != null) map['hourRate'] = hourRate;
    if (rateCurrency != null) map['rateCurrency'] = rateCurrency;
    if (lastProjectLimit != null) map['lastProjectsLimit'] = lastProjectLimit;

    return _putProfile(map);
  }

}
