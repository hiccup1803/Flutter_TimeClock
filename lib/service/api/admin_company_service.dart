import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:staffmonitor/model/company_profile.dart';

part 'admin_company_service.chopper.dart';

@ChopperApi(baseUrl: 'admin-company')
abstract class AdminCompanyService extends ChopperService {
  static AdminCompanyService create([ChopperClient? client]) => _$AdminCompanyService(client);

  @Get()
  Future<Response<CompanyProfile>> getProfileCompany();

  @Put()
  Future<Response<CompanyProfile>> _putProfile(@Body() profileForm);

  Future<Response<CompanyProfile>> updateProfileCompany(
      {required int id,
      String? name,
      String? contact,
      int? filesLimit,
      int? spaceLimit,
      int? fileSizeLimit,
      String? spaceLimitUnit,
      String? timezone,
      int? status, //Type (0 = Short, 1 = Vacation) = ['0', '1'],
      int? employeeLimit,
      int? autoClose,
      int? autoCloseMidnight}) {
    var map = Map<String, dynamic>();
    map['id'] = id;
    if (name != null) map['name'] = name;
    if (contact != null) map['contact'] = contact;
    if (filesLimit != null) map['filesLimit'] = filesLimit;
    if (spaceLimit != null) map['spaceLimit'] = spaceLimit;
    if (fileSizeLimit != null) map['fileSizeLimit'] = fileSizeLimit;
    if (spaceLimitUnit != null) map['spaceLimitUnit'] = spaceLimitUnit;
    if (timezone != null) map['timezone'] = timezone;
    if (status != null) map['status'] = status;
    if (employeeLimit != null) map['employeeLimit'] = employeeLimit;
    if (autoClose != null) map['autoClose'] = autoClose;
    if (autoCloseMidnight != null) map['autoCloseAfter24'] = autoCloseMidnight;

    return _putProfile(map);
  }
}