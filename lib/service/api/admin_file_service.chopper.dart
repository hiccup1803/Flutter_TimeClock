// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_file_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$AdminFileService extends AdminFileService {
  _$AdminFileService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = AdminFileService;

  @override
  Future<Response<dynamic>> deleteFile(int? id) {
    final Uri $url = Uri.parse('admin-files/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<AdminSessionFile>> getFile(int id) {
    final Uri $url = Uri.parse('admin-files/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<AdminSessionFile, AdminSessionFile>($request);
  }

  @override
  Future<Response<AdminSessionFile>> updateFile(
    int? id,
    ApiSessionFile body,
  ) {
    final Uri $url = Uri.parse('admin-files/${id}');
    final $body = body;
    final Request $request = Request(
      'PUT',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<AdminSessionFile, AdminSessionFile>($request);
  }

  @override
  Future<Response<List<AdminSessionFile>>> getFiles({
    int page = 1,
    int perPage = 25,
    dynamic body,
  }) {
    final Uri $url = Uri.parse('admin-files');
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
    return client.send<List<AdminSessionFile>, AdminSessionFile>($request);
  }
}
