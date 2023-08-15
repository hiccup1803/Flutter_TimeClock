// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$UsersService extends UsersService {
  _$UsersService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = UsersService;

  @override
  Future<Response<Profile>> getUser(int id) {
    final Uri $url = Uri.parse('admin-users/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Profile, Profile>($request);
  }

  @override
  Future<Response<Profile>> putUser(
    int? id,
    dynamic body,
  ) {
    final Uri $url = Uri.parse('admin-users/${id}');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Profile, Profile>($request);
  }

  @override
  Future<Response<Profile>> postUser(dynamic body) {
    final Uri $url = Uri.parse('admin-users');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Profile, Profile>($request);
  }

  @override
  Future<Response<List<Profile>>> getUsers({
    int page = 1,
    int perPage = 10,
    dynamic body,
  }) {
    final Uri $url = Uri.parse('admin-users');
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
    return client.send<List<Profile>, Profile>($request);
  }

  @override
  Future<Response<Profile>> promoteUser(
    int? id,
    int? to,
  ) {
    final Uri $url = Uri.parse('admin-users/promote/${id}/${to}');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<Profile, Profile>($request);
  }

  @override
  Future<Response<Profile>> demoteUser(
    int? id,
    int? to,
  ) {
    final Uri $url = Uri.parse('admin-users/demote/${id}/${to}');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<Profile, Profile>($request);
  }

  @override
  Future<Response<Profile>> deactivateUser(int? id) {
    final Uri $url = Uri.parse('admin-users/deactivate/${id}');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<Profile, Profile>($request);
  }

  @override
  Future<Response<Profile>> activateUser(int? id) {
    final Uri $url = Uri.parse('admin-users/reactivate/${id}');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<Profile, Profile>($request);
  }

  @override
  Future<Response<dynamic>> resetUserPassword(int? id) {
    final Uri $url = Uri.parse('admin-users/reset/${id}');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<Pin>> generateUserPin(int? id) {
    final Uri $url = Uri.parse('admin-users/pin/${id}');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<Pin, Pin>($request);
  }

  @override
  Future<Response<dynamic>> removeUserPin(int? id) {
    final Uri $url = Uri.parse('admin-users/remove-pin/${id}');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }
}
