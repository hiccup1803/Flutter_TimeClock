// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$ProjectService extends ProjectService {
  _$ProjectService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = ProjectService;

  @override
  Future<Response<Project>> getProject(int id) {
    final Uri $url = Uri.parse('projects/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<Project, Project>($request);
  }

  @override
  Future<Response<List<Project>>> getProjects({
    int? page,
    int? perPage,
  }) {
    final Uri $url = Uri.parse('projects');
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
    return client.send<List<Project>, Project>($request);
  }

  @override
  Future<Response<Project>> postProject(dynamic body) {
    final Uri $url = Uri.parse('projects');
    final $body = body;
    final Request $request = Request(
      'POST',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<Project, Project>($request);
  }
}
