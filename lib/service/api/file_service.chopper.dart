// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$FileService extends FileService {
  _$FileService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = FileService;

  @override
  Future<Response<dynamic>> deleteFile(int? id) {
    final Uri $url = Uri.parse('files/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<AppFile>> getFile(int id) {
    final Uri $url = Uri.parse('files/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<AppFile, AppFile>($request);
  }

  @override
  Future<Response<List<AppFile>>> getFiles() {
    final Uri $url = Uri.parse('files');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<List<AppFile>, AppFile>($request);
  }
}
