// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registration_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$RegisterService extends RegisterService {
  _$RegisterService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = RegisterService;

  @override
  Future<Response<InvitationDetails>> check(String? code) {
    final Uri $url = Uri.parse('profile/invite/${code}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<InvitationDetails, InvitationDetails>($request);
  }

  @override
  Future<Response<dynamic>> _register(dynamic body) {
    final Uri $url = Uri.parse('profile');
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
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _resetPassword(dynamic body) {
    final Uri $url = Uri.parse('profile/reset');
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
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> _putPassword(dynamic body) {
    final Uri $url = Uri.parse('profile/password');
    final Map<String, String> $headers = {
      'Content-Type': 'application/json',
    };
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
      headers: $headers,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> postRegister(dynamic body) {
    final Uri $url = Uri.parse('register');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
