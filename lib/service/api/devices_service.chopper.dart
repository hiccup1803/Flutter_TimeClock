// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$DeviceService extends DeviceService {
  _$DeviceService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = DeviceService;

  @override
  Future<Response<dynamic>> deleteDeviceToken(int id) {
    final Uri $url = Uri.parse('devices/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<DeviceToken>> getDeviceToken(int id) {
    final Uri $url = Uri.parse('devices/id');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<DeviceToken, DeviceToken>($request);
  }

  @override
  Future<Response<List<DeviceToken>>> getDeviceTokens() {
    final Uri $url = Uri.parse('devices');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<DeviceToken>, DeviceToken>($request);
  }

  @override
  Future<Response<DeviceToken>> _postDeviceToken(dynamic body) {
    final Uri $url = Uri.parse('devices');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<DeviceToken, DeviceToken>($request);
  }
}
