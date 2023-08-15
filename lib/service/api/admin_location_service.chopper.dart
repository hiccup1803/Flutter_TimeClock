// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_location_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$AdminLocationService extends AdminLocationService {
  _$AdminLocationService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = AdminLocationService;

  @override
  Future<Response<UserLocation>> getLocation(int id) {
    final Uri $url = Uri.parse('admin-locations/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<UserLocation, UserLocation>($request);
  }

  @override
  Future<Response<List<UserLocation>>> _getLocations({
    int page = 1,
    int perPage = 10,
    dynamic body,
  }) {
    final Uri $url = Uri.parse('admin-locations');
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
    return client.send<List<UserLocation>, UserLocation>($request);
  }
}
