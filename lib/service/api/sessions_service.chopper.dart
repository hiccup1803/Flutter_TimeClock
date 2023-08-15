// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$SessionsService extends SessionsService {
  _$SessionsService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = SessionsService;

  @override
  Future<Response<dynamic>> deleteSession(int? id) {
    final Uri $url = Uri.parse('sessions/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<Session>> getSession(int id) {
    final Uri $url = Uri.parse('sessions/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Session, Session>($request);
  }

  @override
  Future<Response<Session>> updateSession(
    int? id,
    ApiSession body,
  ) {
    final Uri $url = Uri.parse('sessions/${id}');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Session, Session>($request);
  }

  @override
  Future<Response<Session>> createSession(ApiSession body) {
    final Uri $url = Uri.parse('sessions');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Session, Session>($request);
  }

  @override
  Future<Response<List<Session>>> getSessions({
    int page = 1,
    int perPage = 10,
    dynamic body,
  }) {
    final Uri $url = Uri.parse('sessions');
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
    return client.send<List<Session>, Session>($request);
  }

  @override
  Future<Response<SessionsSummary>> getSummary(
    DateTime after,
    DateTime before,
  ) {
    final Uri $url = Uri.parse('sessions/summary');
    final Map<String, dynamic> $params = <String, dynamic>{
      'from': after,
      'to': before,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<SessionsSummary, SessionsSummary>($request);
  }

  @override
  Future<Response<SessionsSummary>> getProjectSummary(
    DateTime after,
    DateTime before,
    int? projectId,
  ) {
    final Uri $url = Uri.parse('sessions/summary');
    final Map<String, dynamic> $params = <String, dynamic>{
      'from': after,
      'to': before,
      'projectId': projectId,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<SessionsSummary, SessionsSummary>($request);
  }
}
