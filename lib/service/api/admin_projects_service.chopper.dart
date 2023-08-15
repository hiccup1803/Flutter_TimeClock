// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_projects_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$AdminProjectsService extends AdminProjectsService {
  _$AdminProjectsService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = AdminProjectsService;

  @override
  Future<Response<dynamic>> deleteProject(int id) {
    final Uri $url = Uri.parse('admin-projects/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<AdminProject>> getProject(int id) {
    final Uri $url = Uri.parse('admin-projects/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<AdminProject, AdminProject>($request);
  }

  @override
  Future<Response<AdminProject>> putProject(
    int id,
    dynamic body,
  ) {
    final Uri $url = Uri.parse('admin-projects/${id}');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<AdminProject, AdminProject>($request);
  }

  @override
  Future<Response<AdminProject>> postProject(dynamic body) {
    final Uri $url = Uri.parse('admin-projects');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<AdminProject, AdminProject>($request);
  }

  @override
  Future<Response<List<AdminProject>>> getProjects({
    int page = 1,
    int perPage = 50,
  }) {
    final Uri $url = Uri.parse('admin-projects');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'per-page': perPage,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    return client.send<List<AdminProject>, AdminProject>($request);
  }

  @override
  Future<Response<List<AdminProject>>> getAllProjects() {
    final Uri $url = Uri.parse('admin-projects');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<AdminProject>, AdminProject>($request);
  }

  @override
  Future<Response<AdminProject>> archiveProject(int id) {
    final Uri $url = Uri.parse('admin-projects/archive/${id}');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<AdminProject, AdminProject>($request);
  }

  @override
  Future<Response<AdminProject>> bringBackProject(int id) {
    final Uri $url = Uri.parse('admin-projects/bring-back/${id}');
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
    );
    return client.send<AdminProject, AdminProject>($request);
  }
}
