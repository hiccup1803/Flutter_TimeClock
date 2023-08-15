import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dioo;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:staffmonitor/model/admin_session_file.dart';
import 'package:staffmonitor/model/admin_task_file.dart';
import 'package:staffmonitor/model/app_error.dart';
import 'package:staffmonitor/model/app_file.dart';
import 'package:staffmonitor/model/paginated_list.dart';
import 'package:staffmonitor/repository/auth_repository.dart';
import 'package:staffmonitor/service/api/admin_file_service.dart';
import 'package:staffmonitor/service/api/admin_task_file_service.dart';
import 'package:staffmonitor/service/api/file_service.dart';
import 'package:staffmonitor/service/api/file_task_service.dart';
import 'package:staffmonitor/utils/time_utils.dart';

class FilesRepository {
  FilesRepository(
      this.apiSessionUrl,
      this.apiTaskUrl,
      this.apiAdminSessionUrl,
      this.apiAdminTaskUrl,
      this.apiTerminalFileUrl,
      this.authRepository,
      this.fileService,
      this.adminFileService,
      this.adminTaskFileService,
      this.fileTaskService,
      this.flutterUploader,
      );

  final log = Logger('FilesRepository');
  final AuthRepository authRepository;
  final FlutterUploader flutterUploader;
  final FileService fileService;
  final AdminFileService adminFileService;
  final AdminTaskFileService adminTaskFileService;
  final FileTaskService fileTaskService;
  final String apiSessionUrl;
  final String apiTaskUrl;
  final String apiAdminSessionUrl;
  final String apiAdminTaskUrl;
  final String apiTerminalFileUrl;

  late bool _permissionReady;

  Future<String> uploadSessionFile(PlatformFile file, int sessionId,
      [bool admin = false, String? note]) {
    return _uploadFile(
      url: admin ? apiAdminSessionUrl : apiSessionUrl,
      file: file,
      data: {
        'clockId': '$sessionId',
        if (note != null) 'note': note,
      },
      tag: 'session_${sessionId}_${file.name}',
    );
  }

  Future<String> uploadTaskFile(PlatformFile file, int taskId, [bool admin = false, String? note]) {
    return _uploadFile(
      url: admin ? apiAdminTaskUrl : apiTaskUrl,
      file: file,
      data: {
        'taskNoteId': '$taskId',
        if (note != null) 'note': note,
      },
      tag: 'task_${taskId}_${file.name}',
    );
  }

  Future<String> uploadTerminalFile(PlatformFile file, String pin, String terminalId, int clockId,
      [bool admin = false, String? note]) {
    return _uploadTerminalFile(
      url: apiTerminalFileUrl,
      pin: pin,
      terminalId: terminalId,
      file: file,
      data: {
        'clockId': '$clockId',
        if (note != null) 'note': note,
      },
      tag: 'clock_${clockId}_${file.name}',
    );
  }

  Future<String> _uploadFile({
    required String url,
    required PlatformFile file,
    Map<String, String> data = const {},
    required String tag,
  }) async {
    final token = await authRepository.getValidAuthTokenOrRefresh();
    log.fine('uploadFile | size: ${file.size}');
    log.fine('uploadFile | path: ${file.path}');

    data['name'] = file.name;

    if (token != null) {
      return await flutterUploader.enqueue(
        MultipartFormDataUpload(
          url: url,
          headers: {
            "Authorization": token.bearerToken,
          },
          data: data,
          tag: tag,
          files: [
            FileItem(path: file.path!),
          ],
        ),
      );
    }
    throw AppError.fromMessage("Authorization error");
  }

  Future<String> _uploadTerminalFile({
    required String url,
    required String pin,
    required String terminalId,
    required PlatformFile file,
    Map<String, String> data = const {},
    required String tag,
  }) async {
    log.fine('uploadFile | size: ${file.size}');
    log.fine('uploadFile | path: ${file.path}');

    data['name'] = file.name + '.jpg';
    data['pin'] = pin;

    return await flutterUploader.enqueue(
      MultipartFormDataUpload(
        url: url,
        headers: {
          'X-Api-Key': terminalId,
        },
        data: data,
        tag: tag,
        files: [
          FileItem(path: file.path!),
        ],
      ),
    );
  }

