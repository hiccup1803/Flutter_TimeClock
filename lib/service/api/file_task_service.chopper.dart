// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_task_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// ignore_for_file: always_put_control_body_on_new_line, always_specify_types, prefer_const_declarations, unnecessary_brace_in_string_interps
class _$FileTaskService extends FileTaskService {
  _$FileTaskService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final definitionType = FileTaskService;

  @override
  Future<Response<dynamic>> deleteFile(int? id) {
    final Uri $url = Uri.parse('task-files/${id}');
    final Request $request = Request(
      'DELETE',
      $url,
      client.baseUrl,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<AppFile>> downloadFile(int id) {
    final Uri $url = Uri.parse('task-files/download/${id}');
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
    );
    return client.send<AppFile, AppFile>($request);
  }
}
