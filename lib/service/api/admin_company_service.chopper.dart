// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_company_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$AdminCompanyService extends AdminCompanyService {
  _$AdminCompanyService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = AdminCompanyService;

  @override
  Future<Response<CompanyProfile>> getProfileCompany() {
    final Uri $url = Uri.parse('admin-company');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<CompanyProfile, CompanyProfile>($request);
  }

  @override
  Future<Response<CompanyProfile>> _putProfile(dynamic profileForm) {
    final Uri $url = Uri.parse('admin-company');
    final $body = profileForm;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<CompanyProfile, CompanyProfile>($request);
  }
}
