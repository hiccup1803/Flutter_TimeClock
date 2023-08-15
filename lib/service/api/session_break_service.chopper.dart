// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_break_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$SessionBreakService extends SessionBreakService {
  _$SessionBreakService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = SessionBreakService;

  @override
  Future<Response<dynamic>> deleteBreak(int? id) {
    final Uri $url = Uri.parse('breaks/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<SessionBreak>> getBreak(int id) {
    final Uri $url = Uri.parse('breaks/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<SessionBreak, SessionBreak>($request);
  }

  @override
  Future<Response<SessionBreak>> updateBreak(
    int id,
    dynamic body,
  ) {
    final Uri $url = Uri.parse('breaks/${id}');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<SessionBreak, SessionBreak>($request);
  }

  @override
  Future<Response<List<SessionBreak>>> _getBreaks(dynamic body) {
    final Uri $url = Uri.parse('breaks');
    final $body = body;
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<List<SessionBreak>, SessionBreak>($request);
  }

  @override
  Future<Response<SessionBreak>> _postBreak(dynamic body) {
    final Uri $url = Uri.parse('breaks');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<SessionBreak, SessionBreak>($request);
  }
}
