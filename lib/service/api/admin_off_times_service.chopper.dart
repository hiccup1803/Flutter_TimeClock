// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_off_times_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$AdminOffTimesService extends AdminOffTimesService {
  _$AdminOffTimesService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = AdminOffTimesService;

  @override
  Future<Response<dynamic>> deleteOffTime(int id) {
    final Uri $url = Uri.parse('admin-off-times/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<AdminOffTime>> getOffTime(int id) {
    final Uri $url = Uri.parse('admin-off-times/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<AdminOffTime, AdminOffTime>($request);
  }

  @override
  Future<Response<AdminOffTime>> putOffTime(
    int id,
    dynamic body,
  ) {
    final Uri $url = Uri.parse('admin-off-times/${id}');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<AdminOffTime, AdminOffTime>($request);
  }

  @override
  Future<Response<AdminOffTime>> postOffTime(dynamic body) {
    final Uri $url = Uri.parse('admin-off-times');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<AdminOffTime, AdminOffTime>($request);
  }

  @override
  Future<Response<AdminOffTime>> approveOffTime(int id) {
    final Uri $url = Uri.parse('admin-off-times/approve/${id}');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<AdminOffTime, AdminOffTime>($request);
  }

  @override
  Future<Response<AdminOffTime>> denyOffTime(int id) {
    final Uri $url = Uri.parse('admin-off-times/deny/${id}');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<AdminOffTime, AdminOffTime>($request);
  }

  @override
  Future<Response<List<AdminOffTime>>> getOffTimes({
    int page = 1,
    int perPage = 10,
    dynamic body,
  }) {
    final Uri $url = Uri.parse('admin-off-times');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'per-page': perPage,
    };
    final $body = body;
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      body: $body,
      parameters: $params,
    );
    return client.send<List<AdminOffTime>, AdminOffTime>($request);
  }
}
