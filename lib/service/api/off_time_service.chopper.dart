// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'off_time_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$OffTimeService extends OffTimeService {
  _$OffTimeService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = OffTimeService;

  @override
  Future<Response<dynamic>> deleteOffTime(int id) {
    final Uri $url = Uri.parse('off-times/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<OffTime>> getOffTime(int id) {
    final Uri $url = Uri.parse('off-times/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<OffTime, OffTime>($request);
  }

  @override
  Future<Response<OffTime>> putOffTime(
    int id,
    dynamic body,
  ) {
    final Uri $url = Uri.parse('off-times/${id}');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<OffTime, OffTime>($request);
  }

  @override
  Future<Response<List<OffTime>>> getOffTimes({
    int page = 1,
    int perPage = 10,
    dynamic body,
  }) {
    final Uri $url = Uri.parse('off-times');
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
    return client.send<List<OffTime>, OffTime>($request);
  }

  @override
  Future<Response<OffTime>> postOffTime(dynamic body) {
    final Uri $url = Uri.parse('off-times');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<OffTime, OffTime>($request);
  }
}