  Future<Paginated<AdminSessionFile>> getAdminSessionFiles(
      {required int page,
        required DateTime createdAt,
        required int sessionProjectId,
        required int uploaderId}) async {
    final response = await adminFileService.getSortedFiles(
      page: page,
      perPage: 25,
      after: createdAt.firstDayOfMonth,
      before: createdAt.lastDayOfMonth,
      sessionProjectId: sessionProjectId,
      uploaderId: uploaderId,
    );
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<Paginated<AdminTaskFile>> getAdminTaskFiles(
      {required int page,
        required DateTime createdAt,
        required int taskProjectId,
        required int uploaderId}) async {
    final response = await adminTaskFileService.getSortedFiles(
      page: page,
      perPage: 25,
      after: createdAt.firstDayOfMonth,
      before: createdAt.lastDayOfMonth,
      taskProjectId: taskProjectId,
      uploaderId: uploaderId,
    );
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<Paginated<AdminTaskFile>> getAdminProjectFiles(
      {required int page,
        required DateTime createdAt,
        required int taskProjectId,
        required int uploaderId}) async {
    final response = await adminTaskFileService.getSortedFiles(
      page: page,
      perPage: 25,
      after: createdAt.firstDayOfMonth,
      before: createdAt.lastDayOfMonth,
      taskProjectId: taskProjectId,
      uploaderId: uploaderId,
    );
    if (response.isSuccessful) {
      return Paginated.fromResponse(response);
    } else {
      throw response.error!;
    }
  }

  Future<AdminSessionFile> updateAdminSessionFileNote(AdminSessionFile adminSessionFile) async {
    final response = await adminFileService.updateFile(
      adminSessionFile.id,
      ApiSessionFile.fromAdminFile(adminSessionFile),
    );

    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<AdminTaskFile> updateAdminTaskFileNote(AdminTaskFile adminTaskFile) async {
    final response = await adminTaskFileService.updateFile(
      adminTaskFile.id,
      ApiTaskFile.fromAdminFile(adminTaskFile),
    );

    if (response.isSuccessful) {
      return response.body!;
    } else {
      throw response.error!;
    }
  }

  Future<bool> deleteTaskFile(int fileId) async {
    final response = await fileTaskService.deleteFile(fileId);
    if (response.isSuccessful) {
      return true;
    } else {
      throw response.error!;
    }
  }

  Future<bool> deleteAdminTaskFile(int fileId) async {
    final response = await adminTaskFileService.deleteFile(fileId);
    if (response.isSuccessful) {
      return true;
    } else {
      throw response.error!;
    }
  }

  Future<bool> deleteAdminSessionFile(int fileId) async {
    final response = await adminFileService.deleteFile(fileId);
    if (response.isSuccessful) {
      return true;
    } else {
      throw response.error!;
    }
  }

  Future<bool> deleteSessionFile(int fileId) async {
    final response = await fileService.deleteFile(fileId);
    if (response.isSuccessful) {
      return true;
    } else {
      throw response.error!;
    }
  }

  Future<String?> downloadAdminSessionFile(AppFile file) async {
    if (file.fileDownloadUrl?.isEmpty == true) {
      throw 'Missing file download url!';
    }
    final token = await authRepository.getValidAuthTokenOrRefresh();

    if (token != null) {
      _permissionReady = await _checkPermission();
      if (!_permissionReady) return null;

      log.fine('download file: $file');

      var response = await dioo.Dio().get(file.fileDownloadUrl!,
          options: dioo.Options(
            responseType: dioo.ResponseType.bytes,
            headers: {
              "Authorization": token.bearerToken,
            },
          ));
      log.fine(response.data);
      final result = await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
          quality: 60, name: file.name);
      String path1 = result["filePath"].toString();
      String path2 = path1.split(".jpg")[0];
      String path3 = "to Pictures Folder";

      log.fine("ddddd$path2");

      log.fine("ddddd$result");

      return path3;
    } else {
      log.shout('missing auth token');
    }
    return null;
  }

  Future<String?> downloadFile(AppFile file) async {
    if (file.fileDownloadUrl?.isEmpty == true) {
      throw 'Missing file download url!';
    }
    final token = await authRepository.getValidAuthTokenOrRefresh();

    if (token != null) {
      _permissionReady = await _checkPermission();
      if (!_permissionReady) return null;
      final saveDir = await _findLocalPath();

      log.fine('download file: $file');
      log.fine('save dir: $saveDir');

      FlutterDownloader.enqueue(
        url: file.fileDownloadUrl ?? '',
        headers: {
          "Authorization": token.bearerToken,
        },
        savedDir: saveDir,
        //android only
        showNotification: true,
        //android only
        openFileFromNotification: true,
      );
      return saveDir;
    } else {
      log.shout('missing auth token');
    }
    return null;
  }

  Future<bool> _checkPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<String> _findLocalPath() async {
    final directory = await getExternalStorageDirectory();

    log.fine('directory: $directory');
    return directory?.path ?? await getApplicationDocumentsDirectory().then((value) => value.path);
  }
}

void downloadCallback(id, DownloadTaskStatus status, progress) {
  //just do nothing
  // print('downloadCallback, id: $id, status: $status, progress: $progress');
}
