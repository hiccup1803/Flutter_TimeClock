// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_sessions_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$AdminSessionsService extends AdminSessionsService {
  _$AdminSessionsService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = AdminSessionsService;

  @override
  Future<Response<dynamic>> deleteSession(int id) {
    final Uri $url = Uri.parse('admin-sessions/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<AdminSession>> getSession(int id) {
    final Uri $url = Uri.parse('admin-sessions/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<AdminSession, AdminSession>($request);
  }

  @override
  Future<Response<AdminSession>> updateSession(
    int id,
    ApiSession body,
  ) {
    final Uri $url = Uri.parse('admin-sessions/${id}');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<AdminSession, AdminSession>($request);
  }

  @override
  Future<Response<AdminSession>> postSessions(dynamic body) {
    final Uri $url = Uri.parse('admin-sessions');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<AdminSession, AdminSession>($request);
  }

  @override
  Future<Response<List<AdminSession>>> getSessions({
    int page = 1,
    int perPage = 10,
    dynamic body,
  }) {
    final Uri $url = Uri.parse('admin-sessions');
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
    return client.send<List<AdminSession>, AdminSession>($request);
  }

  @override
  Future<Response<AdminSession>> approveSession(int id) {
    final Uri $url = Uri.parse('admin-sessions/approve/${id}');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<AdminSession, AdminSession>($request);
  }
}
