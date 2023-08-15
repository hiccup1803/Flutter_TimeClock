// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_terminals_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$AdminTerminalsService extends AdminTerminalsService {
  _$AdminTerminalsService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = AdminTerminalsService;

  @override
  Future<Response<dynamic>> deleteTerminal(String id) {
    final Uri $url = Uri.parse('admin-terminals/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<AdminTerminal>> getTerminal(String id) {
    final Uri $url = Uri.parse('admin-terminals/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<AdminTerminal, AdminTerminal>($request);
  }

  @override
  Future<Response<AdminTerminal>> putTerminal(
    String id,
    dynamic body,
  ) {
    final Uri $url = Uri.parse('admin-terminals/${id}');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<AdminTerminal, AdminTerminal>($request);
  }

  @override
  Future<Response<AdminTerminal>> postTerminal(dynamic body) {
    final Uri $url = Uri.parse('admin-terminals');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<AdminTerminal, AdminTerminal>($request);
  }

  @override
  Future<Response<List<AdminTerminal>>> getTerminals({
    int page = 1,
    int perPage = 50,
    dynamic body,
  }) {
    final Uri $url = Uri.parse('admin-terminals');
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
    return client.send<List<AdminTerminal>, AdminTerminal>($request);
  }

  @override
  Future<Response<List<AdminTerminal>>> getAllTerminals() {
    final Uri $url = Uri.parse('admin-terminals');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<AdminTerminal>, AdminTerminal>($request);
  }

  @override
  Future<Response<AdminTerminal>> generateCode(String id) {
    final Uri $url = Uri.parse('admin-terminals/code/${id}');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<AdminTerminal, AdminTerminal>($request);
  }
}
