// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_nfc_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$AdminNfcService extends AdminNfcService {
  _$AdminNfcService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = AdminNfcService;

  @override
  Future<Response<dynamic>> deleteNfc(int id) {
    final Uri $url = Uri.parse('admin-nfc/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<AdminNfc>> getNfcById(int id) {
    final Uri $url = Uri.parse('admin-nfc/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<AdminNfc, AdminNfc>($request);
  }

  @override
  Future<Response<AdminNfc>> putNfc(
    int id,
    dynamic body,
  ) {
    final Uri $url = Uri.parse('admin-nfc/${id}');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<AdminNfc, AdminNfc>($request);
  }

  @override
  Future<Response<AdminNfc>> postNfc(dynamic body) {
    final Uri $url = Uri.parse('admin-nfc');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<AdminNfc, AdminNfc>($request);
  }

  @override
  Future<Response<List<AdminNfc>>> getNfc({
    int page = 1,
    int perPage = 50,
    dynamic body,
  }) {
    final Uri $url = Uri.parse('admin-nfc');
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
    return client.send<List<AdminNfc>, AdminNfc>($request);
  }
}
