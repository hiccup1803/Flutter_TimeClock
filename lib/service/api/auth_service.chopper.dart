// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$AuthService extends AuthService {
  _$AuthService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = AuthService;

  @override
  Future<Response<JwtToken>> _refreshToken(dynamic body) {
    final Uri $url = Uri.parse('token/refresh');
    final Map<String, String> $headers = {
      'Content-Type': 'application/json',
    };
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<JwtToken, JwtToken>($request);
  }

  @override
  Future<Response<JwtToken>> _accessToken(dynamic body) {
    final Uri $url = Uri.parse('token/access');
    final Map<String, String> $headers = {
      'Content-Type': 'application/json',
    };
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<JwtToken, JwtToken>($request);
  }
}
